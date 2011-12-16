package ch.smartcode.querybrowser.models
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
	
	import ch.smartcode.querybrowser.events.QueryBrowserModelEvent;
	import ch.smartcode.querybrowser.events.TableInfoEvent;
	import ch.smartcode.querybrowser.services.QueryParser;
	import ch.smartcode.querybrowser.services.QueryRemote;
	import ch.smartcode.querybrowser.vo.QueryVO;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	import org.robotlegs.mvcs.Actor;
	
	[Bindable]
	public class QueryBrowserModel extends Actor
	{
		[Inject]
		public var parser:QueryParser;
		
		private var _queries:ArrayCollection;
		
		public function QueryBrowserModel()
		{
			_queries = new ArrayCollection();
			_queries.filterFunction = hideCurrentQuery;
		}
		
		private function hideCurrentQuery( queryVO:QueryVO ):Boolean
		{
			if( queryVO.query == parser.queryVO.query ) {
				return false;
			}
			
			return true;
		}
		
		[Bindable(event="queriesChanged")]
		public function get queries():ArrayCollection
		{
			return _queries;
		}
		
		public function addQuery( queryVO:QueryVO ):void
		{
			
			var queryVoItem:QueryVO = new QueryVO();
			queryVoItem.query = queryVO.query;
			queryVoItem.type = queryVO.type;
			
			var exists:Boolean = false;
			
			for each( var storedQueryVO:QueryVO in _queries ) {
				if( storedQueryVO.query == queryVoItem.query) {
					_queries.removeItemAt( _queries.getItemIndex( storedQueryVO ) )
					_queries.addItemAt( queryVoItem,0);	
					exists = true;
					break;
				}
			}
			
			if( !exists ) {
				_queries.addItemAt( queryVoItem, 0 );
			}
			
			_queries.refresh();
			dispatch( new Event("queriesChanged") );
			eventDispatcher.dispatchEvent( new QueryBrowserModelEvent(QueryBrowserModelEvent.QUERIES_CHANGED) );
		}

		
	}
}