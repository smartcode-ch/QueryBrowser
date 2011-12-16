package ch.smartcode.querybrowser.context
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
	
	import ch.smartcode.querybrowser.mediators.QueriesListButtonMediator;
	import ch.smartcode.querybrowser.mediators.QueriesListMediator;
	import ch.smartcode.querybrowser.mediators.QueryInputMediator;
	import ch.smartcode.querybrowser.mediators.QueryViewMediator;
	import ch.smartcode.querybrowser.mediators.RunQueryButtonMediator;
	import ch.smartcode.querybrowser.mediators.TableInfoMediator;
	import ch.smartcode.querybrowser.models.QueryBrowserModel;
	import ch.smartcode.querybrowser.services.QueryParser;
	import ch.smartcode.querybrowser.services.QueryRemote;
	import ch.smartcode.querybrowser.views.QueriesListView;
	import ch.smartcode.querybrowser.views.QueryView;
	import ch.smartcode.querybrowser.views.TableInfoView;
	import ch.smartcode.querybrowser.views.buttons.QueriesListButton;
	import ch.smartcode.querybrowser.views.buttons.RunQueryButton;
	import ch.smartcode.querybrowser.views.inputs.QueryInput;
	
	import org.robotlegs.mvcs.Context;
	
	public class ApplicationContext extends Context
	{
		
		override public function startup():void
		{
			// MEDIATORS
			mediatorMap.mapView( TableInfoView, TableInfoMediator );
			mediatorMap.mapView( QueryInput, QueryInputMediator );
			mediatorMap.mapView( RunQueryButton, RunQueryButtonMediator );
			mediatorMap.mapView( QueryView, QueryViewMediator );
			mediatorMap.mapView( QueriesListView, QueriesListMediator );
			mediatorMap.mapView( QueriesListButton, QueriesListButtonMediator);
			
			// MODELS
			injector.mapSingleton( QueryBrowserModel );
			
			// SERVICES
			injector.mapSingleton( QueryRemote );
			injector.mapSingleton( QueryParser );
		}
	}
}