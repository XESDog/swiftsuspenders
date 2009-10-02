/* * Copyright (c) 2009 the original author or authors * * Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions: * * The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software. * * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE. */package org.swiftsuspenders{	import flash.utils.Dictionary;	import flash.utils.describeType;	import flash.utils.getQualifiedClassName;	/**	 * @author tschneidereit	 */	public class Injector	{		/*******************************************************************************************		*								public properties										   *		*******************************************************************************************/						/*******************************************************************************************		*								protected/ private properties							   *		*******************************************************************************************/		private var m_mappings : Dictionary;		private var m_singletons : Dictionary;		private var m_injectionPointLists : Dictionary;		private var m_successfulInjections : Dictionary;						/*******************************************************************************************		*								public methods											   *		*******************************************************************************************/		public function Injector()		{			m_mappings = new Dictionary();			m_singletons = new Dictionary();			m_injectionPointLists = new Dictionary();			m_successfulInjections = new Dictionary(true);		}		public function mapValue(			whenAskedFor : Class, useValue : Object, named : String = null) : void		{			var config : InjectionConfig = new InjectionConfig(				whenAskedFor, useValue, InjectionConfig.INJECTION_TYPE_VALUE);			addMapping(config, named);		}		public function mapClass(			whenAskedFor : Class, instantiateClass : Class, named : String = null) : void		{			var config : InjectionConfig = new InjectionConfig(				whenAskedFor, instantiateClass, InjectionConfig.INJECTION_TYPE_CLASS);			addMapping(config, named);		}				public function mapSingleton(whenAskedFor : Class, named : String = null) : void		{			mapSingletonOf(whenAskedFor, whenAskedFor, named);		}		public function mapSingletonOf(			whenAskedFor : Class, useSingletonOf : Class, named : String = null) : void		{			var config : InjectionConfig = new InjectionConfig(				whenAskedFor, useSingletonOf, InjectionConfig.INJECTION_TYPE_SINGLETON);			addMapping(config, named);		}				public function injectInto(target : Object) : void		{			if (m_successfulInjections[target])			{				return;			}						//get injection points or cache them if this targets' class wasn't encountered before			var injectionPoints : Array = 				m_injectionPointLists[target.constructor] || getInjectionPoints(target.constructor);			var description : XML = describeType(target);			for each (var injectionPoint : InjectionPoint in injectionPoints)			{				var config : InjectionConfig = injectionPoint.mappings[injectionPoint.propertyType];				if (!config)				{					throw(						new InjectorError(							'Injector is missing a rule to handle injection into target ' + target + '. Target dependency: ' + injectionPoint.propertyType						)					);					continue;				}								if (config.injectionType == InjectionConfig.INJECTION_TYPE_VALUE)				{					injectInto(config.response);					target[injectionPoint.propertyName] = config.response;				}				else if (config.injectionType == InjectionConfig.INJECTION_TYPE_CLASS)				{					var response : Object = new (Class(config.response))();					injectInto(response);					target[injectionPoint.propertyName] = response;				}				else if (config.injectionType == InjectionConfig.INJECTION_TYPE_SINGLETON)				{					var singleton : Object = m_singletons[config.response];					if (!singleton)					{						singleton = m_singletons[config.response] = new (Class(config.response))();						injectInto(singleton);						singleton;					}					target[injectionPoint.propertyName] = singleton;				}			}			m_successfulInjections[target] = true;		}				public function unmap(clazz : Class, named : String = null) : void		{			var requestName : String = getQualifiedClassName(clazz);			if (named && m_mappings[named])			{				delete Dictionary(m_mappings[named])[requestName];			}			else			{				delete m_mappings[requestName];			}		}						/*******************************************************************************************		*								protected/ private methods								   *		*******************************************************************************************/		private function addMapping(config : InjectionConfig, named : String) : void		{			var requestName : String = getQualifiedClassName(config.request);			if (named)			{				var nameMappings : Dictionary = m_mappings[named];				if (!nameMappings)				{					nameMappings = m_mappings[named] = new Dictionary();				}				nameMappings[requestName] = config;			}			else			{				m_mappings[requestName] = config;			}		}				private function getInjectionPoints(clazz : Class) : Array		{			var injectionPoints : Array = m_injectionPointLists[clazz] = [];						var description : XML = describeType(clazz);			for each (var node : XML in description..metadata.(@name == 'Inject'))			{				var injectionPoint : InjectionPoint = new InjectionPoint();				var mappings : Dictionary;				if (node.hasOwnProperty('arg') && node.arg.(@key == 'name').length)				{					var name : String = node.arg.@value.toString();					mappings = m_mappings[name];					if (!mappings)					{						m_mappings[name] = new Dictionary();					}				}				else				{					mappings = m_mappings;				}				injectionPoint.mappings = mappings;				injectionPoint.propertyType = node.parent().@type.toString();								injectionPoint.propertyName = node.parent().@name.toString();				injectionPoints.push(injectionPoint);			}						return injectionPoints;		}	}}