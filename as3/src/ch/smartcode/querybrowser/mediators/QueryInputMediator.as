package ch.smartcode.querybrowser.mediators
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
	
	import ch.smartcode.querybrowser.events.QueriesListEvent;
	import ch.smartcode.querybrowser.events.ValidateQueryEvent;
	import ch.smartcode.querybrowser.events.TableInfoEvent;
	import ch.smartcode.querybrowser.services.QueryParser;
	import ch.smartcode.querybrowser.views.inputs.QueryInput;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class QueryInputMediator extends Mediator
	{
		
		[Inject]
		public var view:QueryInput;
		
		[Inject]
		public var parser:QueryParser;
		
		override public function onRegister():void
		{
			addViewListener( ValidateQueryEvent.VALIDATE_QUERY, queryValidateHandler, ValidateQueryEvent );
			addContextListener( ValidateQueryEvent.QUERY_INVALID, queryInvalidHandler, ValidateQueryEvent );
			addContextListener( ValidateQueryEvent.QUERY_VALID, queryValidHandler, ValidateQueryEvent );
			addContextListener( TableInfoEvent.SET_QUERY, setQueryFromTableInfoHandler, TableInfoEvent );
			addContextListener( QueriesListEvent.SET_QUERY_FROM_LIST, setQueryFromQueriesListHandler, QueriesListEvent );
			
			view.valid = false;
		}
		
		private function queryValidateHandler( e:ValidateQueryEvent ):void
		{
			parser.validateQuery( e.queryVO );
		}
		
		private function setQueryFromQueriesListHandler( e:QueriesListEvent ):void
		{
			view.text = parser.setQueryFromQueryVO( e.queryVO );
		}

		private function queryInvalidHandler( e:ValidateQueryEvent ):void
		{
			parser.queryVO = e.queryVO;
			view.valid = false;
		}

		private function queryValidHandler( e:ValidateQueryEvent ):void
		{
			parser.queryVO = e.queryVO;
			view.valid = true;
		}
		
		private function setQueryFromTableInfoHandler( e:TableInfoEvent ):void
		{
			view.text = parser.setQueryFromXML( e.data );
		}
		
	}
}