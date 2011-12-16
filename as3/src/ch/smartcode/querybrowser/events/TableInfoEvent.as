package ch.smartcode.querybrowser.events
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
	
	import flash.events.Event;
	
	public class TableInfoEvent extends Event
	{
		
		public static const TABLE_INFO_LOADED:String = "tableInfoLoaded";
		public static const SET_QUERY:String = "setQuery";
		
		private var _data:XML;

		public function TableInfoEvent(type:String, data:XML, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			_data = data;
			super(type, bubbles, cancelable);
		}
		

		public function get data():XML
		{
			return _data;
		}

		override public function clone():Event
		{
			return new TableInfoEvent( type, data, bubbles, cancelable );
		}
	}
}