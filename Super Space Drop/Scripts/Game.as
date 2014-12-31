package Scripts
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Game extends MovieClip
	{
		private var states:Array;
		
		public var currentState:String;
		public var previousState:String;
		
		public function Game(...args)
		{
			states = args;
			currentState = null;
			previousState = null;
			for each(var event:Object in states)
			{
				addEventListener(event.type, event.callback);
			}
		}
		
		public function removeAllStates()
		{
			currentState = null;
			previousState = null;
			for each(var event:Object in states)
			{
				removeEventListener(event.type, event.callback);
			}
		}
		
		public function gotoState(_state:String)
		{
			trace("gotoState " + _state);
			previousState = currentState;
			currentState = _state;
			
			dispatchEvent(new GameEvent(_state));
		}
	}
}