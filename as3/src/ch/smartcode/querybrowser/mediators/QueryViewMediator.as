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
	
	import ch.smartcode.querybrowser.events.KillQueryEvent;
	import ch.smartcode.querybrowser.events.QueriesListEvent;
	import ch.smartcode.querybrowser.events.QueryErrorEvent;
	import ch.smartcode.querybrowser.events.ValidateQueryEvent;
	import ch.smartcode.querybrowser.events.QueryRemoteEvent;
	import ch.smartcode.querybrowser.events.QueryResultEvent;
	import ch.smartcode.querybrowser.models.QueryBrowserModel;
	import ch.smartcode.querybrowser.services.QueryRemote;
	import ch.smartcode.querybrowser.views.QueryView;
	
	import mx.collections.AsyncListView;
	import mx.collections.errors.ItemPendingError;
	import mx.events.CollectionEventKind;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class QueryViewMediator extends Mediator
	{
		
		[Inject]
		public var view:QueryView;
		
		[Inject]
		public var service:QueryRemote;
		
		[Inject]
		public var model:QueryBrowserModel;
		
		[Bindable]
		public var results:AsyncListView;
		
		override public function onRegister():void
		{
			addContextListener( QueryResultEvent.RESULTS_RECEIVED, resultHandler, QueryResultEvent );
			addContextListener( QueryErrorEvent.ERROR_RECEIVED, errorHandler, QueryErrorEvent );
			
			addContextListener( ValidateQueryEvent.QUERY_VALID, queryValidHandler, ValidateQueryEvent );
			addContextListener( ValidateQueryEvent.QUERY_INVALID, queryInvalidHandler, ValidateQueryEvent );
			
			addContextListener( QueryRemoteEvent.LOADING, dataLoadingHandler, QueryRemoteEvent );
			addContextListener( QueryRemoteEvent.LOADED, dataLoadedHandler, QueryRemoteEvent );
			addContextListener( QueryRemoteEvent.ERROR, dataLoadErrorHandler, QueryRemoteEvent );
			
			addContextListener( QueriesListEvent.SET_QUERY_FROM_LIST, setQueryHandler, QueriesListEvent );
			
			addViewListener( KillQueryEvent.KILL_QUERY, killQueryHandler, KillQueryEvent );				
			addViewListener( KillQueryEvent.QUERY_KILLED, queryKilledHandler, KillQueryEvent );
			
		}

		private function setQueryHandler( e:QueriesListEvent ):void
		{
			view.currentState = "normal";
		}

		private function killQueryHandler( e:KillQueryEvent ):void
		{

			service.killQuery();
			view.currentState = "killQuery";
		}

		private function queryKilledHandler( e:KillQueryEvent ):void
		{
			view.currentState = "normal";
		}

		private function dataLoadedHandler( e:QueryRemoteEvent ):void
		{
			view.currentState = "normal";	
		}
		
		private function dataLoadErrorHandler( e:QueryRemoteEvent ):void
		{
			view.currentState = "normal";	
		}

		private function dataLoadingHandler(  e:QueryRemoteEvent ):void
		{
			view.currentState = "loading";
		}

		private function queryInvalidHandler( e:ValidateQueryEvent ):void
		{
			view.currentState = 'invalid';	
		}

		private function queryValidHandler( e:ValidateQueryEvent ):void
		{
			view.currentState = 'normal';
		}

		private function resultHandler( e:QueryResultEvent ):void
		{
			view.currentState = 'results';
			
			if( e.newQuery ) {
				// columns 
				view.resultsGrid.gridColumnsFromFieldNames = e.fields;
				
				results = new AsyncListView();
				results.createPendingItemFunction = handleCreatePendingItemFunction;
				results.list = e.results;
				view.resultsGrid.scroller.verticalScrollBar.value = 0;
				
			} else {
				results.list = e.results;
			}
			
			
			view.resultsGrid.dataProvider = results;
			
			
		}
		
		private function errorHandler( e:QueryErrorEvent ):void
		{
			view.currentState = 'error';
			view.errorText.text = e.error.message;
		}
		
		private function handleCreatePendingItemFunction(index:int, ipe:ItemPendingError):Object {
			return {};
		}

	}
}