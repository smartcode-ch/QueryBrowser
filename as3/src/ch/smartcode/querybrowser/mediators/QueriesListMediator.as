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
	import ch.smartcode.querybrowser.events.QueryBrowserModelEvent;
	import ch.smartcode.querybrowser.models.QueryBrowserModel;
	import ch.smartcode.querybrowser.services.QueryParser;
	import ch.smartcode.querybrowser.views.QueriesListView;
	
	import mx.events.CollectionEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class QueriesListMediator extends Mediator
	{
		[Inject]
		public var view:QueriesListView;
		
		[Inject]
		public var model:QueryBrowserModel;
		
		override public function onRegister():void
		{
			addViewListener( QueriesListEvent.SET_QUERY_FROM_LIST, setQueryHandler, QueriesListEvent );
			
			view.dataProvider = model.queries;
		}
		
		private function setQueryHandler( e:QueriesListEvent ):void
		{
			dispatch( e );
		}
		
	}
}