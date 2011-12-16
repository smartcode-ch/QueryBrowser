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
	import ch.smartcode.querybrowser.events.QueryBrowserModelEvent;
	import ch.smartcode.querybrowser.events.QueryErrorEvent;
	import ch.smartcode.querybrowser.events.QueryRemoteEvent;
	import ch.smartcode.querybrowser.events.QueryResultEvent;
	import ch.smartcode.querybrowser.events.ValidateQueryEvent;
	import ch.smartcode.querybrowser.models.QueryBrowserModel;
	import ch.smartcode.querybrowser.views.buttons.QueriesListButton;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class QueriesListButtonMediator extends Mediator
	{
		[Inject]
		public var view:QueriesListButton;
		
		[Inject]
		public var model:QueryBrowserModel;
		
		override public function onRegister():void
		{
			addContextListener( QueryBrowserModelEvent.QUERIES_CHANGED, queriesChangedHandler, QueryBrowserModelEvent );
			
			addContextListener( KillQueryEvent.QUERY_KILLED, setEnabled, KillQueryEvent)
			addContextListener( QueryRemoteEvent.LOADING, setDisabled, QueryRemoteEvent );
			addContextListener( QueryRemoteEvent.LOADED, setEnabled, QueryRemoteEvent );
			addContextListener( QueryRemoteEvent.ERROR, setEnabled, QueryRemoteEvent );
			
		}
		
		private function setDisabled( e:Event ):void
		{
			view.enabled = false;
			
		}
		
		private function setEnabled( e:Event ):void
		{
			view.enabled = true;
			
		}		
		
		private function queriesChangedHandler( e:QueryBrowserModelEvent ):void
		{
			view.enabled = model.queries.length > 0;
		}
		
	}
}