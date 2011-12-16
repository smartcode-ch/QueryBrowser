package ch.smartcode.querybrowser.views.buttons
{
	import ch.smartcode.querybrowser.skins.buttons.IconButtonSkin;
	
	import spark.components.Button;
	
	//icons
	[Style(name="iconUp",type="*")]
	[Style(name="iconOver",type="*")]
	[Style(name="iconDown",type="*")]
	[Style(name="iconDisabled",type="*")]
	
	[Style(name="iconWidth",type="Number")]
	[Style(name="iconHeight",type="Number")]
	
	//paddings
	[Style(name="paddingLeft",type="Number")]
	[Style(name="paddingRight",type="Number")]
	[Style(name="paddingTop",type="Number")]
	[Style(name="paddingBottom",type="Number")]
	
	public class IconButton extends Button
	{
		public function IconButton()
		{
			super();
			setStyle("skinClass", IconButtonSkin);
		}
	}
	
}