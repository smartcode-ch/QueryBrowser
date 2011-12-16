package ch.smartcode.querybrowser.views.spinner {
	
	/**
	 * Created by Jake Hawkes http://grakl.com/wordpress/?p=5
	 */
	
	import flash.display.Sprite;
	
	import spark.effects.Fade;
	
	public class Tick extends Sprite {
		private var tickFade:Fade = new Fade(this);
		
			
		public function Tick(fromX:Number, fromY:Number, toX:Number, toY:Number, tickWidth:int, tickColor:uint) {
			this.graphics.lineStyle(tickWidth, tickColor, 1.0, false, "normal", "rounded");
			this.graphics.moveTo(fromX, fromY);
			this.graphics.lineTo(toX, toY);
		}
		
		public function fade(duration:Number):void {
			tickFade.alphaFrom = 1.0;
			tickFade.alphaTo = 0.1;
			tickFade.duration = duration;
			tickFade.play();
		}
	}
}