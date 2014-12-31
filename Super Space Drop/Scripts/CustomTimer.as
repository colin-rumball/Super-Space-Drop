package Scripts {
	import flash.utils.getTimer;
	public class CustomTimer 
	{
		private var interval:int;
		private var timeAtStart:int;
		private var timeAtPause:int;
		private var callback:Function;
		private var name:String;
		private var running:Boolean;
		private var paused:Boolean;
		
		public function CustomTimer(_interval:int, _callback:Function, _name:String):void
		{
			this.interval = _interval;
			this.callback = _callback;
			this.name = _name;
			this.running = false;
			this.paused = false;
		}
		
		public function pause():void
		{
			timeAtPause = getTimer();
			this.paused = true;
		}
		
		public function resume():void
		{
			this.timeAtStart += getTimer()-timeAtPause;
			this.running = true;
			this.paused = false;
		}
		
		public function addTime(_amt:int)
		{
			this.timeAtStart += _amt;
		}
		
		public function reset():void
		{
			this.timeAtStart = getTimer();
			this.running = false;
			this.paused = false;
		}
		
		public function restart():void
		{
			this.timeAtStart = getTimer();
			this.running = true;
			this.paused = false;
		}
		
		public function getCallback():Function
		{
			return callback;
		}
		public function isFinished():Boolean
		{
			return (timeAtStart+interval <= getTimer());
		}
		
		public function getTimeLeft():int
		{
			return interval - (getTimer() - this.timeAtStart);
		}
		
		public function getName():String
		{
			return this.name;
		}
		
		public function isRunning():Boolean
		{
			return this.running;
		}
		
		public function isPaused():Boolean
		{
			return this.paused;
		}
	}
	
}
