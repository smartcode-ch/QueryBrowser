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
	
	import ch.smartcode.querybrowser.events.QueryEvent;
	import ch.smartcode.querybrowser.events.ValidateQueryEvent;
	import ch.smartcode.querybrowser.models.QueryBrowserModel;
	import ch.smartcode.querybrowser.services.QueryRemote;
	import ch.smartcode.querybrowser.views.buttons.RunQueryButton;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class RunQueryButtonMediator extends Mediator
	{
		[Inject]
		public var service:QueryRemote;
		
		[Inject]
		public var view:RunQueryButton;
		
		[Inject]
		public var model:QueryBrowserModel;
		
		override public function onRegister():void
		{
			addContextListener( ValidateQueryEvent.QUERY_INVALID, queryInvalidHandler, ValidateQueryEvent );
			addContextListener( ValidateQueryEvent.QUERY_VALID, queryValidHandler, ValidateQueryEvent );
			addViewListener( QueryEvent.EXECUTE_QUERY, executeQueryHandler, QueryEvent );
			
			view.enabled = false;
		}

		private function queryValidHandler( e:ValidateQueryEvent ):void
		{
			view.enabled = true;
		}

		private function queryInvalidHandler( e:ValidateQueryEvent ):void
		{
			view.enabled = false;
		}

		private function executeQueryHandler( e:QueryEvent ):void
		{
			service.executeQuery();
		}
		
	}
}