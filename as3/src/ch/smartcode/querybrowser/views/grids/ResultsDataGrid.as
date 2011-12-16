package ch.smartcode.querybrowser.views.grids
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
	
	import ch.smartcode.querybrowser.skins.ResultsDataGridGridSkin;
	
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	import mx.collections.AsyncListView;
	
	import spark.components.DataGrid;
	import spark.components.gridClasses.GridColumn;
	
	public class ResultsDataGrid extends DataGrid
	{
		import mx.collections.ArrayCollection;
		import mx.collections.ListCollectionView;
		import mx.controls.dataGridClasses.DataGridColumn;
		import mx.events.CollectionEvent;
		
		
		public var scrollHeight:Number = 500;
		private var _asyncListView:AsyncListView;
		private var _dataSource:AsyncListView;
		
		public function ResultsDataGrid()
		{
			super();
			//setStyle("skinClass", ResultsDataGridGridSkin);
		}

		public function set gridColumnsFromFieldNames( fields:Array ):void
		{
			var gridColumns:Array = [];
			
			for each( var field:String in fields ) {
				var gridColumn:GridColumn = new GridColumn( field );
				gridColumn.dataField = field;
				gridColumns.push( gridColumn );
			}
			
			this.columns = new ArrayList(gridColumns);
		}

	}
}