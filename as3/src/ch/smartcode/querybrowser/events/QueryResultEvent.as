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
	
	import ch.smartcode.querybrowser.datastructures.PagedList;
	
	import flash.events.Event;
	
	public class QueryResultEvent extends Event
	{
		
		public static const RESULTS_RECEIVED:String = "resultsReceived";

		private var _results:PagedList;
		private var _newQuery:Boolean;
		private var _fields:Array;

		public function QueryResultEvent(type:String, results:PagedList, fields:Array, newQuery:Boolean = false, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_results = results;
			_fields = fields;
			_newQuery = newQuery;
			super(type, bubbles, cancelable);
		}

		public function get fields():Array
		{
			return _fields;
		}

		public function get newQuery():Boolean
		{
			return _newQuery;
		}

		public function get results():PagedList
		{
			return _results;
		}

		override public function clone():Event
		{
			return new QueryResultEvent(type,results,fields,newQuery,bubbles,cancelable);
		}
	}
}