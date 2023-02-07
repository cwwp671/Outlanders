class HLW_GameType extends GameInfo;

var HLW_GameSettings currentGameSettings;


var() const Archetype HLW_Pawn_Class_Mage MagePawnArchetype;
var() const Archetype HLW_Pawn_Class_Archer ArcherPawnArchetype;
var() const Archetype HLW_Pawn_Class_Warrior WarriorPawnArchetype;
var() const Archetype HLW_Pawn_Class_Barbarian BarbarianPawnArchetype;
var() int InitialUpgradePoints;

var config bool IsLocal;
var config int MaxPlayersPerTeam;

var actor EndGameFocus;
var string EndGameReason;
var int TimeTillRestart;
var bool bServerRestarting;
var bool bCanPlayTimeLimitMusic;

var float TimeLimitMusic;

event InitGame(string Options, out string ErrorMessage)
{
	ServerOptions = Options;

	super.InitGame(Options, ErrorMessage);
}

/**
 * Creates the Online game with the settings we want
 */
function RegisterServer()
{
	local OnlineGameSettings GameSettings;

	if(!IsLocal && OnlineGameSettingsClass != none && OnlineSub != none && OnlineSub.GameInterface != none)
	{
		GameSettings = new OnlineGameSettingsClass;

		// Create the game settings
		GameSettings.bShouldAdvertise = true;
		GameSettings.bIsDedicated=true;
		GameSettings.NumPublicConnections = 64;
		GameSettings.NumPrivateConnections = 0;
		GameSettings.OwningPlayerName = "NHTI Server";
		GameSettings.bIsLanMatch = false;

		HLW_GameSettings(GameSettings).setServerName("HLW Server");
		HLW_GameSettings(GameSettings).setMapName(WorldInfo.GetMapName());

		GameSettings.UpdateFromURL(ServerOptions, self);

		// Create the online game
		// First set the delegate thats called when the game was created (cause this is async)
		// When it returns it calls OnGameCreated to finish up
		OnlineSub.GameInterface.AddCreateOnlineGameCompleteDelegate(OnGameCreated);

		// Try to create the game. If it fails, clear the delegate
		// Note: the playerControllerId == 0 is the default
		if(OnlineSub.GameInterface.CreateOnlineGame(0, PlayerReplicationInfoClass.default.SessionName, GameSettings) == false)
		{
			OnlineSub.GameInterface.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);
			//`log("HLW_GameType::CreateOnlineGame - Failed to create online game.");
		}
	}
	
}

/**
 * Delegate that gets called when the OnlineGame has been created.
 */
function OnGameCreated(name SessionName, bool bWasSuccessful)
{
	OnlineSub.GameInterface.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);
}

/**
 * BroadcastMessage - sends messages to the chat window
 * 
 * @param sender is the player that has sent the message. If this is none then it is a system message to send to everyone.
 * @param message is the message we want to send
 * @param isTeamChat Whether or not this is being sent to the player's team
 */
function BroadcastMessage(PlayerController sender, string message, optional bool isTeamChat = false, optional int chatType)
{
	local HLW_PlayerController HLW_PC;
	local PlayerReplicationInfo PRI;

	// Make sure our world info isn't none
	if(WorldInfo != none)
	{
		// If the sender is none then this came from the server, so send it to everyone.
		if(sender == none)
		{
			// loop through all the player controllers and send the message
			foreach WorldInfo.AllControllers(class'HLW_PlayerController', HLW_PC)
			{
				
				// output debug info to the log
				HLW_PC.ReceiveBroadcast("", message, chatType);
			}
		}
		// Check to see if the player only wants to chat with his / her team
		else if(isTeamChat)
		{
			PRI = sender.PlayerReplicationInfo;
			// Loop through all the player controllers
			foreach WorldInfo.AllControllers(class'HLW_PlayerController', HLW_PC)
			{
				// Check to see if the player is on the same team as the sender.
				if(HLW_PC.PlayerReplicationInfo.Team == PRI.Team)
				{
					// If the player is on the same team, send them the message.
					HLW_PC.ReceiveBroadcast("Team-" $PRI.PlayerName, message, chatType);
				}
			}
		}
		else
		{
			PRI = sender.PlayerReplicationInfo;
			// This is a message from a player to all other players
			// loop through all the player controllers and send the message
			foreach WorldInfo.AllControllers(class'HLW_PlayerController', HLW_PC)
			{
				// output debug info to the log
				HLW_PC.ReceiveBroadcast(PRI.PlayerName, message, chatType);
			}
		}
	}
}

event Broadcast(Actor sender, coerce string Msg, optional name Type)
{
	local HLW_PlayerController HLW_PC;
	local PlayerReplicationInfo PRI;

	// This gets the PRI of the sender. We can use this to get the players name
	if(Pawn(sender) != none)
	{
		PRI = Pawn(sender).PlayerReplicationInfo;
	}
	else if(Controller(sender) != none)
	{
		PRI = Controller(sender).PlayerReplicationInfo;
	}

	// This executes a "Say" message
	//BroadcastHandler.Broadcast(sender, Msg, Type);

	// Here we broadcast all the messages to all the players
	if(WorldInfo != none)
	{
		foreach WorldInfo.AllControllers(class'HLW_PlayerController', HLW_PC)
		{
			HLW_PC.ReceiveBroadcast(PRI.PlayerName, Msg, 0);
		}
	}
}

event PostLogin( PlayerController NewPlayer)
{
	local HLW_PlayerController HLW_PC;
	local bool isTeamGame;
	local int NumBluePlayers, NumYellowPlayers;

	super.PostLogin(NewPlayer);

	//`log("Post Login Called from " $NewPlayer);

	// Check to make sure we have a player controller
	if(HLW_PlayerController(NewPlayer) == none)
	{
		// Break out of this function if we don't have a controller
		//`log("We don't have a controller");
		return;
	}

	// This is how we stop VOIP from automatically starting.
	NewPlayer.ClientStopNetworkedVoice();
	
	// This makes the player controller a spectator
	NewPlayer.PlayerReplicationInfo.bOnlySpectator = true;

	// Set initial state to spectating
	NewPlayer.ClientGotoState('Spectating');

	// Set our local variable to the NewPlayer
	HLW_PC = HLW_PlayerController(NewPlayer);
	
	HLW_PC.bIsInitialSpawn = true;
	
	
	// Check the name of the map to determine which map to load. This is for menu purposes only
	if(WorldInfo.GetMapName() == "HLW_MainMenu")
	{
		// Open the main menu from the player controller
		HLW_PC.OpenMenu('HLW_MainMenu');

		// Make sure the menu has full control of input
		HLW_PC.SetCinematicMode(true, true, true, true, true, true);

		return;
	}
	else
	{
		isTeamGame = WorldInfo.GetGameClass() == class'HLW_GameType_LineWars' || WorldInfo.GetGameClass() == class'HLW_GameType_TDM';
	
		NumBluePlayers = isTeamGame ? WorldInfo.GRI.Teams[0].Size : 0;
		NumYellowPlayers = isTeamGame ? WorldInfo.GRI.Teams[1].Size : 0;

		HLW_PC.OpenMenu('HLW_ClassSelection', isTeamGame, NumBluePlayers , NumYellowPlayers);
		
		HLW_PC.SetCinematicMode(false, false, true, true, true, true);
	}
}

function LogOut(Controller Exiting)
{
	super.Logout(Exiting);

	if(NumPlayers == 0)
	{
		RestartGame();
	}
}

function StartMatch()
{
	local Actor A;
	local HLW_PlayerController Player;
	 //tell all actors the game is starting
	ForEach AllActors(class'Actor', A)
	{
		A.MatchStarting();
	}

	// start human players first
	StartHumans();

	StartOnlineGame();

	// fire off any level startup events
	WorldInfo.NotifyMatchStarted();
	
	TimeLimitMusic = GetMapTimeLimitMusicTime();
	
	ForEach DynamicActors(class'HLW_PlayerController', Player)
	{
		Player.PlayMusic(GetMapStartMusic());	
	}
	
	SetTimer(TimeLimit * 60.0f, false, 'TimeLimitOver');
	HLW_GameReplicationInfo(WorldInfo.GRI).bMatchInProgress = true;
}

function Tick(float DeltaTime)
{
	local HLW_PlayerController Player;
	
	super.Tick(DeltaTime);
	
	if(bCanPlayTimeLimitMusic)
	{
		if(IsTimerActive('TimeLimitOver'))
		{
			if((TimeLimit * 60.0f) - GetTimerCount('TimeLimitOver') <= TimeLimitMusic)
			{
				bCanPlayTimeLimitMusic = false;
				
				ForEach DynamicActors(class'HLW_PlayerController', Player)
				{
					Player.PlayMusic(GetMapTimeLimitMusic());	
				}
				
				//TriggerGlobalEventClass(class'HLW.HLW_SeqEvent_PlayTimeLimitMusic', self);
			}
		}
	}	
}

function float GetMapTimeLimitMusicTime()
{
	switch(WorldInfo.GetMapName())
	{
		case "HLW_DayArena":
			return 88;
			break;
		case "HLW_NightArena":
			return 96;
			break;
		case "HLW_PentagonArena2":
			return 98;
			break;
		case "HLW_PentagonArena2_NoGrass":
			return 98;
			break;
		case "HLW_PentagonArena2_NoGrassAI":
			return 98;
			break;		
	}
}

function SoundCue GetMapTimeLimitMusic()
{
	switch(WorldInfo.GetMapName())
	{
		case "HLW_DayArena":
			return SoundCue'HLW_Package_Chris_Music.Arena_Day.Music_ArenaDay_Time';
			break;
		case "HLW_NightArena":
			return SoundCue'HLW_Package_Chris_Music.Arena_Night.Music_ArenaNight_Time';
			break;
		case "HLW_PentagonArena2":
			return SoundCue'HLW_Package_Chris_Music.jungle.Music_Jungle_Time';
			break;
		case "HLW_PentagonArena2_NoGrass":
			return SoundCue'HLW_Package_Chris_Music.jungle.Music_Jungle_Time';
			break;
		case "HLW_PentagonArena2_NoGrassAI":
			return SoundCue'HLW_Package_Chris_Music.jungle.Music_Jungle_Time';
			break;
	}
}

function SoundCue GetMapStartMusic()
{
	switch(WorldInfo.GetMapName())
	{
		case "HLW_DayArena":
			return SoundCue'HLW_Package_Chris_Music.Arena_Day.Music_ArenaDay_Intro';
			break;
		case "HLW_NightArena":
			return SoundCue'HLW_Package_Chris_Music.Arena_Night.Music_ArenaNight_Intro';
			break;
		case "HLW_PentagonArena2":
			return SoundCue'HLW_Package_Chris_Music.jungle.Music_Jungle_Intro';
			break;
		case "HLW_PentagonArena2_NoGrass":
			return SoundCue'HLW_Package_Chris_Music.jungle.Music_Jungle_Intro';
			break;
		case "HLW_PentagonArena2_NoGrassAI":
			return SoundCue'HLW_Package_Chris_Music.jungle.Music_Jungle_Intro';
			break;
	}
}

function TimeLimitOver();

/**
 * This is another function dealing with player spawning. We can add additional logic here too.
 * FindPlayerStart Calls ChoosePlayerStart which then calls RatePlayerStart on each player start in the level
 */
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string IncomingName)
{
	return super.FindPlayerStart(Player, InTeam, IncomingName);
}

/** ChoosePlayerStart()
 *  Modified ChoosePlayerStart to use one of our custom player starts at random that is enabled
 *  
* Return the 'best' player start for this player to start from.  PlayerStarts are rated by RatePlayerStart().
* @param Player is the controller for whom we are choosing a playerstart
* @param InTeam specifies the Player's team (if the player hasn't joined a team yet)
* @returns NavigationPoint chosen as player start (usually a PlayerStart)
 */
function PlayerStart ChoosePlayerStart( Controller Player, optional byte InTeam )
{
	local HLW_PlayerStart P;
	local byte TeamIndex;
	local float randomIndex;
	local array<HLW_PlayerStart> EnabledPlayerStarts;

	// use InTeam if player doesn't have a team yet
	TeamIndex = ( (Player != None) && (Player.PlayerReplicationInfo != None) && (Player.PlayerReplicationInfo.Team != None) )
			? byte(Player.PlayerReplicationInfo.Team.TeamIndex)
			: InTeam;

	// Loop through all the HLW_PlayerStarts that are on the map
	foreach WorldInfo.AllNavigationPoints(class'HLW_PlayerStart', P)
	{
		// Make sure the player start is enabled. If the player start is disabled RatePlayerStart will return 5.0f
		if(RatePlayerStart(P, TeamIndex, Player) > 5.0f && P.TeamIndex >= 2)
		{
			// Add the player start to the local array
			EnabledPlayerStarts.AddItem(P);
		}
	}

	if (EnabledPlayerStarts.Length <= 0)
	{
		return super.ChoosePlayerStart(Player, InTeam);
	}

	// Get a random index
	randomIndex = RandRange(0, EnabledPlayerStarts.Length);

	// Return the player start at the random index
	return EnabledPlayerStarts[int(randomIndex)];
}


function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
	local Pawn SpawnedPawn;
	//local class<Pawn> DefaultPlayerClass;
	local Rotator StartRotation;

    if (NewPlayer == none || StartSpot == none)
    {
        return none;
    }

	//DefaultPlayerClass = GetDefaultPlayerClass(NewPlayer);
	GetDefaultPlayerClass(NewPlayer);;
	// don't allow pawn to be spawned with any pitch or roll
	StartRotation.Yaw = StartSpot.Rotation.Yaw;
	
	switch (HLW_PlayerReplicationInfo(NewPlayer.PlayerReplicationInfo).classSelection)
	{
		Case 1:
			SpawnedPawn = Spawn(MagePawnArchetype.Class,,, StartSpot.Location, StartRotation, MagePawnArchetype);
			break;
		Case 2:
			SpawnedPawn = Spawn(ArcherPawnArchetype.Class,,, StartSpot.Location,, ArcherPawnArchetype); 
			break;
		Case 3:
			SpawnedPawn = Spawn(WarriorPawnArchetype.Class,,, StartSpot.Location, StartRotation, WarriorPawnArchetype);
			break;
		Case 4:
			SpawnedPawn = Spawn(BarbarianPawnArchetype.Class,,, StartSpot.Location, StartRotation, BarbarianPawnArchetype);
			break;
		Default:
			SpawnedPawn = Spawn(GetDefaultPlayerClass(NewPlayer),,, StartSpot.Location, StartRotation);
			break;
	}
	
	//`log("THE SPAWNED PAWN IS A"@SpawnedPawn);

	if ( SpawnedPawn == None )
	{
		//`log("Couldn't spawn player of type "$DefaultPlayerClass$" at "$StartSpot);
	}

	if (HLW_Pawn_Class(SpawnedPawn) != none)
	{
		HLW_Pawn_Class(SpawnedPawn).BaseUpgradePoints = InitialUpgradePoints;
	}

    return SpawnedPawn;
}

function class<Pawn> GetDefaultPlayerClass(Controller C)
{
	local HLW_PlayerController HLW_PC;

	HLW_PC = HLW_PlayerController(C);

	if (HLW_PC != none)
	{
		switch (HLW_PlayerReplicationInfo(HLW_PC.PlayerReplicationInfo).classSelection)
		{
		case 1:
			return MagePawnArchetype.Class;
		case 2:
			return ArcherPawnArchetype.Class;
		case 3:
			return WarriorPawnArchetype.Class;
		case 4:
			return BarbarianPawnArchetype.Class;
		}
	}

	return super.GetDefaultPlayerClass(C);
}

/** handles reinitializing players that remained through a seamless level transition
 * called from C++ for players that finished loading after the server
 * @param C the Controller to handle
 */
function HandleSeamlessTravelPlayer(out Controller C)
{
	local PlayerController PC, NewPC;
	local PlayerReplicationInfo OldPRI;

	//`log(">> GameInfo::HandleSeamlessTravelPlayer:" @ C,,'SeamlessTravel');

	PC = PlayerController(C);
	if (PC != None && PC.Class != PlayerControllerClass)
	{
		if (PC.Player != None)
		{
			// we need to spawn a new PlayerController to replace the old one
			NewPC = SpawnPlayerController(PC.Location, PC.Rotation);
			if (NewPC == None)
			{
				//`Warn("Failed to spawn new PlayerController for" @ PC.GetHumanReadableName() @ "(old class" @ PC.Class $ ")");
				PC.Destroy();
				return;
			}
			else
			{
				PC.CleanUpAudioComponents();
				PC.SeamlessTravelTo(NewPC);
				NewPC.SeamlessTravelFrom(PC);
				SwapPlayerControllers(PC, NewPC);
				PC = NewPC;
				C = NewPC;
			}
		}
		else
		{
			PC.Destroy();
		}
	}
	else
	{
		// clear out data that was only for the previous game
		C.PlayerReplicationInfo.Reset();
		// create a new PRI and copy over info; this is necessary because the old gametype may have used a different PRI class
		OldPRI = C.PlayerReplicationInfo;
		C.InitPlayerReplicationInfo();
		OldPRI.SeamlessTravelTo(C.PlayerReplicationInfo);
		// we don't need the old PRI anymore
		//@fixme: need a way to replace PRIs that doesn't cause incorrect "player left the game"/"player entered the game" messages
		OldPRI.Destroy();
	}

	// get rid of team because we will set new one
	if (C.PlayerReplicationInfo.Team != None)
	{
		C.PlayerReplicationInfo.Team.Destroy();
		C.PlayerReplicationInfo.Team = None;
	}

	PC.PlayerReplicationInfo.bOnlySpectator = true;

	if (PC != None)
	{
		PC.CleanUpAudioComponents();

		// tell the player controller to register its data stores again
		PC.ClientInitializeDataStores();

		SetSeamlessTravelViewTarget(PC);
		if (PC.PlayerReplicationInfo.bOnlySpectator)
		{
			PC.GotoState('Spectating');
			PC.PlayerReplicationInfo.bIsSpectator = true;
			PC.PlayerReplicationInfo.bOutOfLives = true;
			NumSpectators++;
		}
		else
		{
			NumPlayers++;
			NumTravellingPlayers--;
			PC.GotoState('PlayerWaiting');
		}
	}
	else
	{
		C.GotoState('RoundEnded');
	}

	PostLogin(PC);

	//`log("<< GameInfo::HandleSeamlessTravelPlayer:" @ C,,'SeamlessTravel');
}

function ScoreKill(Controller Killer, Controller Other)
{
	if(Killer != Other && Killer != none && Killer.PlayerReplicationInfo != none && HLW_Pawn_Creep(Other.Pawn) == none)
	{
		Killer.PlayerReplicationInfo.bForceNetUpdate = TRUE;
		HLW_PlayerReplicationInfo(Killer.PlayerReplicationInfo).SetKills();
	}

	if (Killer != None)
	{
		CheckScore(Killer.PlayerReplicationInfo);
	}
}

function EndGame(PlayerReplicationInfo Winner, string Reason )
{
	local Sequence GameSequence;
	local array<SequenceObject> Events;
	local int i;

	if ( (Reason ~= "triggered") ||
	 (Reason ~= "LastMan")   ||
	 (Reason ~= "TimeLimit") ||
	 (Reason ~= "FragLimit") ||
	 (Reason ~= "TeamScoreLimit") )
	{
		if(Winner != none)
		{
			SetEndGameFocus(Winner);
		}

		Super.EndGame(Winner,Reason);

		if ( bGameEnded )
		{
			// trigger any Kismet "Game Ended" events
			// Here is where we would trigger any events IE. Nexus exploding
			GameSequence = WorldInfo.GetGameSequence();
			if (GameSequence != None)
			{
				GameSequence.FindSeqObjectsByClass(class'UTSeqEvent_GameEnded', true, Events);
				for (i = 0; i < Events.length; i++)
				{
					UTSeqEvent_GameEnded(Events[i]).CheckActivate(self, None);
				}
			}

			GotoState('MatchOver');
		}
	}
}

function RestartAllDeadPlayers()
{
	local HLW_PlayerController HLW_PC;

	foreach WorldInfo.AllControllers(class'HLW.HLW_PlayerController', HLW_PC)
	{
		if(HLW_PC.Pawn == none)
		{
			super.RestartPlayer(HLW_PC);
		}
	}
}

function PreEndGame(PlayerReplicationInfo Winner, string Reason)
{
	//RestartAllDeadPlayers();

	GameReplicationInfo.Winner = winner;
	EndGameReason = Reason;

	HLW_GameReplicationInfo(GameReplicationInfo).bMatchInProgress = false;

	// Give the game time to restart dead players.
	SetTimer(3.0f, false, 'ActualEndGame');
}

function ActualEndGame()
{
	EndGame(PlayerReplicationInfo(GameReplicationInfo.Winner), EndGameReason);
}

function SetEndGameFocus(PlayerReplicationInfo Winner)
{
	local HLW_PlayerController HLW_PC;

	if(Winner.Owner != none)
	{
		EndGameFocus = Controller(Winner.Owner).Pawn;
	}

	if ( (EndGameFocus == None) && (Controller(Winner.Owner) != None) )
	{
		RestartPlayer(Controller(Winner.Owner));
		EndGameFocus = Controller(Winner.Owner).Pawn;
	}

	if ( EndGameFocus != None )
	{
		EndGameFocus.bAlwaysRelevant = true;
	}
	foreach WorldInfo.AllControllers(class'HLW.HLW_PlayerController', HLW_PC)
	{
		HLW_PC.GameHasEnded(EndGameFocus, true);
	}
}

state MatchOver
{
	function bool MatchIsInProgress()
	{
		return false;
	}

	event BeginState(Name PreviousStateName)
	{
		HLW_GameReplicationInfo(WorldInfo.GRI).bMatchInProgress = false;
		TimeTillRestart = 20;
		//SetTimer(20.0f, false, 'RestartGame');
	}

	function RestartPlayer(Controller NewPlayer)
	{
		return;
	}

	function Timer()
	{
		local HLW_PlayerController HLW_PC;

		if(bServerRestarting)
		{
			return;
		}

		foreach WorldInfo.AllControllers(class'HLW.HLW_PlayerController', HLW_PC)
		{
			if(HLW_PC != none && TimeTillRestart > 0)
			{
				HLW_PC.UpdateServerRestartText("Server Restarting in " $TimeTillRestart);
			}
			else
			{
				HLW_PC.UpdateServerRestartText("Server is Restarting...");
			}
		}

		if(TimeTillRestart == 0)
		{
			RestartGame();
			bServerRestarting = true;
		}


		TimeTillRestart--;
	}
}

//function bool CheckModifiedEndGame(PlayerReplicationInfo Winner, string Reason)
//{
//	local HLW_Base_Center BC;
//	foreach DynamicActors(class'HLW_Base_Center', BC)
//	{
//		if(BC != none && BC.Health <= 0)
//		{
//			return false;
//		}
//	}
//}

defaultproperties
{
	DefaultPawnClass=class'HLW.HLW_SpectatorPawn'
	PlayerControllerClass=class'HLW.HLW_PlayerController'
	PlayerReplicationInfoClass=class'HLW.HLW_PlayerReplicationInfo'
	GameReplicationInfoClass=class'HLW.HLW_GameReplicationInfo'
	OnlineGameSettingsClass=class'HLW.HLW_GameSettings'

	MagePawnArchetype=HLW_Pawn_Class_Mage'HLW_Package.Archetype.Mage_Archetype'
	ArcherPawnArchetype=HLW_Pawn_Class_Archer'HLW_Package_Dan.Archetypes.ArcherPawnArchetype'
	WarriorPawnArchetype=HLW_Pawn_Class_Warrior'HLW_Package.Archetype.Warrior_Archetype'
	BarbarianPawnArchetype=HLW_Pawn_Class_Barbarian'HLW_Package.Archetype.Barbarian_Archetype'

	bDelayedStart=false
	bUseSeamlessTravel=true
	bRestartLevel=false
	InitialUpgradePoints=1
	
	bCanPlayTimeLimitMusic=true
}