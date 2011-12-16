package ch.smartcode.querybrowser.services
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
	
	import ch.smartcode.querybrowser.config.QueryInputConfig;
	import ch.smartcode.querybrowser.events.ValidateQueryEvent;
	import ch.smartcode.querybrowser.vo.QueryVO;
	
	import org.robotlegs.mvcs.Actor;

	public class QueryParser extends Actor
	{
		
		private var _queryVO:QueryVO;
		
		private var _node:XML;
		private var _table:String;
		private var _fields:XMLList = new XMLList();
		

		public function get fields():XMLList
		{
			return _fields;
		}

		public function get table():String
		{
			return _table;
		}
		
		public function set queryVO( value:QueryVO ):void
		{
			_queryVO = value;
		}

		[Bindable]
		public function get queryVO():QueryVO
		{
			return _queryVO;
		}

		public function setQueryFromXML( node:XML ):String
		{
			_node = node;
			_queryVO = new QueryVO;
			if( _node.name() == 'table' ) {
				_fields = new XMLList();
				updatedFields();
				_table = node.@name;
				
				_queryVO.query = 'SELECT * FROM ' + _table;
				
			} else {
				
				if( _node.@table != _table) {
					_fields = new XMLList();
				} 
				
				updatedFields();
				_table = node.@table;
				
				_queryVO.query = 'SELECT ' + fieldsString() + ' FROM ' + _table;
			}
			
			_queryVO.type = QueryVO.SIMPLE;
			return _queryVO.query;
		}

		public function setQueryFromQueryVO(queryVO:QueryVO):String
		{
			_queryVO = queryVO;
			return _queryVO.query;
		}
		
		private function updatedFields( ):void
		{
			if( _node.name() == 'field' ) {
				if( _fields.contains( _node ) ) {
					for ( var i:int; i < _fields.length(); i++ ) {
						if( _fields[i].@name == _node.@name) {
					 		delete _fields[i];
							break;
					 	}
					}
				} else {
					_fields[ _fields.length() ] = _node.copy();
					
				}
			} else if (_node.name() == 'table') {
				_fields =  new XMLList();
			}
		}
		
		private function fieldsString():String
		{
			var fieldsString:String = "";
			for each( var field:XML in _fields ) {
				fieldsString = fieldsString.concat( field.@name + ",");
			}
			
			return fieldsString.substr(0, fieldsString.length -1) ;
			
		}
		
		public function validateQuery(queryVO:QueryVO):void
		{
			if( QueryInputConfig.VALID_QUERY.test( queryVO.query ) ) {
				eventDispatcher.dispatchEvent( new ValidateQueryEvent( ValidateQueryEvent.QUERY_VALID, queryVO ) );
			} else {
				eventDispatcher.dispatchEvent( new ValidateQueryEvent( ValidateQueryEvent.QUERY_INVALID, queryVO ) );
			}
			
		}
	}
}