package Scripts 
{
	import Scripts.Board;
	import Scripts.Block;
	import flash.display.MovieClip;
	
	public class Cell 
	{
		private var column:int;
		private var row:int;
		private var x:int;
		private var y:int;
		
		private var board:Board;
		
		private var block:Block;
		
		public function Cell(_board:Board, _column:int, _row:int):void
		{
			this.column = _column;
			this.row = _row;
			this.board = _board;
			this.x = 200+(_column*40) //change
			this.y = 32+(_row*40) //change
		}
		
		public function assignBlock(_block:Block):void
		{
			this.block = _block;
		}
		
		public function passBlockDown(_cellBelow:Cell):void
		{
			if (_cellBelow != null)
			{
				block.move(_cellBelow.getY());
				_cellBelow.assignBlock(block);
				this.assignBlock(null);
			}
		}
		
		public function isEmpty():Boolean
		{
			return (block == null);
		}
		
		public function getBlock():Block
		{
			return block;
		}
		
		public function getBoard():Board
		{
			return board;
		}
		
		public function getLeftCell():Cell
		{
			return board.getCell(column-1, row);
		}
		public function getRightCell():Cell
		{
			return board.getCell(column+1, row);
		}
		public function getTopCell():Cell
		{
			return board.getCell(column, row-1);
		}
		public function getBottomCell():Cell
		{
			return board.getCell(column, row+1);
		}
		
		public function getColumn():int
		{
			return column;
		}
		public function getRow():int
		{
			return row;
		}
		
		public function getY():int
		{
			return this.y;
		}
		
		public function getX():int
		{
			return this.x;
		}
	}
	
}
