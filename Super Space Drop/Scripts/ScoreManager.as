package Scripts {
	
	public class ScoreManager 
	{
		private var actualScore:int;
		private var displayScore:int;
		
		public function ScoreManager():void
		{
			actualScore = 0;
			displayScore = 0;
		}
		
		public function updateScoreDisplay(_level:Level):void
		{
			if (actualScore < displayScore)
			{
				displayScore -= (displayScore-actualScore)/20;
			} else if (actualScore > displayScore)
			{
				displayScore += (actualScore-displayScore)/20;
			}
			
			if (_level.Score_Textbox != null)
			{
				var scoreString:String = this.getScoreString();
				_level.Score_Textbox.text = scoreString;
			}
		}
		
		public function addToScore(_addition:int):void
		{
			actualScore += _addition;
		}
		
		public function equalizeScores():void
		{
			displayScore = actualScore;
		}
		
		public function getDisplayScore():int
		{
			return displayScore;
		}
		
		public function getScoreString():String
		{
			var scoreString:String = displayScore.toString();
			for(var i:int = scoreString.length; i < 6; i++)
			{
				scoreString = '0' + scoreString;
			}
			return scoreString;
		}

	}
	
}
