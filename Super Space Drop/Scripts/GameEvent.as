package Scripts
{
	import flash.events.*;
	
	public class GameEvent extends Event
	{
		public static const GAME_LOAD:String = "gameload";
		public static const GAME_MENU:String = "gamemenu";
		public static const GAME_WAITING:String = "gamewaiting";
		public static const GAME_PLAY:String = "gameplay";
		public static const GAME_STATUS:String = "gamestatus";
		public static const GAME_PAUSE:String = "gamepause";
		public static const GAME_LOSE:String = "gamelose";
		
		public function GameEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}