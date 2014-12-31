package Scripts {
	import flash.utils.getTimer;
	import Scripts.CustomTimer;
	
	public class TimerManager 
	{
		private var timers:Array;
		public function TimerManager() 
		{
			timers = new Array();
		}

		public function addNewTimer(_interval:int, _callback:Function, _name:String):void
		{
			timers.push(new CustomTimer(_interval, _callback, _name));
		}
		
		public function checkTimersForFinished():void
		{
			for each(var timer:CustomTimer in timers)
			{
				if (timer.isRunning())
				{
					if (timer.isFinished())
					{
						timer.reset();
						timer.getCallback()();
					}
				} else
				{
					timer.reset();
				}
			}
		}
		
		public function addTimeToAllTimers(_amt:int):void
		{
			for each(var timer:CustomTimer in timers)
			{
				timer.addTime(_amt);
			}
		}
		
		public function pauseAllTimers():void
		{
			for each(var timer:CustomTimer in timers)
			{
				if (timer.isRunning())
				{
					timer.pause();
				}
			}
		}
		
		public function resumeAllTimers():void
		{
			for each(var timer:CustomTimer in timers)
			{
				if (timer.isPaused())
				{
					timer.resume();
				}
			}
		}
		
		public function resetAllTimers():void
		{
			for each(var timer:CustomTimer in timers)
			{
				timer.reset();
			}
		}
		
		public function restartAllTimers():void
		{
			for each(var timer:CustomTimer in timers)
			{
				timer.restart();
			}
		}
		
		public function getTimerByName(_name:String):CustomTimer
		{
			for each(var timer:CustomTimer in timers)
			{
				if (timer.getName() == _name)
				{
					return timer;
				}
			}
			return null;
		}
	}
	
}
