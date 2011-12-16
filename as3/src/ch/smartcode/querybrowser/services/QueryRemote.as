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
	
	import ch.smartcode.querybrowser.config.QueryRemoteConfig;
	import ch.smartcode.querybrowser.datastructures.PagedList;
	import ch.smartcode.querybrowser.events.KillQueryEvent;
	import ch.smartcode.querybrowser.events.QueryErrorEvent;
	import ch.smartcode.querybrowser.events.QueryRemoteEvent;
	import ch.smartcode.querybrowser.events.QueryResultEvent;
	import ch.smartcode.querybrowser.events.TableInfoEvent;
	import ch.smartcode.querybrowser.models.QueryBrowserModel;
	import ch.smartcode.querybrowser.vo.ErrorVO;
	import ch.smartcode.querybrowser.vo.QueryVO;
	import ch.smartcode.querybrowser.vo.ResultVO;
	
	import flash.net.registerClassAlias;
	
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import org.robotlegs.mvcs.Actor;
	
	public class QueryRemote extends Actor
	{
		
		[Inject]
		public var parser:QueryParser;
		
		[Inject]
		public var model:QueryBrowserModel;
		
		private var _remoteObject:RemoteObject;
		private var _query:String;
		
		private var _resultVo:ResultVO;
		private var _pagedResultsList:PagedList;
		private var _pagingIdx:uint = 0;
		private var _resultsLength:uint = 0;
		private var _offset:uint;
		
		/**
		 * When a query has been killed, we receive errors from the pending remote calls.
		 * With this helper variable we suppress the display of these errors.
		 */
		private var _killing:Boolean;
		
		public function QueryRemote():void
		{
			super();
			_remoteObject = new RemoteObject();
			_remoteObject.destination = QueryRemoteConfig.DESTINATION;
			_remoteObject.source = QueryRemoteConfig.SOURCE;
			_remoteObject.showBusyCursor = false;
			_remoteObject.addEventListener( FaultEvent.FAULT, faultHandler );
			
			registerRemoteAliases();
			
		}
		
		/* QUERY */
		
		// simple query or complex query
		public function executeQuery():void
		{
			dispatch( new QueryRemoteEvent( QueryRemoteEvent.LOADING) );
			_remoteObject.showBusyCursor = false;
			_pagingIdx = 0;
			_offset = 0;
			_resultsLength = 0;
			
			if( parser.queryVO.type == QueryVO.SIMPLE ) {
				executeSimpleQuery();
			} else {
				executeComplexQuery();
			}
			
			
		}
		
		// Simple queries
		private function executeSimpleQuery( ):void
		{
			var asyncToken:AsyncToken = _remoteObject.executeSimpleQuery( parser.queryVO.query, _pagingIdx,  QueryRemoteConfig.DATA_PAGE_SIZE, true  );
			asyncToken.addResponder( new AsyncResponder(executeSimpleQueryResultHandler, faultHandler, _pagingIdx) );
		}
		
		private function executeSimpleQueryResultHandler( e:ResultEvent, token:Object = null ):void
		{	
			queryResultHandler( e,loadSimpleQueryItems,token );
		}
		
		private function loadSimpleQueryItems(list:IList, start:uint, count:uint):void
		{
			_remoteObject.showBusyCursor = true;
			_pagingIdx = start;
			
			var asyncToken:AsyncToken = _remoteObject.executeSimpleQuery( parser.queryVO.query,_pagingIdx, count, false );
			asyncToken.addResponder( new AsyncResponder(loadItemsResultHandler, faultHandler, _pagingIdx) );
		}
		
		// Complex queries
		private function executeComplexQuery( ):void
		{
			var asyncToken:AsyncToken = _remoteObject.executeComplexQuery( parser.queryVO.query, _pagingIdx,  QueryRemoteConfig.DATA_PAGE_SIZE, true  );
			asyncToken.addResponder( new AsyncResponder(executeComplexQueryResultHandler, faultHandler, _pagingIdx) );
		}
		
		private function executeComplexQueryResultHandler( e:ResultEvent, token:Object = null ):void
		{	
			queryResultHandler( e,loadComplexQueryItems,token );
			
		}
		
		private function loadComplexQueryItems(list:IList, start:uint, count:uint):void
		{
			_remoteObject.showBusyCursor = true;
			_pagingIdx = start;
			var asyncToken:AsyncToken = _remoteObject.executeComplexQuery( parser.queryVO.query,_pagingIdx + _offset, count, false );
			asyncToken.addResponder( new AsyncResponder(loadItemsResultHandler, faultHandler, _pagingIdx) );
		}
		
		/**
		 * Result handler for both query types
		 */
		private function queryResultHandler( e:ResultEvent, itemsLoadFunction:Function, token:Object = null ):void
		{
			dispatch( new QueryRemoteEvent( QueryRemoteEvent.LOADED) );
			
			if( e.result is ErrorVO ) {
				
				dispatch( new QueryErrorEvent( QueryErrorEvent.ERROR_RECEIVED, ErrorVO(e.result) ) );
				
			} else {
				
				_resultVo = ResultVO( e.result );
				
				_offset = _resultVo.offset;
				_pagedResultsList = new PagedList( _resultVo.datasets, QueryRemoteConfig.DATA_PAGE_SIZE );
				_pagedResultsList.loadItemsFunction = itemsLoadFunction;
				
				model.addQuery( parser.queryVO );
				
				storeItems( _resultVo.results, token as int );
				
				dispatch( new QueryResultEvent( QueryResultEvent.RESULTS_RECEIVED, _pagedResultsList, _resultVo.fields, true) );
			}
		}
		
		/**
		 * Paging data load result handler
		 */
		private function loadItemsResultHandler( e:ResultEvent, token:Object = null ):void
		{
			dispatch( new QueryRemoteEvent( QueryRemoteEvent.LOADED) );
			
			if( e.result is ErrorVO ) {
				dispatch( new QueryErrorEvent(QueryErrorEvent.ERROR_RECEIVED, ErrorVO(e.result) ) );
				//Alert.show( ErrorVO(e.result).message, 'Error');
			} else {
				_resultVo = ResultVO( e.result );
				storeItems( _resultVo.results, token as int );
				dispatch( new QueryResultEvent( QueryResultEvent.RESULTS_RECEIVED, _pagedResultsList, _resultVo.fields, false) );
			}
		}
		
		/**
		 * store items in the pagedList
		 */
		private function storeItems( items:Array, token:int ):void
		{
			
			//trace("items => " + items.length + " token => " + token + " results length => " + _resultsLength);
			var v:Vector.<Object> = new Vector.<Object>();
			for each (var i:Object in items)
			{
				v.push(i);
			}
			_pagedResultsList.storeItemsAt(v, token);	
			_resultsLength += items.length;
		}
		
		/**
		 * KILL QUERY 
		 * 
		 * I couldn't find a clean implementation.
		 * 
		 * This one works but leads to a segmentation fault on the php side. So this is not very nice.
		 * 
		 * */
		public function killQuery():void
		{
			_killing = true;
			// remove all pending request responders
			_remoteObject.disconnect();
			
			var asyncToken:AsyncToken = _remoteObject.killQuery( parser.queryVO );
			asyncToken.addResponder( new AsyncResponder( killQueryResultHandler, faultHandler ) );
		}
		
		private function killQueryResultHandler( e:ResultEvent, token:Object = null ):void
		{
			_killing = false;
			dispatch( new KillQueryEvent( KillQueryEvent.QUERY_KILLED) );
			
			if( !Boolean(e.result) ) {
				Alert.show("Something went wrong - query could not be killed", 'Error');
			} else {
				Alert.show("Query Killed", 'Success');
			}
			
		}
		
		
		/* TABLE INFO */
		public function getTableInfo():void
		{
			_remoteObject.getTableInfo.addEventListener( ResultEvent.RESULT, getTableInfoResultHandler );
			_remoteObject.getTableInfo();
		}
		
		private function getTableInfoResultHandler( e:ResultEvent ):void
		{
			dispatch( new TableInfoEvent( TableInfoEvent.TABLE_INFO_LOADED, e.result as XML) );
			_remoteObject.getTableInfo.removeEventListener( ResultEvent.RESULT, getTableInfoResultHandler );
		}
		
		/* HANDLERS */
		
		private function faultHandler(e:FaultEvent, token:Object = null):void
		{
			if( !_killing ) {
				Alert.show("Error Code: " + e.fault.faultCode + "\nError String: " + e.fault.faultString + "\nError Detail: " + e.fault.faultDetail + "\nError ID: " + e.fault.errorID, 'Error');
			}
			
			dispatch( new QueryRemoteEvent( QueryRemoteEvent.ERROR) );
			
		}
		
		private function registerRemoteAliases():void
		{
			registerClassAlias( "vo.ResultVO", ResultVO )
			registerClassAlias( "vo.ErrorVO", ErrorVO );
		}
		
		
	}
}