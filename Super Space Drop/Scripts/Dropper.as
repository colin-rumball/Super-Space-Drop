package Scripts {
	
	import flash.display.MovieClip;
	
	public class Dropper extends MovieClip 
	{
		private var board:Board;
		private var movable:Boolean;
		private static var droppable:Boolean;
		private var ghostQuad:Array;
		
		public function Dropper(_board:Board) 
		{
			board = _board;
			movable = true;
			droppable = true;
			ghostQuad = new Array();
			ghostQuad.push(new Block(0, 320+27, 1));
			ghostQuad.push(new Block(40, 320+27, 2));
			ghostQuad.push(new Block(0, 360+27, 2));
			ghostQuad.push(new Block(40, 360+27, 1));
			(ghostQuad[0] as Block).alpha = 0.3;
			(ghostQuad[1] as Block).alpha = 0.3;
			(ghostQuad[2] as Block).alpha = 0.3;
			(ghostQuad[3] as Block).alpha = 0.3;
			this.addChild(ghostQuad[0]);
			this.addChild(ghostQuad[1]);
			this.addChild(ghostQuad[2]);
			this.addChild(ghostQuad[3]);
			this.x = 200;
			this.y = 2;
		}
		
		public function canDropNextSet():Boolean
		{
			//trace("canDropNextSet");
			return droppable;
		}
		
		public function dropNextSetWithoutFail(_nextBlockSet:Array, _level:Level):Boolean
		{
			//trace("dropNextSet");
			var index = 0;
			for (var i = 0; i < 2; i++)
			{
				for (var j = 0; j < 2; j++)
				{
					var c1:Cell = board.getCell(((this.x-200)/40)+j, i);
					var b1:Block = new Block(this.x+(j*40), this.y+27+(i*40), (_nextBlockSet[index] as Block).getType());
					_level.GameArea.addChild(b1);
					if (c1 != null)
					{
						if (c1.isEmpty())
						{
							c1.assignBlock(b1);
						} else
						{
							return false;
						}
					}
					index++;
				}
			}
			return true;
		}
		
		public function updateGhostPosition():void
		{
			//trace("updateGhostPositions");
			var leftCell:Cell = board.getLowestEmptyCellBelow(board.getCell(((this.x-200)/40), 0));
			(ghostQuad[0] as Block).y = leftCell.getY()-150+108;
			(ghostQuad[2] as Block).y = leftCell.getY()-110+108;
			var rightCell:Cell = board.getLowestEmptyCellBelow(board.getCell(((this.x-200)/40)+1, 0));
			(ghostQuad[1] as Block).y = rightCell.getY()-150+108;
			(ghostQuad[3] as Block).y = rightCell.getY()-110+108;
			//trace("updateGhostPositions-END");
		}
		
		public function updateGhostTypes(_nextQuad:Array):void
		{
			//trace("updateGhostTypes");
			(ghostQuad[0] as Block).setType((_nextQuad[0] as Block).getType());
			(ghostQuad[2] as Block).setType((_nextQuad[2] as Block).getType());
			(ghostQuad[3] as Block).setType((_nextQuad[3] as Block).getType());
			(ghostQuad[1] as Block).setType((_nextQuad[1] as Block).getType());
			//trace("updateGhostTypes-END");
		}
		
		public function hideGhost():void
		{
			(ghostQuad[0] as Block).visible = false;
			(ghostQuad[1] as Block).visible = false;
			(ghostQuad[2] as Block).visible = false;
			(ghostQuad[3] as Block).visible = false;
		}
		
		public function showGhost():void
		{
			(ghostQuad[0] as Block).visible = true;
			(ghostQuad[1] as Block).visible = true;
			(ghostQuad[2] as Block).visible = true;
			(ghostQuad[3] as Block).visible = true;
		}
		
		public function moveRight():void
		{
			if (this.isMoveable() && this.x < 680)
			{
				this.x += 40;
				updateGhostPosition();
			}
		}
		
		public function moveLeft():void
		{
			if (this.isMoveable() && this.x > 200)
			{
				this.x -= 40;
				updateGhostPosition();
			}
		}
		
		public function isMoveable():Boolean
		{
			return movable;
		}
		
		public function makeImmovable():void
		{
			movable = false;
		}
		
		public function makeMovable():void
		{
			movable = true;
		}
		
		public function enableDrops():void
		{
			//trace("enableDrops");
			droppable = true;
		}
		
		public function disableDrops():void
		{
			//trace("disableDrops");
			droppable = false;
		}
	}
	
}
