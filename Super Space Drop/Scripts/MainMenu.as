package Scripts {
	
	import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.events.*;
	
	public class MainMenu extends MovieClip {
		
		private var timeAtLastDrop:int;
		private var dropDelay:int;
		
		public function MainMenu() 
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
	}
	
}
