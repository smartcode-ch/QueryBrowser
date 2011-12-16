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
	
	import ch.smartcode.querybrowser.vo.QueryVO;
	
	import flash.events.Event;
	
	public class ValidateQueryEvent extends Event
	{
		public static const VALIDATE_QUERY:String = "validateQuery";
		public static const QUERY_VALID:String = "queryValid";
		public static const QUERY_INVALID:String = "queryInvalid";

		private var _queryVO:QueryVO;
		
		public function ValidateQueryEvent(type:String, queryVO:QueryVO, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_queryVO = queryVO;
			super(type, bubbles, cancelable);
		}


		public function get queryVO():QueryVO
		{
			return _queryVO;
		}
		
		override public function clone():Event
		{
			return new ValidateQueryEvent( type, queryVO, bubbles, cancelable );
		}

	}
}