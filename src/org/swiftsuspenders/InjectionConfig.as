/* * Copyright (c) 2009 the original author or authors * * Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions: * * The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software. * * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE. */package org.swiftsuspenders{
	import flash.utils.Dictionary;
		/**	 * @author tschneidereit	 */	public class InjectionConfig 	{		/*******************************************************************************************		*								public properties										   *		*******************************************************************************************/		public var request : Class;		public var response : Object;		public var injectionType : int;		public var injectionName : String;						/*******************************************************************************************		*								public methods											   *		*******************************************************************************************/		public function InjectionConfig(request : Class, response : Object, 			injectionType : int, injectionName : String)		{			this.request = request;			this.response = response;			this.injectionType = injectionType;			this.injectionName = injectionName;		}				public function getResponse(injector : Injector, singletons : Dictionary) : Object		{			var result : Object;			if (injectionType == InjectionType.VALUE)			{				injector.injectInto(response);				result = response;			}			else if (injectionType == InjectionType.CLASS)			{				result = injector.instantiate(Class(response));			}			else if (injectionType == InjectionType.SINGLETON)			{				var usedSingletonsMap : Dictionary = singletons;				if (injectionName)				{					usedSingletonsMap = singletons[injectionName];					if (!usedSingletonsMap)					{						usedSingletonsMap = singletons[injectionName] = new Dictionary();					}				}				result = usedSingletonsMap[request];				if (!result)				{					result = usedSingletonsMap[request] = injector.instantiate(Class(response));				}			}			return result;		}	}}