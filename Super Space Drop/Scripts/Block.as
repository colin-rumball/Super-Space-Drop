package Scripts {
	
	import flash.display.MovieClip;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.media.Video;
	
	public class Block extends MovieClip 
	{
		private var type:int;
		public static const FOOD:int = 1;
		public static const FUEL:int = 2;
		public static const OXYGEN:int = 3;
		public static const ELECTRICITY:int = 4;
		public static const ARMOUR:int = 5;
		
		private var inPlace:Boolean = true;
		private var flagged:Boolean = false;
		private var scoring:Boolean = false;
		
		private var containingCell:Cell;
		
		private var removalTween:Tween;
		private var blockTween:Tween
		
		public function Block(_x:int, _y:int, _type:int) 
		{
			this.x = _x;
			this.y = _y;
			this.type = _type;
			this.gotoAndStop(_type);
		}
		
		public function move(endY:int):void
		{
			inPlace = false;
			blockTween = new Tween(this, "y", None.easeNone, this.y, endY, (endY-this.y)/20, false);
			blockTween.addEventListener(TweenEvent.MOTION_FINISH, tweenFinished);
		}
		
		public function pause():void
		{
			if (removalTween != null)
			{
				removalTween.stop();
			} else if (blockTween != null)
			{
				blockTween.stop();
			}
			for (var i = 0; i < this.numChildren; i++)
			{
				if (this.getChildAt(i) is MovieClip)
				{
					(this.getChildAt(i) as MovieClip).stop();
				}
			}
		}
		
		public function resume():void
		{
			if (removalTween != null)
			{
				removalTween.resume();
			} else if (blockTween != null)
			{
				blockTween.resume();
			}
			for (var i = 0; i < this.numChildren; i++)
			{
				if (this.getChildAt(i) is MovieClip)
				{
					(this.getChildAt(i) as MovieClip).play();
				}
			}
		}
		
		public function fullyScoreBlock(_cell:Cell, _scoreManager:ScoreManager, _resourceManager:ResourceManager):void
		{
			//trace("fullyScoreBlock");
			this.gotoAndStop(type+5);
			scoring = true;
			_scoreManager.addToScore(100);
			_resourceManager.addToResource(this.getType()-1, 2);
			containingCell = _cell;
			removalTween = new Tween(this, "y", None.easeNone, this.y, this.y, 28, false);
			removalTween.addEventListener(TweenEvent.MOTION_FINISH, this.animationDone);
		}
		
		public function halfScoreBlock(cell:Cell, _scoreManager:ScoreManager, _resourceManager:ResourceManager):void
		{
			//trace("halfScoreBlock");
			this.gotoAndStop(type+5);
			scoring = true;
			_scoreManager.addToScore(50);
			_resourceManager.addToResource(this.getType()-1, 1);
			containingCell = cell;
			removalTween = new Tween(this, "y", None.easeNone, this.y, this.y, 28, false);
			removalTween.addEventListener(TweenEvent.MOTION_FINISH, this.animationDone);
		}
		
		public function animationDone(e:TweenEvent):void
		{
			//trace("animationDone");
			removalTween = null;
			removeBlock();
		}
		
		public function removeBlock():void
		{
			//trace("removeBlock");
			if (this.parent != null)
			{
				this.parent.removeChild(this);
			} else
			{
				trace("error");
			}
			if (containingCell != null)
			{
				containingCell.assignBlock(null);
			}
		}
		
		public function flagForScoring():void
		{
			flagged = true;
		}
		
		public function isFlaggedForScoring():Boolean
		{
			return flagged;
		}
		
		private function tweenFinished(e:TweenEvent):void
		{
			blockTween = null;
			inPlace = true;
		}
		
		public function setType(_type:int):void
		{
			type = _type;
			this.gotoAndStop(_type);
		}
		
		public function getType():int
		{
			return type;
		}
		
		public function isInPlace():Boolean
		{
			return inPlace;
		}
		
		public function isScoring():Boolean
		{
			return scoring;
		}
	}
	
}
