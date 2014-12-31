package Scripts 
{
	import Scripts.Cell;
	import Scripts.Block;
	import Scripts.ScoreManager;
	import flash.utils.getTimer;
	import flash.media.Sound;
	
	public class Board 
	{
		private var nbCols:int = 14;
		private var nbRows:int = 10;
		private var cells:Array = new Array();
		private var turnAtLastQuad:int = 0;
		private var scoreSound:Sound;
		
		public function Board():void
		{
			scoreSound = new ScoreSound();
			for (var c = 0; c < nbCols; c++)
			{
				var tempArray:Array = new Array();
				for (var r = 0; r < nbRows; r++)
				{
					tempArray.push(new Cell(this, c, r));
				}
				cells.push(tempArray);
			}
		}
		
		public function runBoardMaintenance(_scoreManager:ScoreManager, _resourceManager:ResourceManager, _currentTurn:int, _gameMuted:Boolean):void
		{
			//trace("runBoardMaintenance");
			checkCellsForDescent();
			checkCellsForQuads(_scoreManager, _resourceManager, _currentTurn, _gameMuted);
			scoreAdjacentCells(_scoreManager, _resourceManager)
			//trace("runBoardMaintenance-END");
		}
		
		private function checkCellsForDescent():void
		{
			//trace("checkCellsForDescent");
			for (var c = nbCols-1; c >= 0; c--)
			{
				for (var r = nbRows-1; r >= 0; r--)
				{
					var cell:Cell = getCell(c,r);
					if (cell != null && !cell.isEmpty())
					{
						var cellBelow:Cell = getLowestEmptyCellBelow(cell);
						if (cellBelow != null && cellBelow != cell)
						{
							cell.passBlockDown(cellBelow);
						}
					}
				}
			}
		}
		
		private function checkCellsForQuads(_scoreManager:ScoreManager, _resourceManager:ResourceManager, _currentTurn:int, _gameMuted:Boolean):void
		{
			//trace("checkCellsForQuads");
			for (var c = 0; c < nbCols-1; c++)
			{
				for (var r = 0; r < nbRows-1; r++)
				{
					if (checkForQuad(c, r))
					{
						if (!_gameMuted)
						{
							scoreSound.play();
						}
						if (this.turnAtLastQuad == _currentTurn > getTimer())
						{
							_scoreManager.addToScore(100);
						}
						this.turnAtLastQuad = _currentTurn;
						scoreQuad(c, r, _scoreManager, _resourceManager);
					}
				}
			}
		}
		
		private function scoreAdjacentCells(_scoreManager:ScoreManager, _resourceManager:ResourceManager):void
		{
			//trace("scoreAdjacentCells");
			for (var c = 0; c < nbCols; c++)
			{
				for (var r = 0; r < nbRows; r++)
				{
					var cell:Cell = getCell(c,r);
					if (cell != null && !cell.isEmpty())
					{
						var cellBlock:Block = cell.getBlock();
						if (cellBlock.isFlaggedForScoring()  && !cellBlock.isScoring())
						{
							cellBlock.halfScoreBlock(cell, _scoreManager, _resourceManager);
							//cell.assignBlock(null);
						}
					}
				}
			}
		}
		
		public function getLowestEmptyCellBelow(_cell:Cell):Cell
		{
			var cellBlock:Block = _cell.getBlock();
			var cellBelow:Cell = _cell.getBottomCell();
			if (cellBelow != null && cellBelow.isEmpty() && (cellBlock == null ||(cellBlock.isInPlace() && !cellBlock.isScoring())))
			{
				var testCell:Cell = cellBelow.getBottomCell();
				while (testCell != null && testCell.isEmpty())
				{
					testCell = cellBelow.getBottomCell();
					if (testCell != null && testCell.isEmpty())
					{
						cellBelow = testCell;
					}
				}
				return cellBelow;
			} else
			{
				return _cell;
			}
		}
		
		public function checkForQuad(c:int, r:int):Boolean
		{
			var topLeftCell:Cell = getCell(c,r);
			if (topLeftCell != null && !topLeftCell.isEmpty())
			{
				var topLeftBlock:Block = topLeftCell.getBlock();
				for (var i = 0; i < 2; i++)
				{
					for (var j = 0; j < 2; j++)
					{
						var testCell:Cell = this.getCell(c+i, r+j);
						if (testCell != null && !testCell.isEmpty())
						{
							var testBlock:Block = testCell.getBlock();
							if (topLeftBlock.getType() == testBlock.getType() && testBlock.isInPlace() && !testBlock.isScoring())
							{
								if (i == 1 && j == 1)
								{
									return true;
								}
							} else
							{
								return false;
							}
						} else
						{
							return false;
						}
					}
				}
			} 
			return false;
		}
		
		public function scoreQuad(c:int, r:int, _scoreManager:ScoreManager, _resourceManager:ResourceManager):void
		{
			for (var i = 0; i < 2; i++)
			{
				for (var j = 0; j < 2; j++)
				{
					var cell:Cell = getCell(c+i, r+j);
					if (cell != null)
					{
						var block:Block = cell.getBlock();
						if (block.isInPlace() && !block.isScoring())
						{
							flagAdjacentBlocksForScoring(cell);
							block.fullyScoreBlock(cell, _scoreManager,_resourceManager);
							//cell.assignBlock(null);
						}
					}
				}
			}
		}
		
		public function flagAdjacentBlocksForScoring(_cell:Cell):void
		{
			if (_cell != null)
			{
				var c:int = _cell.getColumn();
				var r:int = _cell.getRow();
				var block:Block = _cell.getBlock();
				var adjacentBlock:Block;
				
				var cell:Cell = this.getCell(c-1, r);
				if (cell != null)
				{
					adjacentBlock = cell.getBlock();
					if (adjacentBlock != null && adjacentBlock.getType() == block.getType() && adjacentBlock.isInPlace() && !adjacentBlock.isScoring())
					{
						
						adjacentBlock.flagForScoring();
					}
				}
				
				cell = this.getCell(c, r-1);
				if (cell != null)
				{
					adjacentBlock = cell.getBlock();
					if (adjacentBlock != null && adjacentBlock.getType() == block.getType() && adjacentBlock.isInPlace() && !adjacentBlock.isScoring())
					{
						adjacentBlock.flagForScoring();
					}
				}
				
				cell = this.getCell(c+1, r);
				if (cell != null)
				{
					adjacentBlock = cell.getBlock();
					if (adjacentBlock != null && adjacentBlock.getType() == block.getType() && adjacentBlock.isInPlace() && !adjacentBlock.isScoring())
					{
						adjacentBlock.flagForScoring();
					}
				}
				
				cell = this.getCell(c, r+1)
				if (cell != null)
				{
					adjacentBlock = cell.getBlock();
					if (adjacentBlock != null && adjacentBlock.getType() == block.getType() && adjacentBlock.isInPlace() && !adjacentBlock.isScoring())
					{
						adjacentBlock.flagForScoring();
					}
				}
			}
		}
		
		public function allBlocksAsleep():Boolean
		{
			for (var c = 0; c < nbCols; c++)
			{
				for (var r = 0; r < nbRows; r++)
				{
					var cell:Cell = this.getCell(c, r);
					if (cell != null && !cell.isEmpty())
					{
						var cellBlock:Block = cell.getBlock();
						if (!cellBlock.isInPlace() || cellBlock.isScoring())
						{
							return false;
						}
					}
				}
			}
			return true;
		}
		
		public function pauseAllBlocks():void
		{
			for (var c = 0; c < nbCols; c++)
			{
				for (var r = 0; r < nbRows; r++)
				{
					var cell:Cell = this.getCell(c, r);
					if (cell != null && !cell.isEmpty())
					{
						cell.getBlock().pause();
					}
				}
			}
		}
		
		public function resumeAllBlocks():void
		{
			for (var c = 0; c < nbCols; c++)
			{
				for (var r = 0; r < nbRows; r++)
				{
					var cell:Cell = this.getCell(c, r);
					if (cell != null && !cell.isEmpty())
					{
						cell.getBlock().resume();
					}
				}
			}
		}
		
		public function clearAllCells():void
		{
			for (var c = 0; c < nbCols; c++)
			{
				for (var r = 0; r < nbRows; r++)
				{
					var cell:Cell = this.getCell(c, r);
					if (cell != null && !cell.isEmpty())
					{
						cell.getBlock().removeBlock();
						cell.assignBlock(null);
					}
				}
			}
		}
		
		public function getCell(c:int, r:int):Cell //can return null
		{
			if (c < nbCols && c > -1 && 
				r < nbRows && r > -1)
			{
				return cells[c][r];
			} else
			{
				return null;
			}
		}
	}
	
}
