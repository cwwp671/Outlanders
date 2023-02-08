/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_PlayerController extends PlayerController;

var int AimingAbilityIndex;
var bool AimingDebug;
var bool bIsCasting;
var bool bCanUseAbilities;
var bool bCanAttackPrimary;
var bool bCanAttackSecondary;
var bool bCanAcceptLookInput;
var int NumFreeAbilities;

var Name CachedPreviousState;
var byte CachedCameraType;
var bool bStunned;
// CJL temp ugly implementation of OOM hud
var bool bDidChangeOne;
var bool bDidChangeTwo;
var bool bDidChangeThree;
var bool bDidChangeFour;

var bool bIsInitialSpawn;
var bool bSuicided;

var float SuicideRespawnTime;
var float RespawnTime;

var HLW_Class_Select ClassSelector;

var class<HLW_MainMenu>     StartMenuClass;
var HLW_MainMenu    StartMenu;

var class<HLW_ClassSelectionMenu>     SelectionMenuClass;
var HLW_ClassSelectionMenu    SelectionMenu;

var class<HLW_Gfx_EndGameScreen> EndGameScreenClass;
var HLW_Gfx_EndGameScreen EndGameScreen;

var class<HLW_Gfx_InGameStatsScreen> InGameStatsScreenClass;
var HLW_Gfx_InGameStatsScreen InGameStats;

var class<HLW_Gfx_EscapeMenu> EscapeMenuClass;
var HLW_Gfx_EscapeMenu EscapeMenu;

var GFxMoviePlayer Menu;
var bool bQuittingToMainMenu;

var int ClassNumberSelection;

var HLW_Ability AimingAbility;
var bool bNextWeapon;
//LUKAS STUFF
var float OriginalMouseSensitivity;
var bool bSprinting;

var int PCCreepNumber;

var bool IsClassSwitch;
var bool bHasVotedSurrender;

var name CameraStyle;

enum ChatTypes{ALL_CHAT, TEAM_CHAT, SYSTEM_MESSAGE};
var ChatTypes chatType;

var repnotify byte KillPlayerByte;

replication
{
	if(bNetDirty && bNetOwner)
		NumFreeAbilities, KillPlayerByte;
}

simulated function ReplicatedEvent(Name VarName)
{
	if(VarName == 'KillPlayerByte')
	{
		ClientKillPlayer();
		return;
	}
	
	super.ReplicatedEvent(VarName);
}

reliable server function SetPawnType(int classNumber, int teamIndex, bool bIsSpectator, optional bool bIsJoiningFromSpectator)
{
	`log("PlayerController::SetPawn - Switching Class from spectator " $bIsJoiningFromSpectator);

	//`log("Pawn is a"@Pawn);
	
	if(bIsInitialSpawn || bIsJoiningFromSpectator)
	{
		SetPawn(classNumber, teamIndex,,bIsSpectator);
		bIsInitialSpawn=false;
		return;	
	}
	
	// We are trying to switch classes, so change the player rep variable and break out of this function
	ResetCinematic();
	HLW_PlayerReplicationInfo(PlayerReplicationInfo).classSelection = classNumber;
	IsClassSwitch = true;


	HLW_Pawn_Class(Pawn).TakeDamage(10000, none, Pawn.Location, vect(0,0,0), class'HLW.HLW_DamageType_Physical');
}

reliable server function SetPawn(int classNumber, int teamIndex, optional bool IsRespawn, optional bool bIsSpectator)
{
	//local HLW_Pawn_Class newPawn;
	local class<PlayerInput> NewInputClass;
	local class<HUD> newHudClass;

	//if(Pawn != none && !Pawn.IsA('HLW_SpectatorPawn') && !IsRespawn)
	//{
	//	// We are trying to switch classes, so change the player rep variable and break out of this function
	//	ResetCinematic();
	//	HLW_PlayerReplicationInfo(PlayerReplicationInfo).classSelection = classNumber;
	//	IsClassSwitch = true;
	//	return;
	//}

	switch(classNumber)
	{
		Case 1:
			newHudClass = class 'HLW_HUD_Mage';
			NewInputClass=class'MageInput';
			break;
		Case 2:
			newHudClass = class 'HLW_HUD_Archer';
			NewInputClass=class'ArcherInput';
			break;
		Case 3:
			newHudClass = class 'HLW_HUD_Warrior';
			NewInputClass=class'WarriorInput';
			break;
		Case 4:
			newHudClass = class 'HLW_HUD_Barbarian';
			NewInputClass=class'WarriorInput';
			break;
		default:
			NewInputClass=class'MageInput';
	}

	if(!IsRespawn)
	{
		SetCinematicMode(false, false, true, true, true, true);
		HLW_PlayerReplicationInfo(PlayerReplicationInfo).classSelection = classNumber;
		if(teamIndex != 255)
		{
			WorldInfo.GRI.Teams[teamIndex].AddToTeam(self);

			HLW_TeamInfo(HLW_PlayerReplicationInfo(PlayerReplicationInfo).Team).HLW_TeamColor = WorldInfo.GRI.Teams[teamIndex].TeamColor;
		}

		if(newHudClass != none)
		{
			ClientSetHUD(newHudClass);
		}
	}

	if(IsClassSwitch)
	{
		PlayerReplicationInfo.Reset();
		ClientSetHUD(newHudClass);
		
		IsClassSwitch = false;
	}

	// This should only happen when we first get in game EG. When the player is a Spectator Pawn
	if(Pawn != none)
	{
		Detach(Pawn);
		Pawn = none;
	}

	ClientCloseStatsScreen();

	// Used to make player not a spectator anymore.
	if(!bIsSpectator)
	{
		HLW_PlayerReplicationInfo(PlayerReplicationInfo).bOnlySpectator = false;
		// Use Epic's stuff to restart the player
		WorldInfo.Game.RestartPlayer(self);
	}
	else
	{
		GotoState('Spectating');
	}

	// Reset the input class we are using based of the chosen class
	if(NewInputClass != none)
	{
		ClientSetInput(NewInputClass);
	}

	ClientSetCameraClass();
	
}

reliable client function ResetCinematic()
{
	SetCinematicMode(false, false, true, true, true, true);
}

reliable client function SetHudPreMatchText(string TextToDraw)
{
	if(HLW_HUD_Class(myHUD) != none)
	{
		HLW_HUD_Class(myHUD).PreMatchBeginText = TextToDraw;
	}
}

reliable client function UpdateServerRestartText(string serverRestartText)
{
	if(EndGameScreen != none)
	{
		EndGameScreen.UpdateServerRestartText(serverRestartText);
	}
}

function AdjustHUDRenderSize(out int X, out int Y, out int SizeX, out int SizeY, const int FullScreenSizeX, const int FullScreenSizeY)
{
	if(myHud != None)
	{
		super.AdjustHUDRenderSize(X, Y, SizeX, SizeY, FullScreenSizeX, FullScreenSizeY);	
	}
}

reliable client function ClientSetInput(class<PlayerInput> NewInputClass)
{
	local int PIIndex;

	// Find and save the index of the current PlayerInput
	PIIndex = Interactions.Find(PlayerInput);

	// Change our input class and make a new PlayerInput with that class
	InputClass = NewInputClass;
	PlayerInput = new(Self) NewInputClass;

	// If we did not have a PlayerInput in our Interactions, put our new PlayerInput at the end
	if ( PIIndex == -1 )
	{
		Interactions[Interactions.Length] = PlayerInput;
	}
	else // If we did have a PlayerInput in our Interactions, replace it with our new PlayerInput
	{
		Interactions[PIIndex] = PlayerInput;
	}

	// Re-initialize the input system
	if (PlayerInput != none)
	{
		PlayerInput.InitInputSystem();
	}
}

reliable client function ClientSetHUD(class<HUD> newHUDType)
{
	super.ClientSetHUD(newHUDType);

	myHUD.PlayerOwner = self;
}

reliable client function OpenMenu(Name MenuName, optional bool isTeamGame, optional int numBluePlayers, optional int numYellowPlayers)
{
	local bool isClassSelection;

	switch(MenuName)
	{
				// This is code from my server browser. Leaving it here in case we need it for HLW ~Paul O.
	//case 'ChatLobby':
	//	Menu = new ChatLobbyClass;

	//	//if(WorldInfo.NetMode == NM_ListenServer && Role == ROLE_Authority)
	//	//{
	//	//	IsHost = true;
	//	//	SetTimer(30.0, true, 'UpdateServer');
	//	//}

	//	break;
	case 'HLW_MainMenu':
		Menu = new StartMenuClass;
		break;

	case 'HLW_ClassSelection':
		Menu = new SelectionMenuClass;
		isClassSelection = true;
		break;
	default:
		break;
	}

	if(Menu != none)
	{
		Menu.SetTimingMode(TM_Real);
		Menu.Init();

		if(isClassSelection)
		{
			HLW_ClassSelectionMenu(Menu).UnrealInit(isTeamGame);

			if(isTeamGame)
			{
				HLW_ClassSelectionMenu(Menu).UpdatePlayerNumbers(numBluePlayers, numYellowPlayers);
				SetUpdateClassSelectionPlayerNumbersTimer();
			}
		}
	}
}

function ShowEndGameScreen();

reliable server function SetUpdateClassSelectionPlayerNumbersTimer()
{
	SetTimer(1.0f, true, 'CallUpdateClassSelectionPlayerNumbers');
}

reliable server function ClearUpdateClassSelectionPlayerNumbersTimer()
{
	ClearTimer('CallUpdateClassSelectionPlayerNumbers');
}

function CallUpdateClassSelectionPlayerNumbers()
{
	UpdateClassSelectionPlayerNumbers(WorldInfo.GRI.Teams[0].Size, WorldInfo.GRI.Teams[1].Size);
}

reliable client function UpdateClassSelectionPlayerNumbers(int numBluePlayers, int numYellowPlayers)
{
	if(HLW_ClassSelectionMenu(Menu) != none)
	{
		HLW_ClassSelectionMenu(Menu).UpdatePlayerNumbers(numBluePlayers, numYellowPlayers);
	}
}

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	local int i;
	local HLW_PlayerReplicationInfo HLW_PRI;
	super.Possess(aPawn, bVehicleTransition);

	HLW_PRI = HLW_PlayerReplicationInfo(PlayerReplicationInfo);

	// If we have aquired our class pawn and have all of the necessary variables, try to set up the abilities array in the rep info
	if (aPawn != none && aPawn.IsA('HLW_Pawn_Class') && HLW_PRI != none)
	{
		// If the abilities are not already initialized
		if (!HLW_PRI.bAbilitiesInitialized)
		{
			//`log("          PC Initializing Abilities");
			for(i = 0; i < 5; i++)
			{
				//`log("Ability " @ i @ " will be a " @ HLW_Pawn_Class(aPawn).AbilityClasses[i]);
				HLW_PRI.Abilities[i] = Spawn(HLW_Pawn_Class(aPawn).AbilityClasses[i], self);
				HLW_PRI.Abilities[i].AbilityIndex = i;
			}

			HLW_PRI.bAbilitiesInitialized = true;
		}
	}
}

function PawnDied(Pawn P)
{
	local int i;
	
	if(HLW_Camera(PlayerCamera).CameraStyle  == 'FirstPerson')
	{
		SwitchOnDeath();
	}
	
	//ATTEMPT TO FIX PERMA STUN AFTER DEATH - CONNOR P
	
	KillPlayerByte++;
	
	bIsCasting = false;
	bCanUseAbilities = true;
	bCanAttackPrimary = true;
	bCanAttackSecondary = true;
	bCanAcceptLookInput = true;
	
	// If the abilities are already initialized
	if (HLW_PlayerReplicationInfo(PlayerReplicationInfo).bAbilitiesInitialized)
	{
		for(i = 0; i < 5; i++)
		{
			HLW_PlayerReplicationInfo(PlayerReplicationInfo).Abilities[i].AbilityComplete(true);
		}
	}
	
	/////////////////////////////////////
	
	

	if (HLW_HUD_Class(myHUD) != none)
	{
		P.Health = 0;
		HLW_HUD_Class(myHUD).HealthAndManaComponentHUD.CallUpdateCurrentHealth(0);
		HLW_HUD_Class(myHUD).HealthAndManaComponentHUD.CallUpdateMaxHealth(P.HealthMax);
	}

	HLW_GoToState('PlayerWalking');
	
	super.PawnDied(P);
	
	// This is where we would alert the player they are waiting to respawn, and most likely set a world timer to respawn 
	// Anyone waiting to spawn

	if(bSuicided)
	{
		SetTimer(SuicideRespawnTime, false, 'ResetPlayer');
		bSuicided = false;
	}
	else
	{
		SetTimer(RespawnTime, false, 'ResetPlayer');
		bSuicided = false;
	}
}

reliable client function ClientKillPlayer()
{
	local byte i;
	
	bIsCasting = false;
	bCanUseAbilities = true;
	bCanAttackPrimary = true;
	bCanAttackSecondary = true;
	bCanAcceptLookInput = true;

	for(i = 0; i < 5; i++)
	{
		HLW_PlayerReplicationInfo(PlayerReplicationInfo).Abilities[i].AbilityComplete(true);
	}

	if (HLW_HUD_Class(myHUD) != none)
	{
		HLW_HUD_Class(myHUD).HealthAndManaComponentHUD.CallUpdateCurrentHealth(0);
		HLW_HUD_Class(myHUD).HealthAndManaComponentHUD.CallUpdateMaxHealth(0);
	}
}

function ResetPlayer()
{
	// For now we will call Set Pawn, but we should move this to the game info and 
	// Have a list to loop through to call the SetPawn function
	if(HLW_PlayerReplicationInfo(PlayerReplicationInfo).Team != None)
	{
		SetPawn(HLW_PlayerReplicationInfo(PlayerReplicationInfo).classSelection, HLW_PlayerReplicationInfo(PlayerReplicationInfo).Team.TeamIndex, true);
	}
	else
	{
		SetPawn(HLW_PlayerReplicationInfo(PlayerReplicationInfo).classSelection, 255, true);	
	}
}

function CloseEscapeMenu()
{
	EscapeMenu.Close(true);
}

function IncrementSurrenderCounter(int increment)
{
	ServerIncrementSurrenderCounter(increment);
}

reliable server function ServerIncrementSurrenderCounter(int increment)
{
	if(increment == 0)
	{
		HLW_TeamInfo(PlayerReplicationInfo.Team).SurrenderCounter = increment;
	}
	else
	{
		HLW_TeamInfo(PlayerReplicationInfo.Team).SurrenderCounter += increment;
	}
}

reliable client function SendTextToServer(string message, optional bool isTeamChat = false, optional bool isSystemMessage = false, optional int chatTypeIn)
{
	ServerReceiveText(message, isTeamChat, isSystemMessage, chatTypeIn);
}

//reliable client function SendDeathMSG(HLW_PlayerController HLW_PC, string textToSend)
//{
//	ServerReceiveDeathMSG(HLW_PC, textToSend);
//}

reliable server function ServerReceiveText(string message, optional bool isTeamChat = false, optional bool isSystemMessage = false, optional int chatTypeIn)
{
	if(isSystemMessage)
	{
		HLW_GameType(WorldInfo.Game).BroadcastMessage(none, message, isTeamChat, ChatTypes.SYSTEM_MESSAGE);
	}
	else
	{
		HLW_GameType(WorldInfo.Game).BroadcastMessage(self, message, isTeamChat, chatTypeIn);
	}
}

//reliable server function ServerReceiveDeathMSG(HLW_PlayerController HLW_PC, string receivedText)
//{
//	WorldInfo.Game.Broadcast(HLW_PC, receivedText);
//}

reliable client function ReceiveBroadcast(string playerName, string receivedText, int chatTypeIn)
{
	if(myHUD != none)
	{
		if(playerName == "")
		{
			HLW_HUD_Class(myHUD).ChatWindowComponentHUD.UpdateChatLog(receivedText, ChatTypes.SYSTEM_MESSAGE);
		}
		else
		{
			HLW_HUD_Class(myHUD).ChatWindowComponentHUD.UpdateChatLog(playerName @ ": " @ receivedText, chatTypeIn);
		}
	}
}

reliable server function ServerEndGame()
{
	WorldInfo.Game.EndGame(none, "triggered");
}

// This still needs work ~Paul O.
//exec function ToggleDebugInfo()
//{
//    bIsDebug = !bIsDebug;
//}

function QuitToMenu()
{
	bQuittingToMainMenu = true;

	if(!CleanupOnlineSubsystemSession(true))
	{
		//`log("HLW_PlayerController::QuitToMainMenu()  - Online cleanup failed, finishing quit.");
		FinishQuitToMainMenu();
	}
}

function FinishQuitToMainMenu()
{
	ConsoleCommand("Disconnect");
}

function bool CleanupOnlineSubsystemSession(bool bWasFromMenu)
{
	local OnlineGameSettings CurrentGameSettings;
	local bool bSuccess;

	if(WorldInfo.NetMode != NM_Standalone && OnlineSub != none && OnlineSub.GameInterface != none)
	{
		CurrentGameSettings = OnlineSub.GameInterface.GetGameSettings('Game');
	}

	if(CurrentGameSettings != none)
	{
		if(CurrentGameSettings.GameState != OGS_InProgress)
		{
			OnlineSub.GameInterface.AddDestroyOnlineGameCompleteDelegate(OnDestroyOnlineGameComplete);
			OnlineSub.GameInterface.DestroyOnlineGame('Game');
		}
		else
		{
			// Set the end delegate so we can know when that is complete and call destroy
			OnlineSub.GameInterface.AddEndOnlineGameCompleteDelegate(OnEndOnlineGameComplete);
			OnlineSub.GameInterface.EndOnlineGame('Game');
		}

		bSuccess = true;
	}

	return bSuccess;
}

/**
 * Called when the online game has finished ending.
 */
function OnEndOnlineGameComplete(name SessionName, bool bWasSuccessful)
{
	OnlineSub.GameInterface.ClearEndOnlineGameCompleteDelegate(OnEndOnlineGameComplete);

	if (bQuittingToMainMenu)
	{
		// Now we can destroy the game (NOTE: If DestroyOnlineGame returns false, it will still trigger the delegate)
		OnlineSub.GameInterface.AddDestroyOnlineGameCompleteDelegate(OnDestroyOnlineGameComplete);
		OnlineSub.GameInterface.DestroyOnlineGame('Game');
	}
}

/**
 * Called when the destroy online game has completed. At this point it is safe
 * to travel back to the menus
 *
 * @param SessionName the name of the session the event is for
 * @param bWasSuccessful whether it worked ok or not
 */
function OnDestroyOnlineGameComplete(name SessionName, bool bWasSuccessful)
{
	OnlineSub.GameInterface.ClearDestroyOnlineGameCompleteDelegate(OnDestroyOnlineGameComplete);
	FinishQuitToMainMenu();
}

exec function OpenEscapeMenu()
{
	if(Role < ROLE_Authority)
	{
		if(SelectionMenu != none && SelectionMenu.bMovieIsOpen)
		{
			SetCinematicMode(false, false, true, true, true, true);
			PlayerInput.ResetInput();
			SelectionMenu.ClearCaptureKeys();
			SelectionMenu.Close(false);
			return;
		}

		if( HLW_HUD_Class(myHUD) != none && HLW_HUD_Class(myHUD).ChatWindowComponentHUD.bChatting)
		{
			PlayerInput.ResetInput();
			HLW_HUD_Class(myHUD).ChatWindowComponentHUD.bCaptureInput = false;
			HLW_HUD_Class(myHUD).ChatWindowComponentHUD.OnChatSend(0);
			return;
		}

		if(EscapeMenu == none)
		{
			EscapeMenu = new EscapeMenuClass;
			EscapeMenu.Init();

			return;
		}

		if (EscapeMenu.bMovieIsOpen)
		{
			EscapeMenu.CloseMenu();
		}
		else
		{
			EscapeMenu.OpenMenu();
		}
	}
}

exec function QuitGame()
{
	// TODO: Make this open a menu or options or something like that.
	// For now it just exits the game ~Paul O.
	ConsoleCommand("quit");
}

reliable client function PlayMusic(SoundCue inMusic)
{
	`log("PLAY TIME LIMIT MUSIC:"@inMusic);
	PlaySound(inMusic, true,,, Location);
}

exec function SelectClass()
{
	if(WorldInfo.GetMapName() == "HLW_Tutorial")
	{
		if(SelectionMenu == none)
		{
			SelectionMenu = new SelectionMenuClass;
			SelectionMenu.SetTimingMode(TM_Real);
			SelectionMenu.OpenMenu();
		}
		else
		{
			SelectionMenu.OpenMenu();
		}

		SelectionMenu.bCalledFromSpectatorMode = false;

		SetCinematicMode(true, false, true, true, true, true);
		SelectionMenu.UnrealInit(false);
	}
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
}

simulated event PlayerTick(float DeltaTime)
{
	local HLW_HUD_Class HudClass;
	local HLW_PlayerReplicationInfo PRI;

	super.PlayerTick(DeltaTime);

	HudClass = HLW_HUD_Class(myHUD);
	PRI = GetPRI();

	if(PRI != none && PRI.Abilities[0] != None)
	{
		if (HudClass != none && HLW_Pawn_Class(Pawn) != none && HLW_Pawn_Class(Pawn).GetPRI() != none)
		{
			HudClass.GameTimerComponentHUD.CalculateGameTime(HLW_GameReplicationInfo(WorldInfo.GRI).MatchTimer);
			//HudClass.FinanceComponentHUD.CallUpdateGold(PRI.Gold);
			//HudClass.FinanceComponentHUD.CallUpdateIncome(PRI.Income);
			//HudClass.FinanceComponentHUD.CallUpdateIncomeTime(HLW_Pawn_Class(Pawn).GetRemainingTimeForTimer('PayIncome') + 1);
			HudClass.CharacterComponentHUD.CallUpdateExperience(PRI.ExperienceMax, PRI.Experience);
			HudClass.CharacterComponentHUD.CallUpdateKills(PRI.HLW_Kills);
			HudClass.CharacterComponentHUD.CallUpdateDeaths(PRI.Deaths);
			HudClass.CharacterComponentHUD.CallUpdateAssists(0);
		
			if(PRI.UpgradePoints != 0)
			{
				HudClass.AbilityComponentHUD.CallAbilityPointAvailable(PRI.UpgradePoints);
			}
			else
			{
				HudClass.AbilityComponentHUD.CallStopAbilityAvailable();
			}
		}
	}
}

unreliable server function SetPawnGroundSpeed(float NewGroundSpeed)
{
	if(Pawn != None)
	{
		Pawn.GroundSpeed = NewGroundSpeed;	
	}
}

exec function DoDamageDraw()
{
	DrawDamage(99, "None");	
}

unreliable client function PushDamageMessage(string DamageAmount, Color MessageColor)
{
	if(HLW_HUD_Class(myHUD) != None)
	{
		//`log("HLW_PC Call HUD PushDamageMessage");
		HLW_HUD_Class(myHUD).PushDamageMessage(DamageAmount, MessageColor);
	}	
}

unreliable client function DrawDamage(int DamageAmount, string DamageType)
{
	//`log("HLW_PC Call PushDamageMessage");
	PushDamageMessage(string(DamageAmount), GetDamageColor(DamageType));
}

unreliable client function Color GetDamageColor(string DamageType)
{
	local Color DamageColor;
	
	switch(DamageType)
	{
		case "Physical":
			DamageColor.R = 255;
			DamageColor.G = 0;
			DamageColor.B = 0;
			DamageColor.A = 1;
			break;
		case "Magical":
			DamageColor.R = 0;
			DamageColor.G = 0;
			DamageColor.B = 255;
			DamageColor.A = 1;
			break;
		case "Pure":
			DamageColor.R = 255;
			DamageColor.G = 255;
			DamageColor.B = 255;
			DamageColor.A = 1;
			break;
		default:
			DamageColor.R = 0;
			DamageColor.G = 255;
			DamageColor.B = 0;
			DamageColor.A = 1;
			break;
	}
	
	return DamageColor;
}

reliable server function setCreepNumber(int newCreepNumber)
{
	//`log("Playercontroller setCreepNumber ( " @ newCreepNumber @ " ) ");
	HLW_PlayerReplicationInfo(PlayerReplicationInfo).SetSelectedCreep(newCreepNumber);
	PCCreepNumber =  HLW_PlayerReplicationInfo(PlayerReplicationInfo).SelectedCreep;
}

function getPCCreepNumber()
{
	HLW_HUD_Class(myHUD).getCreepNumber();
}

exec function EnterSprint()
{
	//bSprinting=true;
	//PlayerInput.MoveStrafeSpeed = 1200 / 3;
	//`log("EnterSprint");
}
exec function ExitSprint()
{
	//bSprinting=false;
	//PlayerInput.MoveStrafeSpeed = 1200;
	//`log("ExitSprint");
}

exec function StartFire(optional byte FireModeNum)
{
	//`log("PC:: Global StartFire - CanAttackPrimary:"@bCanAttackPrimary);
	if (bCanAttackPrimary)
	{
		super.StartFire(FireModeNum);
	}
}

exec function StartAltFire(optional byte FireModeNum)
{
	//`log("PC:: Global StartAltFire - CanAttackPrimary:"@bCanAttackSecondary);
	if (bCanAttackSecondary)
	{
		super.StartAltFire(FireModeNum);
	}
}

function HLW_Ability GetAbility(int index)
{
	local HLW_PlayerReplicationInfo HLW_PRI;
	HLW_PRI = HLW_PlayerReplicationInfo(PlayerReplicationInfo);

	if (HLW_PRI == none)
	{
		//`log("ERROR in HLW_PlayerController.GetAbility(): PRI is not valid");
		return none;
	}

	if (index >= 0 && index < 5)
	{
		return HLW_PRI.Abilities[index];
	}

	//`log("ERROR in HLW_PlayerController.GetAbility(): index of " @ index @ " is not valid");
}

function bool CanUseAbility(HLW_Ability Ability)
{
	local HLW_PlayerReplicationInfo HLW_PRI;
	local HLW_Pawn Pawn_HLW;

	HLW_PRI = HLW_PlayerReplicationInfo(PlayerReplicationInfo);
	Pawn_HLW = HLW_Pawn(Pawn);

    if (HLW_PRI != none && Pawn_HLW != none)
    {
		// CJL Need to make our own stunned state
		if (!IsInState('Stunned') && !bIsCasting && !Pawn_HLW.IsStunned() && bCanUseAbilities)
		{
		    if (NumFreeAbilities > 0)
		    {
		        return true;
		    }
        
			return HLW_PRI.Mana >= Ability.ManaCost.CurrentValue && Ability.CanBeCast();
		}
    }

    return false;
}

exec function SpendUpgradePoint(byte abilityIndex)
{
	local HLW_Ability AbilityToLevel;

	//`log("LEVEL UP ABILITY " @ abilityIndex);

	if (GetPRI() != none && (GetPRI().UpgradePoints > 0 || abilityIndex == 4))
	{
		if (abilityIndex == 5)
		{
			//GetPRI().IncreaseStats(0.6f);
			//GetPRI().SetUpgradePoints(GetPRI().UpgradePoints - 1);
		}
		else
		{
			AbilityToLevel = GetAbility(abilityIndex);
			
			if (AbilityToLevel != none)
			{
				HLW_HUD_Class(myHUD).AbilityComponentHUD.CallAbilityLevelUp(abilityIndex, AbilityToLevel.AbilityLevel + 1);
				ServerLevelUpAbility(abilityIndex);
			}
		}
	}
}


reliable server function ServerLevelUpAbility(byte abilityIndex)
{
	local HLW_Ability AbilityToLevel;
	AbilityToLevel = GetAbility(abilityIndex);

	if (GetPRI() != none && (GetPRI().UpgradePoints > 0 || abilityIndex == 4) && AbilityToLevel != none)
	{
		AbilityToLevel.LevelUp();

		if(abilityIndex != 4)
		{
			GetPRI().SetUpgradePoints(GetPRI().UpgradePoints - 1);
		}
	}
}

// Gets called when the 1-4 keys are pressed.
exec function BeginAbility(byte abilityIndex)
{
	AimingAbilityIndex = abilityIndex;
	
	AimingAbility = GetAbility(abilityIndex);

	if (AimingAbility != none && CanUseAbility(AimingAbility))
	{
		// This is to stop firing if the button is held down when an ability is about to start being aimed
		// Might need to account for other fire modes?
		StopFire(0);
		StopAltFire(0);
		StopBlock();

		if (AimingAbility.AimType == HLW_AAT_Instant)
		{
			StartCastingAbility(true);
		}
		else
		{
			// Tell the server to change our state. This will happen on the client as well
			HLW_GoToState('PlayerAimingAbility');
		}
	}
}

/* ***************************
 * Aiming Ability State
 *****************************/
simulated state PlayerAimingAbility extends PlayerWalking
{
	simulated event BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		// CJL add checks for aiming ability here and possibly cleanly break out if it's none
		StartAimingAbility(true);
	}
	
	exec function BeginAbility(byte abilityIndex)
	{
		local HLW_Ability DesiredAbility;

		// If the key pressed is the same as the one we're aiming, use the ability
		if (abilityIndex == AimingAbilityIndex)
		{
			StartFire();
		}
		else // Otherwise, restart the aiming state with the new ability, if we can
		{
			DesiredAbility = GetAbility(abilityIndex);

			if (DesiredAbility != none && CanUseAbility(DesiredAbility))
			{
				StopAimingAbility(false);

				AimingAbility = DesiredAbility;
				AimingAbilityIndex = abilityIndex;

				StartAimingAbility(false);
			}
		}
	}
	
	simulated function PausedState()
	{
		bStunned = true;
	}
	
	exec function StartFire(optional byte FireModeNum)
	{
		if(!AimingAbility.bInvalidHitLocation)
		{
			StartCastingAbility(true);
			HLW_GoToState('PlayerWalking');
		}
	}
	
	exec function StartAltFire(optional byte FireModeNum)
	{
		StopAimingAbility(true);
		HLW_GoToState('PlayerWalking');
	}
	
	exec function StartBlock()
	{
		StopAimingAbility(true);
		HLW_GoToState('PlayerWalking');
		
		//Global.StartBlock(); //Uncomment if you want block to activate on ability cancel
	}
	
	exec function StopBlock()
	{
		StopAimingAbility(true);
		HLW_GoToState('PlayerWalking');
	}

	simulated event EndState(name NextStateName)
	{	
		
		if (AimingAbility != none && AimingAbility.IsInState('Aiming'))
		{
			StopAimingAbility(true);
		}

		super.EndState(NextStateName);
	}
}

simulated function StartAimingAbility(bool bNotifyServer)
{
	HLW_Pawn_Class(Pawn).AbilityBeingAimed(AimingAbility);

	// We need to allow the server to get into the ability class, otherwise it can't call server functions
	if (Role < ROLE_Authority)
	{
		AimingAbility.StartAiming();

		if (bNotifyServer)
		{
			// Pass it the aiming ability index, since we know it's valid, and passing an Ability instance doesn't work
			ServerStartAimingAbility(AimingAbilityIndex);
		}
	}
}

reliable server function ServerStartAimingAbility(byte index)
{
	if (Role == ROLE_Authority)
		GetAbility(index).StartAiming();
}

simulated function StopAimingAbility(bool bNotifyServer)
{
	HLW_Pawn_Class(Pawn).AbilityEndingAim(AimingAbility);

	// We need to allow the server to get into the ability class, otherwise it can't call server functions
	if (Role < ROLE_Authority)
	{
		AimingAbility.StopAiming();
		AimingAbility.StopAimAnimation();
		AimingAbility.HideTheDangDecal();

		if (bNotifyServer)
		{
			// Pass it the aiming ability index, since we know it's valid, and passing an Ability instance doesn't work
			ServerStopAimingAbility(AimingAbilityIndex);
		}
	}
}



reliable server function ServerStopAimingAbility(byte index)
{
	if (Role == ROLE_Authority)
		GetAbility(index).StopAiming();
}

simulated function StartCastingAbility(bool bNotifyServer)
{
	local bool bIsFreeAbility;
	
	bIsFreeAbility = false;
	bIsCasting = true;

	HLW_Pawn_Class(Pawn).AbilityBeingCast(AimingAbility);

	ServerNotifyAbilitiesOfCast(AimingAbility.AbilityIndex);

	if (NumFreeAbilities > 0)
	{
		bIsFreeAbility = true;
		ServerConsumeFreeAbility();
	}

	// We need to allow the server to get into the ability class, otherwise it can't call server functions
	if (Role < ROLE_Authority)
	{
		AimingAbility.StartCasting(,bIsFreeAbility);

		if (bNotifyServer)
		{
			// Pass it the aiming ability index, since we know it's valid, and passing an Ability instance doesn't work
			ServerStartCastingAbility(AimingAbilityIndex, bIsFreeAbility);
		}
	}
}

reliable server function ServerNotifyAbilitiesOfCast(byte IndexOfAbilityBeingCast)
{
	local int i;
	local HLW_Ability AbilityBeingCast;

	if (GetPRI() != none)
	{
		AbilityBeingCast = GetAbility(IndexOfAbilityBeingCast);

		for (i = 0; i < 5; i++)
		{
			if (GetPRI().Abilities[i] != none && GetPRI().Abilities[i] != AbilityBeingCast)
			{
				GetPRI().Abilities[i].OwnerCastingAbility(AbilityBeingCast);
			}
		}
	}
}

reliable server function ServerStartCastingAbility(byte index, bool bIsFree)
{
	if (Role == ROLE_Authority)
	{
		GetAbility(index).StartCasting(,bIsFree);
	}
}

reliable server function ServerConsumeFreeAbility()
{
    NumFreeAbilities = Max(NumFreeAbilities - 1, 0);
}

simulated function AbilityActivated(HLW_Ability Ability)
{
	//`log("PC:: Global AbilityActivated - Ability:"@Ability);
	bIsCasting = false;

	if (Ability != none)
	{
		if (Ability.bPreventsOtherAbilitiesWhileActive)
		{
			bCanUseAbilities = false;
		}

		if (Ability.bPreventsPrimaryAttacksWhileActive)
		{
			bCanAttackPrimary = false;
		}

		if (Ability.bPreventsSecondaryAttacksWhileActive)
		{
			bCanAttackSecondary = false;
		}

		if (Ability.bPreventsMoveInputWhileActive)
		{
			IgnoreMoveInput(true);
		}

		if (Ability.bPreventsLookInputWhileActive)
		{
			//bCanAcceptLookInput = false;
		}
	}
}

simulated function AbilityEnded(HLW_Ability Ability)
{
	//`log("PC:: Global AbilityEnded - Ability:"@Ability);
	bIsCasting = false;

	if (Ability != none)
	{
		if (Ability.bPreventsOtherAbilitiesWhileActive)
		{
			bCanUseAbilities = true;
		}

		if (Ability.bPreventsPrimaryAttacksWhileActive)
		{
			bCanAttackPrimary = true;
		}

		if (Ability.bPreventsSecondaryAttacksWhileActive)
		{
			bCanAttackSecondary = true;
		}

		if (Ability.bPreventsMoveInputWhileActive)
		{
			IgnoreMoveInput(false);
		}

		if (Ability.bPreventsLookInputWhileActive)
		{
			//bCanAcceptLookInput = true;
		}
	}
}

simulated function StunPlayer(float Duration = 10.0)
{
	PushState('Stunned');
	bStunned = true;
	//HLW_GoToState('Stunned');
}



state Stunned
{
	function BeginState(Name PreviousStateName)
	{
		//local byte i;
		
		//super.BeginState(PreviousStateName);
		
		CachedPreviousState = PreviousStateName;
		
		//`log("STUN STATE");
		
		//for(i = 0; i < ArrayCount(GetPRI().Abilities); i++)
		//{
			//`log("Stun State: Telling Ability["$i$"] To Get Stunned");
			//GetPRI().Abilities[i].GotStunned();	
		//}

		bCanAttackPrimary = false;
		bCanAttackSecondary = false;
		bCanUseAbilities = false;
		bCanAcceptLookInput = false;
		IgnoreMoveInput(true);
		
		//Play Stun Animation
		SetTimer(10.0, false, 'GoToLastState');//Set Timer To End Stun
	}
	
	function PushedState()
	{
		//`log("STUN STATE PUSHED");
		bStunned = true;
		bCanAttackPrimary = false;
		bCanAttackSecondary = false;
		bCanUseAbilities = false;
		bCanAcceptLookInput = false;
		IgnoreMoveInput(true);
		
		//CachedPreviousState = PreviousStateName;
		SetTimer(10.0, false, 'PopToLastState');//Set Timer To End Stun
	}
	
	function PopToLastState()
	{
		//`log("POP STUN STATE");
		bStunned = false;
		bCanAttackPrimary = true;
		bCanAttackSecondary = true;
		bCanUseAbilities = true;
		bCanAcceptLookInput = true;
		IgnoreMoveInput(false);
		
		PopState();	
	}
	
	exec function StartFire(optional byte FireModeNum)
	{
		//StartCastingAbility(true);
		//HLW_GoToState('PlayerWalking');
	}
	
	exec function StartAltFire(optional byte FireModeNum)
	{
		//StopAimingAbility(false);
		//HLW_GoToState('PlayerWalking');
	}
	
	function GoToLastState()
	{
		if(CachedPreviousState != 'PlayerAimingAbility')
		{
			GoToState(CachedPreviousState);
		}
		else
		{
			GoToState('PlayerWalking');	
		}
	}
	
	function EndState(Name NextStateName)
	{
		//super.EndState(NextStateName);
		
		//`log("END STUN STATE");
		bStunned = false;
		bCanAttackPrimary = true;
		bCanAttackSecondary = true;
		bCanUseAbilities = true;
		bCanAcceptLookInput = true;
		IgnoreMoveInput(false);
	}	
}


state PlayerWalking
{
	function PlayerMove (float DeltaTime )
	{
		//local float changedGroundSpeed, defaultMoveSpeed;
		local bool MovingBackwards;
		local float BaseMovementSpeed, EndMovementSpeed;
		local HLW_Pawn_Class ClassPawn;

		Super.PlayerMove(DeltaTime);

		//if (bCanAcceptMoveInput)
		//{
			MovingBackwards = false;
			ClassPawn = HLW_Pawn_Class(Pawn);
			
			if(PlayerInput != None && ClassPawn != None && ClassPawn.GetPRI() != none)
			{
				BaseMovementSpeed = ClassPawn.GetPRI().MovementSpeed;
				EndMovementSpeed = BaseMovementSpeed;
				ClassPawn.bIsMovingBackwards = false;
				ClassPawn.bIsStrafing = false;
				SetBackwards(ClassPawn.bIsMovingBackwards);
				SetStrafing(ClassPawn.bIsStrafing);
				
				if(PlayerInput.aBaseY < 0) // Moving backwards
				{
					ClassPawn.bIsMovingBackwards = true;
					SetBackwards(ClassPawn.bIsMovingBackwards);
					MovingBackwards = true;
					EndMovementSpeed *= ClassPawn.MoveBackwardPercentage;
				}
				else if (PlayerInput.aBaseY > 0) // Moving forwards
				{
					EndMovementSpeed *= bSprinting ?  ClassPawn.MoveSprintPercentage : 1.0;
				}
	
				// Strafing
				if(!MovingBackwards && PlayerInput.aStrafe != 0)
				{
					ClassPawn.bIsStrafing = true;
					SetStrafing(ClassPawn.bIsStrafing);
					EndMovementSpeed *= ClassPawn.MoveStrafePercentage;
				}
	
				if (Pawn.GroundSpeed != EndMovementSpeed)
				{
					if(HLW_Pawn_Class_Warrior(Pawn) != None )
					{
						if(!HLW_Pawn_Class_Warrior(Pawn).bIsCharging && !HLW_Pawn_Class_Warrior(Pawn).bIsChasing)
						{
							SetPawnGroundSpeed(EndMovementSpeed);//do nothing
						}
						
						//else
						//{
							//
						//}
					}
					else
					{
						SetPawnGroundSpeed(EndMovementSpeed);
					}
					
					
				}
			}
		//}
	}
	
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		//if((DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) && HLW_Pawn_Class_Warrior(Pawn) != None)
		//{
		//	DoubleClickDir = DCLICK_Active;
		//}
		//else if((DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) && HLW_Pawn_Class_Warrior(Pawn) != None)
		//{
		//	if(HLW_Pawn_Class(Pawn).Dodge(DoubleClickMove))
		//	{
		//		DoubleClickDir = DCLICK_Active;
		//	}
		//}

		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
	}
}

reliable server function SetStrafing(bool Strafing)
{
	if(Pawn != None)
		HLW_Pawn_Class(Pawn).bIsStrafing = Strafing;
}

reliable server function SetBackwards(bool BackingUp)
{
	if(Pawn != None)
		HLW_Pawn_Class(Pawn).bIsMovingBackwards = BackingUp;
}

function HLW_GoToState(optional name NewState, optional name Label, optional bool bForceEvents, optional bool bKeepStack)
{
	GotoState(NewState, Label, bForceEvents, bKeepStack);

	if (Role < ROLE_Authority)
	{
		ServerGotoState(NewState);
	}
}

reliable server function ServerGotoState(optional name NewState, optional name Label, optional bool bForceEvents, optional bool bKeepStack)
{
	if (Role == ROLE_Authority)
	{
		HLW_GoToState(NewState, Label, bForceEvents, bKeepStack);
	}
}

// CJL might want to allow a weapon swap here for mages even if they're aiming an ability?
exec function NextWeapon()
{
	if (!IsInState('PlayerAimingAbility') && !bIsCasting)
	{
		super.NextWeapon();
	}
}

exec function PrevWeapon()
{
	if (!IsInState('PlayerAimingAbility') && !bIsCasting)
	{
		super.PrevWeapon();
	}
}

function NotifyChangedWeapon(Weapon PrevWeapon, Weapon NewWeapon)
{
	local int i;

	super.NotifyChangedWeapon(PrevWeapon, NewWeapon);

	if (GetPRI() != none)
	{

		for (i = 0; i < 5; i++)
		{
			if (GetPRI().Abilities[i] != none)
			{
				GetPRI().Abilities[i].OwnerChangedWeapon(PrevWeapon, NewWeapon);
			}
		}
	}

}

exec function DebugAiming()
{
	AimingDebug = !AimingDebug;
}

exec function ChatHandler(string key)
{
	local HLW_HUD_ChatWindow chatWindow;

	PlayerInput.ResetInput();

	chatWindow = HLW_HUD_Class(myHUD).ChatWindowComponentHUD;

	if(!chatWindow.bChatting)
	{
		switch(key)
		{
			case "T":
				chatType = ChatTypes.TEAM_CHAT;
				break;
			case "Y":
				chatType = ChatTypes.ALL_CHAT;
				break;
			default:
				chatType = ChatTypes.ALL_CHAT;
		}

		SetTimer(0.1f, false, 'ActivateChat');
	}
	else
	{
		if(key == "Enter")
		{
			chatWindow.bCaptureInput = false;
			chatWindow.OnChatSend(chatType);
		}
	}
}

function ActivateChat()
{
	HLW_HUD_Class(myHUD).ChatWindowComponentHUD.OnChatInputClick(chatType);
}

//Functions for zooming in and out
reliable client function SwitchOnDeath()
{

	if(PlayerCamera != none && HLW_Camera(PlayerCamera).CameraStyle  == 'FirstPerson')
	{
		HLW_Camera(PlayerCamera).CameraStyle  = 'ThirdPerson';
		
		if(HLW_Pawn_Class(Pawn) != None)
		{
			HLW_Pawn_Class(Pawn).ThirdPerson.SetOwnerNoSee(false); 
			HLW_Pawn_Class(Pawn).Mesh.SetOwnerNoSee(true);
		}
	}
}

unreliable server function ServerUpdateCamera(vector CamLoc, int CamPitchAndYaw)
{
	if(PlayerCamera != none)
	{
		super.ServerUpdateCamera(CamLoc, CamPitchAndYaw);
	}
}

reliable client function ClientSetCameraClass()
{
	if(CameraStyle != '' && HLW_Camera(PlayerCamera).CameraStyle != CameraStyle)
	{
		SwitchCam();
	}
}

reliable client function ClientCloseStatsScreen()
{
	if(InGameStats != none && InGameStats.bMovieIsOpen)
	{
		InGameStats.HideStatsScreen();
	}
}

exec function OpenGameStats()
{
	`log("PlayerController::OpenGameStats - The tab key was pressed");
	if(!HLW_GameReplicationInfo(WorldInfo.GRI).bMatchInProgress)
	{
		return;
	}

	if(Role < ROLE_Authority)
	{
		if(InGameStats == none)
		{
			InGameStats = new InGameStatsScreenClass;
			InGameStats.Init();
		}

		InGameStats.OpenStatsScreen();
	}
}

exec function CloseGameStats()
{
	if(Role < ROLE_Authority)
	{
		if(InGameStats != none && InGameStats.bMovieIsOpen)
		{
			InGameStats.HideStatsScreen();
		}
	}
}

//exec function SetCam()
//{
	
//}

exec function SwitchCam()
{	
	if(HLW_Camera(PlayerCamera).CameraStyle  == 'ThirdPerson')
	{
		HLW_Camera(PlayerCamera).CameraStyle  = 'FirstPerson';
		HLW_Camera(PlayerCamera).FreeCamDistance  = 0;
		
		if(HLW_Pawn_Class(Pawn) != None)
		{
			HLW_Pawn_Class(Pawn).ThirdPerson.SetOwnerNoSee(true); 
			HLW_Pawn_Class(Pawn).Mesh.SetOwnerNoSee(false);
		}

		CameraStyle = 'FirstPerson';
	}
	else if(HLW_Camera(PlayerCamera).CameraStyle  == 'FirstPerson')
	{
		HLW_Camera(PlayerCamera).CameraStyle  = 'ThirdPerson';
		
		if(HLW_Pawn_Class(Pawn) != None)
		{
			HLW_Pawn_Class(Pawn).ThirdPerson.SetOwnerNoSee(false); 
			HLW_Pawn_Class(Pawn).Mesh.SetOwnerNoSee(true);
		}

		CameraStyle = 'ThirdPerson';
	}
}

//The player wants to block
exec function StartBlock()
{
	//`log("PC:: Global StartBlock - CanAttackSecondary:"@bCanAttackSecondary);
	if (bCanAttackSecondary)
	{
		if(HLW_Pawn_Class_Warrior(Pawn) != None)
		{
			HLW_Pawn_Class_Warrior(Pawn).bBlockHeld = true;
		}
	
		if ( WorldInfo.Pauser == PlayerReplicationInfo )
		{
			SetPause( false );
			return;
		}
	
		if ( HLW_Pawn_Class_Warrior(Pawn) != None && !bCinematicMode && !WorldInfo.bPlayersOnly /*&& !HLW_Melee_Weapon(Pawn.Weapon).bIsAttacking*/ )
		{
			HLW_Pawn_Class_Warrior(Pawn).StartBlock();
		}
	}
}

exec function StopBlock()
{
	//`log("PC:: Global StopBlock");
	
	if (Pawn == none || !Pawn.IsA('HLW_Pawn_Class_Warrior') || Pawn.Weapon == none /*|| !Pawn.Weapon.IsA('HLW_Melee_Weapon')*/)
	{
		//`log("PC:: Global StopBlock - Return");
		return;
	}

	HLW_Pawn_Class_Warrior(Pawn).bBlockHeld = false;
	
	if ( WorldInfo.Pauser == PlayerReplicationInfo )
	{
		SetPause( false );
		return;
	}
	
	if (!bCinematicMode && !WorldInfo.bPlayersOnly /*&& !HLW_Melee_Weapon(Pawn.Weapon).bIsAttacking*/)
	{
		//`log("Controller Stop Block");
		HLW_Pawn_Class_Warrior(Pawn).StopBlock();
	}
}

exec function StopFire( optional byte FireModeNum )
{
	//`log("PC:: Global StopFire - FireModeNum:"@FireModeNum);
	
	super.StopFire(FireModeNum);
	
	if(HLW_Ability_Barrage(GetAbility(4)) != None)
	{
		//`log("StopFire Barrage Exists");
		
		if(HLW_Ability_Barrage(GetAbility(4)).bIsActive)
		{
			//`log("StopFire Barrage Active");
			HLW_Ability_Barrage(GetAbility(4)).StopFire();
			ServerStopFire();
		}
	}
}

reliable server function ServerStopFire()
{
	HLW_Ability_Barrage(GetAbility(4)).ServerStopFire();
}

state Spectating
{
	function BeginState(name PreviousStateName)
	{
		`log("PlayerController::Spectating - The player is in spectating state " $self);

		super.BeginState(PreviousStateName);
	}

	exec function SelectClass()
	{
		if(HLW_GameReplicationInfo(WorldInfo.GRI).bMatchInProgress)
		{
			if(SelectionMenu == none)
			{
				SelectionMenu = new SelectionMenuClass;
				SelectionMenu.SetTimingMode(TM_Real);
				SelectionMenu.OpenMenu();
			}
			else
			{
				SelectionMenu.OpenMenu();
			}

			SelectionMenu.bCalledFromSpectatorMode = true;

			SetCinematicMode(true, false, true, true, true, true);
			SelectionMenu.UnrealInit(WorldInfo.GRI.GameClass == class'HLW_GameType_LineWars' || WorldInfo.GRI.GameClass == class'HLW_GameType_TDM');
		}
	}
}

/**
 * State Dead
 * 
 * Overriding the PlayerController's Dead state to disable UDK's default behavior of 
 * restarting the player by any input.
 * 
 * Epic does a lot of stuff in this state that we could potentially use, for now
 * just override the startfire call. AOC has their own dead state. 
 * ~Paul O.
 */
state Dead
{
	// Having this empty prevents the player being able to respawn before we want them to
	exec function StartFire( optional byte FireModeNum )
	{
		//`log("PC:: Dead StartFire - CanAttackPrimary:"@bCanAttackPrimary);
	}
}

state RoundEnded
{
	event BeginState(Name PreviousStateName)
	{
		if(Role < ROLE_Authority)
		{
			if(InGameStats != none && InGameStats.bMovieIsOpen)
			{
				InGameStats.Close(true);
			}
		}

		SwitchOnDeath();

		UnPossess();

		super.BeginState(PreviousStateName);

		SetTimer(2.0f, false, 'ShowEndGameScreen');
	}

	exec function StartFire( optional byte FireModeNum )
	{
		
	}

	function ShowEndGameScreen()
	{
		if(Role < ROLE_Authority)
		{
			HLW_HUD_Class(myHUD).CloseAllComponents();

			EndGameScreen = new EndGameScreenClass;
			EndGameScreen.Init();
		}
	}
}

simulated function HLW_PlayerReplicationInfo GetPRI()
{
	return HLW_PlayerReplicationInfo(PlayerReplicationInfo);
}

simulated function HLW_PlayerController GetPC()
{
	return self;
}

exec function MageTest()
{
	//SendTextToServer("HOLY BUCK I AM A MAGE",,, ChatTypes.SYSTEM_MESSAGE);
}

exec function WarriorTest()
{
	//SendTextToServer("HOLY BUCK I AM A WARRIOR",,, ChatTypes.SYSTEM_MESSAGE);
	//HLW_Pawn_Class_Warrior(Pawn).WarriorDanceTP();
}

exec function ArcherTest()
{
	//SendTextToServer("HOLY BUCK I AM AN ARCHER",,, ChatTypes.SYSTEM_MESSAGE);
}

defaultproperties
{
	AimingDebug=false
	ClassSelector=HLW_Class_Select'HLW_Package.Archetype.Class_Select_Archetype'
	StartMenuClass=class'HLW.HLW_MainMenu'
	EndGameScreenClass=class'HLW.HLW_Gfx_EndGameScreen'
	InGameStatsScreenClass=class'HLW.HLW_Gfx_InGameStatsScreen'
	SelectionMenuClass=class'HLW.HLW_ClassSelectionMenu'
	EscapeMenuClass=class'HLW.HLW_Gfx_EscapeMenu'

	AimingAbilityIndex=-1
	CameraClass=class'HLW_Camera'
	bSprinting=FALSE
	bIsCasting=false
	bCanUseAbilities=true
	bCanAttackPrimary=true
	bCanAttackSecondary=true
	bCanAcceptLookInput=true

	bDidChangeOne=false
	bDidChangeTwo=false
	bDidChangeThree=false
	bDidChangeFour=false
	
	CachedCameraType=0
	KillPlayerByte=0
	
	SuicideRespawnTime=8
	RespawnTime=2.5
}
