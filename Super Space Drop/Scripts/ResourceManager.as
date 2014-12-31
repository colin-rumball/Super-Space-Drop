package Scripts {
	import flash.display.MovieClip;
	public class ResourceManager 
	{
		private var actualValues:Array;
		private var displayValues:Array;
		private var decreaseAmounts:Array;
		private var decreaseTimes:Array;
		private var resourceBars:Array;
		private var numberOfActiveResources:int;
		
		private const DAY_FOR_ELECTRICITY:int = 6;
		private const DAY_FOR_ARMOUR:int = 15;
		
		public function ResourceManager():void
		{
			numberOfActiveResources = 3;
			actualValues = new Array(100, 100, 100, 100, 100);
			displayValues = new Array(100, 100, 100, 100, 100);
			decreaseAmounts = new Array(8, 4, 3, 3, 18);
			decreaseTimes = new Array(6, 2, 1, 2, 11);
			resourceBars = new Array();
			var _bars:ResourceBars = new ResourceBars();
			resourceBars.push(_bars.RedBar);
			resourceBars.push(_bars.GreenBar);
			resourceBars.push(_bars.BlueBar);
			resourceBars.push(_bars.YellowBar);
			resourceBars.push(_bars.PurpleBar);
			for (var i = 0; i < 5; i++)
			{
				resourceBars[i].gotoAndStop(100);
			}
		}
		
		public function addToResource(_index:int, _amt:int):void
		{
			
			this.actualValues[_index] += _amt;
			if (this.actualValues[_index] > 100)
			{
				this.actualValues[_index] = 100;
			}
		}
		
		public function decreaseResources(_currentTurn:int):void
		{
			if (_currentTurn > 0)
			{
				for (var i = 0; i < numberOfActiveResources; i++)
				{
					if (_currentTurn % (decreaseTimes[i] as int) == 0)
					{
						actualValues[i] -= decreaseAmounts[i];
					}
				}
			}
		}
		
		public function allResourcesArePositive():Boolean
		{
			for (var i = 0; i < numberOfActiveResources; i++)
			{
				if (displayValues[i] <= 0)
				{
					return false;
				}
			}
			return true;
		}
		
		public function getResourceAtZero():int
		{
			for (var i = 0; i < numberOfActiveResources; i++)
			{
				if (actualValues[i] <= 0)
				{
					return i+1;
				}
			}
			return 0;
		}
		
		public function addBarsToStage(_parent:MovieClip):void
		{
			for (var i = 0; i < 5; i++)
			{
				_parent.addChild(resourceBars[i]);
				resourceBars[i].x = 824+(28*i);
				resourceBars[i].y = 114;
			}
		}
		
		public function updateBarLengths():void
		{
			//trace("updateBarPositions");
			for (var i = 0; i < 5; i++)
			{
				if (actualValues[i] < displayValues[i])
				{
					displayValues[i]--;
				} else if (actualValues[i] > displayValues[i])
				{
					displayValues[i]++;
				}
				(resourceBars[i] as MovieClip).gotoAndStop(displayValues[i]);
			}
		}
		
		public function resetResources():void
		{
			numberOfActiveResources = 3;
			actualValues = new Array(100, 100, 100, 100, 100);
			displayValues = new Array(100, 100, 100, 100, 100);
			this.updateBarLengths();
		}
		
		public function checkForNewResource(_currentDay:int, _level:MovieClip):void
		{
			if (_currentDay >= DAY_FOR_ELECTRICITY)
			{
				if (_currentDay == DAY_FOR_ELECTRICITY)
				{
					_level.StatusText.text = "Leaving Sun's Orbit.\nSolar Power Down.";
					this.addNewResource();
				}
				_level.Sun.visible = false;
			} else 
			{
				_level.Sun.gotoAndStop(_currentDay);
			}
			if (_currentDay >= DAY_FOR_ARMOUR)
			{
				if (_currentDay == DAY_FOR_ARMOUR)
				{
					_level.StatusText.text = "Entering Asteroid Field.\nMaintaining Armour is Essential.";
					this.addNewResource();
				}
				_level.AsteroidField.visible = true;
			} else
			{
				_level.AsteroidField.visible = false;
			}
		}
		
		public function addNewResource():void
		{
			if (this.getNumberOfActiveResources() < 5)
			{
				numberOfActiveResources++;
			}
		}
		
		public function getNumOfResourcesInNeed():int
		{
			var returnInt:int = 0;
			for (var i = 0; i < numberOfActiveResources; i++)
			{
				if (actualValues[i] < 100)
				{
					returnInt++;
				}
			}
			return returnInt;
		}
		
		public function getActualValue(_index:int):int
		{
			return actualValues[_index];
		}
		
		public function getNumberOfActiveResources():int
		{
			return numberOfActiveResources;
		}

	}
	
}
