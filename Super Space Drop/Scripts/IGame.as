package Scripts 
{
	import flash.events.*;
	
	public interface IGame extends IEventDispatcher 
	{		
		function gotoState(type:String);
		
		function gameload(e:Event);
		
		function gamemenu(e:Event);
		
		function gamewaiting(e:Event);
		
		function gameplay(e:Event);
		
		function gamestatus(e:Event);
		
		function gamepause(e:Event);
		
		function gamelose(e:Event);
	}	
}
