package ch.smartcode.querybrowser.vo
{
	/* 
	Copyright (C) 2011  Rico Leuthold // rico.leuthold@smartcode.ch
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>. 
	*/
	
	import flash.events.EventDispatcher;

	public class QueryVO extends EventDispatcher
	{		
		public static const COMPLEX:String = "complex";
		public static const SIMPLE:String = "simple";
		
		[Bindable]
		public var query:String;
		private var _type:String;

		public function get type():String
		{
			return _type;
		}
		
		[Inspectable(type="String",category="Other", defaultValue="simple", enumeration="complex,simple")]
		public function set type(value:String):void
		{
			_type = value;
		}

	}
}