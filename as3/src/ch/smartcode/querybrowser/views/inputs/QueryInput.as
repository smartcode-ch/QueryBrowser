package ch.smartcode.querybrowser.views.inputs
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
	import ch.smartcode.querybrowser.skins.inputs.QueryInputSkin;
	import ch.smartcode.querybrowser.vo.QueryVO;
	
	import mx.events.FlexEvent;
	
	import spark.components.RichEditableText;
	import spark.components.TextArea;
	import spark.events.TextOperationEvent;
	
	public class QueryInput extends TextArea
	{
		
		private var _queryVO:QueryVO;
		
		public function QueryInput()
		{
			super();
			focusEnabled = false;
			setStyle( "skinClass", QueryInputSkin );
			setStyle( "verticalAlign", "middle" );
			styleName = "queryInput";
			
			prompt = QueryInputConfig.QUERY_INPUT_PROMPT;
			
			_queryVO = new QueryVO();
			_queryVO.type = QueryVO.COMPLEX;
			
			addEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandeler );
			addEventListener( TextOperationEvent.CHANGE, textChangeHandler );
		}
		
		override public function set text( value:String ):void
		{
			super.text = value;
			textChangeHandler();
		}

		private function textChangeHandler( e:TextOperationEvent = null):void
		{
			_queryVO.query = this.text;
			dispatchEvent( new ValidateQueryEvent(ValidateQueryEvent.VALIDATE_QUERY, _queryVO) );
		}
		
		public function set valid( value:Boolean ):void
		{
			if( value ) {
				setStyle( "color", 0x5684DA );
			} else {
				setStyle( "color", 0xDF7F48 );
			}
		}
		
		private function updateCompleteHandeler(e:FlexEvent):void
		{
			var updatedHeight:Number = RichEditableText(textDisplay).contentHeight;
			if( updatedHeight > this.minHeight ) {
				this.height = updatedHeight;
			} else {
				this.height = this.minHeight;
			}
			
		}
	}
}