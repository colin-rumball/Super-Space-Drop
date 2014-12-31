package Scripts {
	
	import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.events.*;
	
	public class HowToScreen extends MovieClip {

		private var timeAtLastDrop:int;
		private var dropDelay:int;
		
		
		public function HowToScreen() 
		{
			timeAtLastDrop = 0;
			dropDelay = Math.floor((Math.random()*800)+50);
		}
		
		public function update(e:Event)
		{
			if (timeAtLastDrop + dropDelay < getTimer())
			{
				timeAtLastDrop = getTimer();
				dropDelay = Math.floor((Math.random()*800)+50);
				var block:Block = new Block(Math.floor((Math.random()*959)+1), -40, Math.floor((Math.random()*5)+1))
				this.addChildAt(block, 0);
				block.move(540);
			}
		}
		
		public function backPage()
		{
			if (this.currentFrame > 1)
				this.gotoAndStop(this.currentFrame-1);
		}
		
		public function forwardPage()
		{
			if (this.currentFrame < 4)
				this.gotoAndStop(this.currentFrame+1);
		}
	}
	
}
