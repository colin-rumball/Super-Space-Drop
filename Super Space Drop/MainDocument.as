package  {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.ui.*;
	import flash.filters.GlowFilter; 
	import flash.media.Sound;
    import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import Scripts.*;
	
	public class MainDocument extends Game implements IGame 
	{
		private const TURN_TIMER_NAME:String = "TurnTimer";
		private const DROPPER_TIMER_NAME:String = "DropperTimer";
		private const TURN_LENGTH:int = 6000;
		private const TIME_BETWEEN_DROPS:int = 800;
		
		private var nextBlockSets:Array;
		private var turnTimerBars:Array;
		
		public var timerManager:TimerManager;
		public var resourceManager:ResourceManager;
		public var scoreManager:ScoreManager;
		
		private var dayEnding:Boolean;
		private var currentTurn:int;
		private var currentDay:int;
		
        var swipeSound:Sound;
		var clickSound:Sound;
		var moveSound:Sound;
		var failSound:Sound;
		var rotateSound:Sound;
		var music:Sound;
		var sndChannel:SoundChannel;
		var gameMuted:Boolean;
		
		var clickLocation:Array;
		
		private var muteUnmuteButton:MuteUnmuteButton;
		
		public var board:Board;
		public var dropper:Dropper;
		
		public var level:Level;
		public var gameOverScreen:GameOverScreen;
		public var mainMenu:MainMenu;
		public var gamePausedScreen:GamePausedScreen;
		public var howToScreen:HowToScreen;
		public var startScreen:StartScreen;
		public var confirmationScreen:ConfirmationScreen;
		public var beginningScreen:BeginningScreen;
		
		public function MainDocument() 
		{
			super( { type: GameEvent.GAME_LOAD, callback: gameload }, 
				  	{ type: GameEvent.GAME_MENU, callback: gamemenu },
					{ type: GameEvent.GAME_WAITING, callback: gamewaiting },
					{ type: GameEvent.GAME_PLAY, callback: gameplay },
					{ type: GameEvent.GAME_STATUS, callback: gamestatus },
					{ type: GameEvent.GAME_PAUSE, callback: gamepause },
					{ type: GameEvent.GAME_LOSE, callback: gamelose } );
			
			gotoState(GameEvent.GAME_LOAD);
		}
		
		public function gameload(e:Event) 
		{
			trace("gameload");
			board = new Board();
			level =  new Level();
			
			resourceManager = new ResourceManager();
			dropper = new Dropper(board);
			scoreManager = new ScoreManager();
			timerManager = new TimerManager();
			timerManager.addNewTimer(TURN_LENGTH, this.endTurn, TURN_TIMER_NAME);
			timerManager.addNewTimer(TIME_BETWEEN_DROPS, dropper.enableDrops, DROPPER_TIMER_NAME);
			
			currentTurn = 1;
			dayEnding = false;
			
			swipeSound = new SwipeSound();
			clickSound = new ClickSound();
			moveSound = new MoveSound();
			failSound = new FailSound();
			rotateSound = new RotateSound();
			music = new Music();
			gameMuted = false;
			muteUnmuteButton = new MuteUnmuteButton;
			
			nextBlockSets = new Array();
			var tempArray:Array = new Array();
			tempArray.push(new Block(32, 122-108, 1));
			tempArray.push(new Block(72, 122-108, 2));
			tempArray.push(new Block(32, 162-108, 2));
			tempArray.push(new Block(72, 162-108, 1));
			nextBlockSets.push(tempArray);
			
			var glowFilter:GlowFilter = new GlowFilter(); 
			glowFilter.inner=false; 
			glowFilter.color = 0xFFFFFF; 
			glowFilter.blurX = 15; 
			glowFilter.blurY = 15; 
			glowFilter.alpha = 0.5;
			
			(nextBlockSets[0][0] as MovieClip).filters = [glowFilter];
			(nextBlockSets[0][1] as MovieClip).filters = [glowFilter];
			(nextBlockSets[0][2] as MovieClip).filters = [glowFilter];
			(nextBlockSets[0][3] as MovieClip).filters = [glowFilter];
			
			for (var i = 0; i < 3; i++)
			{
				tempArray = new Array();
				var newBlockTypes:Array = new Array(generateNewBlockType(), generateNewBlockType());
				while (newBlockTypes[0] == newBlockTypes[1])
				{
					newBlockTypes[1] = generateNewBlockType();
				}
				var numberOfType1:int = 0;
				var numberOfType2:int = 0;
				for (var j = 0; j < 2; j++)
				{
					for (var k = 0; k < 2; k++)
					{
						var rand:Number = Math.floor((Math.random()*2)+1);
						if ((rand == 1 && numberOfType1 < 3) || numberOfType2 > 2)
						{
							var newBlock:Block = new Block((k*40)+32, 216+27+(j*40)+(i*97)-108, newBlockTypes[0]); //change numbers in this thing crazy
							newBlock.alpha = 0.75-(i*0.25);
							tempArray.push(newBlock);
							numberOfType1++;
						} else
						{
							var newBlock:Block = new Block((k*40)+32, 216+27+(j*40)+(i*97)-108, newBlockTypes[1]);
							newBlock.alpha = 0.75-(i*0.25);
							tempArray.push(newBlock);
							numberOfType2++;
						}
					}
				}
				nextBlockSets.push(tempArray);
			}
			
			turnTimerBars = new Array();
			for (var j = 0; j < 2; j++)
			{
				turnTimerBars.push(new TimeBar());
				turnTimerBars[j].x = 148+(j*616);
				turnTimerBars[j].y = 2;
			}
			
			confirmationScreen = new ConfirmationScreen();
			mainMenu = new MainMenu();
			gamePausedScreen =  new GamePausedScreen();
			gameOverScreen = new GameOverScreen();
			howToScreen = new HowToScreen()
			startScreen = new StartScreen(); 
			beginningScreen = new BeginningScreen();
			
			resetGame();
			
			clickLocation = new Array(-1, -1);
			
			stage.addChild(muteUnmuteButton);
			muteUnmuteButton.x = 22;
			muteUnmuteButton.y = 14;
			muteUnmuteButton.gotoAndStop(1);
			muteUnmuteButton.MuteButton.addEventListener(MouseEvent.CLICK, muteButtonHandler);
			
			gotoState(GameEvent.GAME_WAITING);
		}
		
		public function resetGame() //change check everything for reset, and reset blocks to come
		{
			board = new Board();
			level =  new Level();
			
			currentTurn = 1;
			currentDay = 1;
			
			resourceManager.resetResources();
			scoreManager = new ScoreManager();
			
			dropper = new Dropper(board);
			for (var i = 0; i < 2; i++)
			{
				turnTimerBars[i].gotoAndStop(100);
			}
		}
		
		public function gamewaiting(e:Event)
		{
			stage.addChild(beginningScreen);
			beginningScreen.addEventListener(MouseEvent.CLICK, beginningScreenButtonHandler);
		}
		
		public function gamemenu(e:Event)
		{
			stage.addChild(mainMenu);
			stage.addEventListener(Event.ENTER_FRAME, mainMenu.update)
			mainMenu.PlayButton.addEventListener(MouseEvent.CLICK, playButtonHandler);
			mainMenu.HelpButton.addEventListener(MouseEvent.CLICK, helpButtonHandler);
			bringMuteUnmuteButtonToFront();
		}
		
		public function gameplay(e:Event) 
		{
			//trace("gameplay");
			timerManager.checkTimersForFinished();
			resourceManager.updateBarLengths();
			board.runBoardMaintenance(scoreManager, resourceManager, currentTurn, gameMuted);
			dropper.updateGhostPosition();
			scoreManager.updateScoreDisplay(level);
			
			var tempTurnTimer:CustomTimer = timerManager.getTimerByName(TURN_TIMER_NAME);
			for (var i = 0; i < 2; i++) //update turn timer bars
			{
				if (!tempTurnTimer.isPaused() && tempTurnTimer.isRunning())
				{
					(turnTimerBars[i] as TimeBar).gotoAndStop(Math.ceil((tempTurnTimer.getTimeLeft()/6000)*100));
				}
			}
			
			if (dayEnding && board.allBlocksAsleep())
			{
				gotoState(GameEvent.GAME_STATUS);
			}
			
			if (currentTurn >= 14+(currentDay*2) && !dayEnding) //end day
			{
				dayEnding = true;
				dropper.hideGhost();
				timerManager.pauseAllTimers();
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
			}
			//trace("gameplay-END");
		}
		
		public function gamestatus(e:Event)
		{
			trace("gamestatus");
			stage.removeEventListener(Event.ENTER_FRAME, gameplay);
			
			level.gotoAndPlay(2);
			level.ContinueButton.addEventListener(MouseEvent.CLICK, continueButtonHandler);
			level.DayCounter.Count.text = currentDay;
			resourceManager.checkForNewResource(currentDay, level);
			scoreManager.equalizeScores();
			scoreManager.updateScoreDisplay(level);
			dayEnding = false;
			bringMuteUnmuteButtonToFront();
		}
		
		public function gamelose(e:Event) //change
		{
			trace("gamelose");
			if (!gameMuted)
			{
				sndChannel.stop();
				failSound.play();
			}
			level.PauseButton.removeEventListener(MouseEvent.CLICK, pauseButtonHandler);
			stage.removeEventListener(Event.ENTER_FRAME, gameplay);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
			
			stage.addChild(gameOverScreen);
			var index:int = resourceManager.getResourceAtZero();
			gameOverScreen.Ship.gotoAndStop(index);
			gameOverScreen.Status.text = "On day "+currentDay+" of your journey ";
			switch(index)
			{
				case 0:
					gameOverScreen.Ship.gotoAndStop(7);
					gameOverScreen.Status.appendText("your particle storage unit overflowed causing your ship to explode.");
					break;
				case Block.FOOD:
					gameOverScreen.Status.appendText("your food reserves depleted causing you to starve to death, and leaving your unmanned ship hurtling through space aimlessly.");
					break;
				case Block.FUEL:
					gameOverScreen.Status.appendText("your fuel reserves depleted leaving your ship to float recklessly out of control through space with you still inside.");
					break;
				case Block.OXYGEN:
					gameOverScreen.Status.appendText("your oxygen reserves depleted causing you to slip into a deep endless sleep, leaving your unmanned ship hurtling forward.");
					break;
				case Block.ELECTRICITY:
					gameOverScreen.Status.appendText("your electricity reserves depleted causing your ship to shut down, leaving you to ponder your fate within your own tin coffin.");
					break;
				case Block.ARMOUR:
					gameOverScreen.Status.appendText("your armour was fully depleted resulting in your ship being torn to pieces by the next asteroid to hit it.");
					break;
			}
			gameOverScreen.Score.text = scoreManager.getScoreString();
			stage.removeEventListener(Event.ENTER_FRAME, gameplay);
			gameOverScreen.QuitButton.addEventListener(MouseEvent.CLICK, quitButtonHandler);
			bringMuteUnmuteButtonToFront();
		}
		
		public function gamepause(e:Event)
		{
			trace("gamepause");
			level.PauseButton.removeEventListener(MouseEvent.CLICK, pauseButtonHandler);
			if (previousState == GameEvent.GAME_PLAY)
			{
				stage.removeEventListener(Event.ENTER_FRAME, gameplay);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
				timerManager.pauseAllTimers();
				board.pauseAllBlocks();
			} else if (previousState == GameEvent.GAME_STATUS)
			{
				level.ContinueButton.removeEventListener(MouseEvent.CLICK, continueButtonHandler);
			}
			
			stage.addChild(gamePausedScreen);
			gamePausedScreen.ResumeButton.addEventListener(MouseEvent.CLICK, resumeButtonHandler);
			gamePausedScreen.HelpButton.addEventListener(MouseEvent.CLICK, helpButtonHandler);
			gamePausedScreen.QuitButton.addEventListener(MouseEvent.CLICK, quitButtonHandler);
			
			bringMuteUnmuteButtonToFront();
		}
		
		//-----------------------------------------------------------------------------------------------------------------------
		
		public function KeyDown(e:KeyboardEvent)
		{
			//trace("KeyDown");
			if (currentState == GameEvent.GAME_PLAY)
			{
				if (e.keyCode == Keyboard.RIGHT)
				{
					if (!gameMuted)
					{
						moveSound.play();
					}
					dropper.moveRight();
				} else if (e.keyCode == Keyboard.LEFT)
				{
					if (!gameMuted)
					{
						moveSound.play();
					}
					dropper.moveLeft();
				} else if (e.keyCode == Keyboard.DOWN)
				{
					endTurn();
				} else if (e.keyCode == Keyboard.UP)
				{
					if (!gameMuted)
					{
						rotateSound.play();
					}
					rotateBlocks();
				}
			}
			//trace("KeyDown-END");
		}
		
		public function mouseDown(e:MouseEvent):void
		{
			if (e.localX > 100)
			{
				clickLocation = new Array(e.localX, e.localY);
			}
		}
		
		public function mouseMove(e:MouseEvent):void
		{
			if (e.localX > 100 && e.buttonDown)
			{
				if (e.localX > clickLocation[0]+40)
				{
					dropper.moveRight();
					clickLocation[0]+=40
				} else if (e.localX < clickLocation[0]-40)
				{
					dropper.moveLeft();
					clickLocation[0]-=40
				}
			}
			if (e.buttonDown)
			{
				if (e.localY > clickLocation[1]+90)
				{
					endTurn();
					clickLocation[1]+=90
				} else if (e.localY < clickLocation[1]-90)
				{
					rotateBlocks();
					clickLocation[1]-=90
				}
			}
		}
		
		//-----------------------------------------------------------------------------------------------------------------------
		
		public function beginningScreenButtonHandler(e:MouseEvent):void
		{
			trace("beginningScreenButtonHandler");
			beginningScreen.removeEventListener(MouseEvent.CLICK, beginningScreenButtonHandler);
			stage.removeChild(beginningScreen);
			playMusic();
			gotoState(GameEvent.GAME_MENU);
		}
		
		public function helpButtonHandler(e:MouseEvent):void
		{
			trace("helpButtonHandler");
			playButtonClickedSound();
			
			if (currentState == GameEvent.GAME_MENU)
			{
				mainMenu.PlayButton.removeEventListener(MouseEvent.CLICK, playButtonHandler);
				mainMenu.HelpButton.removeEventListener(MouseEvent.CLICK, helpButtonHandler);
				stage.removeEventListener(Event.ENTER_FRAME, mainMenu.update)
				stage.removeChild(mainMenu);
			} else if (currentState == GameEvent.GAME_PAUSE)
			{
				for (var i:int = level.numChildren - 1; i >= 0; i--) 
				{
					level.getChildAt(i).visible = false;
				}
				gamePausedScreen.visible = false;
			}
			
			stage.addChild(howToScreen);
			stage.addEventListener(Event.ENTER_FRAME, howToScreen.update)
			howToScreen.BackButton.addEventListener(MouseEvent.CLICK, backButtonHandler);
			howToScreen.ForwardButton.addEventListener(MouseEvent.CLICK, forwardButtonHandler);
			bringMuteUnmuteButtonToFront();
		}
		
		public function backButtonHandler(e:MouseEvent):void
		{
			trace("backButtonHandler");
			playButtonClickedSound();
			
			if (howToScreen.currentFrame == 1)
			{
				
				howToScreen.BackButton.removeEventListener(MouseEvent.CLICK, backButtonHandler);
				howToScreen.ForwardButton.removeEventListener(MouseEvent.CLICK, forwardButtonHandler);
				stage.removeEventListener(Event.ENTER_FRAME, howToScreen.update)
				stage.removeChild(howToScreen);
				
				if (currentState == GameEvent.GAME_MENU)
				{
					stage.addChild(mainMenu);
					stage.addEventListener(Event.ENTER_FRAME, mainMenu.update)
					mainMenu.PlayButton.addEventListener(MouseEvent.CLICK, playButtonHandler);
					mainMenu.HelpButton.addEventListener(MouseEvent.CLICK, helpButtonHandler);
				} else if (currentState == GameEvent.GAME_PAUSE)
				{
					for (var i:int = level.numChildren - 1; i >= 0; i--) 
					{
						if (level.getChildAt(i).name != "AsteroidField")
							level.getChildAt(i).visible = true;
					}
					gamePausedScreen.visible = true;
				}
			} else
			{
				howToScreen.backPage();
				if (howToScreen.currentFrame == 3)
					howToScreen.ForwardButton.addEventListener(MouseEvent.CLICK, forwardButtonHandler);
			}
		}
		
		public function forwardButtonHandler(e:MouseEvent):void
		{
			trace("forwardButtonHandler");
			playButtonClickedSound();
			
			howToScreen.forwardPage();
			bringMuteUnmuteButtonToFront();
		}
		
		public function playButtonHandler(e:MouseEvent):void
		{
			trace("playButtonClicked");
			playButtonClickedSound();
			mainMenu.PlayButton.removeEventListener(MouseEvent.CLICK, playButtonHandler);
			mainMenu.HelpButton.removeEventListener(MouseEvent.CLICK, helpButtonHandler);
			stage.removeEventListener(Event.ENTER_FRAME, mainMenu.update)
			stage.removeChild(mainMenu);
			
			resetGame(); //change is this needed
			stage.addChild(level);
			
			resourceManager.addBarsToStage(level);
			level.GameArea.addChild(dropper);
			for (var i = 0; i < 4; i++)
			{
				for (var j = 0; j < 4; j++)
				{
					level.GameArea.addChild(nextBlockSets[i][j]);
				}
			}
			level.GameArea.addChild(turnTimerBars[0]);
			level.GameArea.addChild(turnTimerBars[1]);
			
			resourceManager.updateBarLengths();
			stage.addChild(startScreen);
			startScreen.StartButton.addEventListener(MouseEvent.CLICK, startButtonHandler);
			bringMuteUnmuteButtonToFront();
		}
		
		public function startButtonHandler(e:MouseEvent):void
		{
			trace("startButtonHandler");
			playButtonClickedSound();
			startScreen.StartButton.removeEventListener(MouseEvent.CLICK, startButtonHandler);
			timerManager.getTimerByName(TURN_TIMER_NAME).restart();
			stage.removeChild(startScreen);
			
			gotoState(GameEvent.GAME_PLAY);
			level.PauseButton.addEventListener(MouseEvent.CLICK, pauseButtonHandler);
			stage.addEventListener(Event.ENTER_FRAME, gameplay);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
			level.GameArea.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown); //change
			level.GameArea.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			bringMuteUnmuteButtonToFront();
			stage.focus = null;
		}
		
		public function pauseButtonHandler(e:MouseEvent):void
		{
			trace("pauseButtonClicked");
			playButtonClickedSound();
			if (level.currentFrame == 1 || level.currentFrame == 91)
			{
				gotoState(GameEvent.GAME_PAUSE);
			}
		}
		
		public function resumeButtonHandler(e:MouseEvent):void
		{
			trace("resumeButtonClicked");
			playButtonClickedSound();
			gamePausedScreen.ResumeButton.removeEventListener(MouseEvent.CLICK, resumeButtonHandler);
			gamePausedScreen.HelpButton.removeEventListener(MouseEvent.CLICK, helpButtonHandler);
			gamePausedScreen.QuitButton.removeEventListener(MouseEvent.CLICK, quitButtonHandler);
			stage.removeChild(gamePausedScreen);
			
			level.PauseButton.addEventListener(MouseEvent.CLICK, pauseButtonHandler);
			if (previousState == GameEvent.GAME_PLAY)
			{
				timerManager.resumeAllTimers();
				
				stage.addEventListener(Event.ENTER_FRAME, gameplay);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
				gotoState(GameEvent.GAME_PLAY);
				board.resumeAllBlocks();
			} else if (previousState == GameEvent.GAME_STATUS)
			{
				level.ContinueButton.addEventListener(MouseEvent.CLICK, continueButtonHandler);
				currentState = previousState;
			}
			stage.focus = null;
		}
		
		public function quitButtonHandler(e:MouseEvent):void
		{
			trace("quitButtonHandler");
			playButtonClickedSound();
			switch(currentState)
			{
				case GameEvent.GAME_LOSE:
					if (gameOverScreen.currentFrame == 60)
					{
						gameOverScreen.QuitButton.removeEventListener(MouseEvent.CLICK, quitButtonHandler);
						stage.removeChild(gameOverScreen);
						stage.removeChild(level);
						
						playMusic();
						gotoState(GameEvent.GAME_MENU);
						resetGame();
					}
					break;
				case GameEvent.GAME_PAUSE:
					gamePausedScreen.ResumeButton.removeEventListener(MouseEvent.CLICK, resumeButtonHandler);
					gamePausedScreen.HelpButton.removeEventListener(MouseEvent.CLICK, helpButtonHandler);
					gamePausedScreen.QuitButton.removeEventListener(MouseEvent.CLICK, quitButtonHandler);
			
					stage.addChild(confirmationScreen);
					confirmationScreen.YesButton.addEventListener(MouseEvent.CLICK, yesButtonHandler);
					confirmationScreen.NoButton.addEventListener(MouseEvent.CLICK, noButtonHandler);
					break;
			}
			bringMuteUnmuteButtonToFront()
		}
		
		public function yesButtonHandler(e:MouseEvent):void
		{
			trace("yesButtonHandler");
			playButtonClickedSound();
			confirmationScreen.YesButton.removeEventListener(MouseEvent.CLICK, yesButtonHandler);
			confirmationScreen.NoButton.removeEventListener(MouseEvent.CLICK, noButtonHandler);
			stage.removeChild(confirmationScreen);
			
			gamePausedScreen.ResumeButton.removeEventListener(MouseEvent.CLICK, resumeButtonHandler);
			gamePausedScreen.HelpButton.removeEventListener(MouseEvent.CLICK, helpButtonHandler);
			gamePausedScreen.QuitButton.removeEventListener(MouseEvent.CLICK, quitButtonHandler);
			stage.removeChild(gamePausedScreen);
			stage.removeChild(level);
			
			gotoState(GameEvent.GAME_MENU);
			resetGame();
		}
		
		public function noButtonHandler(e:MouseEvent):void
		{
			trace("noButtonHandler");
			playButtonClickedSound();
			confirmationScreen.YesButton.removeEventListener(MouseEvent.CLICK, yesButtonHandler);
			confirmationScreen.NoButton.removeEventListener(MouseEvent.CLICK, noButtonHandler);
			stage.removeChild(confirmationScreen);
			
			gamePausedScreen.ResumeButton.addEventListener(MouseEvent.CLICK, resumeButtonHandler);
			gamePausedScreen.HelpButton.addEventListener(MouseEvent.CLICK, helpButtonHandler);
			gamePausedScreen.QuitButton.addEventListener(MouseEvent.CLICK, quitButtonHandler);
		}
		
		public function continueButtonHandler(e:MouseEvent):void
		{
			trace("continueButtonHandler");
			playButtonClickedSound();
			if (level.currentFrame == 91)
			{
				level.gotoAndPlay(92);
				currentTurn = 0;
				dayEnding = false;
				currentDay++;
				timerManager.restartAllTimers();
				timerManager.addTimeToAllTimers(3500);
				board.clearAllCells();
				dropper.showGhost();
				dropper.makeMovable();
				gotoState(GameEvent.GAME_PLAY);
				level.PauseButton.addEventListener(MouseEvent.CLICK, pauseButtonHandler);
				stage.addEventListener(Event.ENTER_FRAME, gameplay);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
			}
			stage.focus = null;
		}
		
		public function muteButtonHandler(e:MouseEvent):void
		{
			trace("muteButtonHandler");
			playButtonClickedSound();
			muteUnmuteButton.MuteButton.removeEventListener(MouseEvent.CLICK, muteButtonHandler);
			
			gameMuted = true;
			sndChannel.stop();
			sndChannel.removeEventListener(Event.SOUND_COMPLETE, loopMusic);
			muteUnmuteButton.gotoAndStop(2);
			muteUnmuteButton.UnmuteButton.addEventListener(MouseEvent.CLICK, unmuteButtonHandler);
			stage.focus = null;
		}
		
		public function unmuteButtonHandler(e:MouseEvent):void
		{
			trace("unmuteButtonHandler");
			playButtonClickedSound();
			muteUnmuteButton.UnmuteButton.removeEventListener(MouseEvent.CLICK, unmuteButtonHandler);
			
			gameMuted = false;
			playMusic();
			muteUnmuteButton.gotoAndStop(1);
			muteUnmuteButton.MuteButton.addEventListener(MouseEvent.CLICK, muteButtonHandler);
			stage.focus = null;
		}
		
		//-----------------------------------------------------------------------------------------------------------------------
		
		public function endTurn():void
		{
			//trace("endTurn");
			if (dropper.canDropNextSet())
			{
				if (!gameMuted)
				{
					swipeSound.play();
				}
				if (dropper.dropNextSetWithoutFail(nextBlockSets[0], level))
				{
					currentTurn++;
					cycleNextBlockSets();
					if (timerManager.getTimerByName(TURN_TIMER_NAME).getTimeLeft() < 6000)
					{
						scoreManager.addToScore(Math.ceil((timerManager.getTimerByName(TURN_TIMER_NAME).getTimeLeft()/6000)*50));
					}
				} else
				{
					gotoState(GameEvent.GAME_LOSE);
				}
				resourceManager.decreaseResources(currentTurn);
				if (!resourceManager.allResourcesArePositive())
				{
					gotoState(GameEvent.GAME_LOSE);
				}
				dropper.disableDrops();
				dropper.updateGhostTypes(nextBlockSets[0]);
				timerManager.getTimerByName(TURN_TIMER_NAME).restart();
				timerManager.getTimerByName(DROPPER_TIMER_NAME).restart();
			}
		}
		
		public function generateNewBlockType():int
		{
			if (resourceManager.getNumOfResourcesInNeed() > 1)
			{
				var newBlockType:int;
				var totalCount:int = 0;
				for (var i = 0; i < 5; i++)
				{
					totalCount += 100-resourceManager.getActualValue(i);
				}
			
				var rand:Number = Math.floor((Math.random()*totalCount)+1);
				var counter:int = 0;
				for (var j = 0; j < 5; j++)
				{
					if (rand <= (100-resourceManager.getActualValue(j))+counter)
					{
						newBlockType = j+1;
						break;
					}
					counter += 100-resourceManager.getActualValue(j);
				}
			} else
			{
				newBlockType = Math.floor((Math.random()*resourceManager.getNumberOfActiveResources())+1)
			}
			return newBlockType;
		}
		
		public function cycleNextBlockSets():void
		{
			var newBlockTypes:Array = new Array(generateNewBlockType(), generateNewBlockType());
			while (newBlockTypes[0] == newBlockTypes[1])
			{
				newBlockTypes[1] = generateNewBlockType();
			}
			
			var numberOfType1:int = 0;
			var numberOfType2:int = 0;
			for (var i = 0; i < 4; i++)
			{
				(nextBlockSets[0][i] as Block).setType((nextBlockSets[1][i] as Block).getType());
				(nextBlockSets[1][i] as Block).setType((nextBlockSets[2][i] as Block).getType());
				(nextBlockSets[2][i] as Block).setType((nextBlockSets[3][i] as Block).getType());
				var rand:Number = Math.floor((Math.random()*2)+1);
				if ((rand == 1 && numberOfType1 < 3) || numberOfType2 > 2)
				{
					(nextBlockSets[3][i] as Block).setType(newBlockTypes[0]);
					numberOfType1++;
				} else
				{
					(nextBlockSets[3][i] as Block).setType(newBlockTypes[1]);
					numberOfType2++;
				}
			}
		}
		
		public function rotateBlocks():void
		{
			var tempBlockType:int = (nextBlockSets[0][0] as Block).getType();
			(nextBlockSets[0][0] as Block).setType((nextBlockSets[0][2] as Block).getType());
			(nextBlockSets[0][2] as Block).setType((nextBlockSets[0][3] as Block).getType());
			(nextBlockSets[0][3] as Block).setType((nextBlockSets[0][1] as Block).getType());
			(nextBlockSets[0][1] as Block).setType(tempBlockType);
			dropper.updateGhostTypes(nextBlockSets[0]);
		}
		//-----------------------------------------------------------------------------------------------------------------------
		function loopMusic(e:Event):void
		{
			trace("loopMusic");
			sndChannel.removeEventListener(Event.SOUND_COMPLETE, loopMusic);
			playMusic();
		}
		
		function playMusic():void
		{
			trace("playMusic");
			if (!gameMuted)
			{
				sndChannel = music.play();
				var myTransform1:SoundTransform = new SoundTransform(0.5);
				sndChannel.soundTransform = myTransform1;
				sndChannel.addEventListener(Event.SOUND_COMPLETE, loopMusic);
			}
		}
		
		function playButtonClickedSound():void
		{
			if (!gameMuted)
			{
				clickSound.play();
			}
		}
		
		function bringMuteUnmuteButtonToFront():void
		{
			stage.setChildIndex(muteUnmuteButton, stage.numChildren - 1);
		}
	}
	
}
