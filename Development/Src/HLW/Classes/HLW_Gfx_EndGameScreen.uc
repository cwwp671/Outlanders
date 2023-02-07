/**
 * HLW_Gfx_EndGameScreen - Handles all funtionality associated with the
 * end game screens. Showing Deaths, Kills, Class, Level, ect...
 * 
 * Original Author: Paul Ouellette
 */

class HLW_Gfx_EndGameScreen extends GFxMoviePlayer;

var bool bIsTeamGame;

function Init(optional LocalPlayer player)
{
	super.Init(player);

	if(GetPC().WorldInfo.GRI.GameClass == class'HLW_GameType_LineWars' || GetPC().WorldInfo.GRI.GameClass == class'HLW_GameType_TDM')
	{
		bIsTeamGame = true;
	}

	Start();

	Advance(0);

	SetViewScaleMode(SM_ExactFit);

	PrepareStatsToSendToAs();

	AddFocusIgnoreKey('Escape');
	AddFocusIgnoreKey('Tab');
}

function UpdateServerRestartText(string serverRestartText)
{
	UnrealUpdateServerRestartText(bIsTeamGame, serverRestartText);
}

function UnrealUpdateServerRestartText(bool isTeamGame, string serverRestartText)
{
	ActionScriptVoid("root.UnrealUpdateServerRestartText");
}

function OnAsExitToMenuButtonClick()
{
	//GetPC().ClientEndOnlineGame();
	//GetPC().ClientTravel("HLW_MainMenu", TRAVEL_Absolute);
	HLW_PlayerController(GetPC()).QuitToMenu();
}

function PrepareStatsToSendToAs()
{
	local int i;
	local array<PlayerReplicationInfo> PRIArray;
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local GFxObject BlueTeamStats;
	local GFxObject YellowTeamStats;
	local int objectIndex;
	
	DataProvider = CreateArray();

	if(bIsTeamGame)
	{
		BlueTeamStats = CreateArray();
		YellowTeamStats = CreateArray();
	}

	PRIArray = GetPC().WorldInfo.GRI.PRIArray;
	objectIndex = 0;

	for (i = 0; i < PRIArray.Length; i++)
	{
		if(!PRIArray[i].bOnlySpectator)
		{
			TempObj = CreateObject("Object");

			TempObj.SetInt("Level", HLW_PlayerReplicationInfo(PRIArray[i]).Level);
			TempObj.SetString("Player", HLW_PlayerReplicationInfo(PRIArray[i]).PlayerName);

			switch(HLW_PlayerReplicationInfo(PRIArray[i]).classSelection)
			{
			case 1:
				TempObj.SetString("ClassName", "Mage");
				break;
			case 2:
				TempObj.SetString("ClassName", "Archer");
				break;
			case 3:
				TempObj.SetString("ClassName", "Warrior");
				break;
			case 4:
				TempObj.SetString("ClassName", "Barbarian");
				break;
			}

			TempObj.SetInt("Kills", HLW_PlayerReplicationInfo(PRIArray[i]).HLW_Kills);
			TempObj.SetInt("Deaths", HLW_PlayerReplicationInfo(PRIArray[i]).Deaths);
			TempObj.SetInt("Gold", 0); //HLW_PlayerReplicationInfo(PRIArray[i]).Gold
			TempObj.SetInt("DamageDone", HLW_PlayerReplicationInfo(PRIArray[i]).TotalDamageDone);
			TempObj.SetInt("DamageTaken", HLW_PlayerReplicationInfo(PRIArray[i]).TotalDamageTaken);

			if(bIsTeamGame)
			{
				if(PRIArray[i].Team.TeamIndex == 0)
				{
					BlueTeamStats.SetElementObject(objectIndex, TempObj);
				}
				else
				{
					YellowTeamStats.SetElementObject(objectIndex, TempObj);
				}
			}
			else
			{
				DataProvider.SetElementObject(objectIndex, TempObj);
			}

			objectIndex++;
		}
	}

	if(bIsTeamGame)
	{
		SetVariableObject("root.unrealBlueTeamStats", BlueTeamStats);
		SetVariableObject("root.unrealYellowTeamStats", YellowTeamStats);

		UpdateTeamStats(HLW_GameReplicationInfo(GetPC().WorldInfo.GRI).bMatchInProgress);
	}
	else
	{
		SetVariableObject("root.unrealFFAStatsList", DataProvider);

		UpdateFFAStats(HLW_GameReplicationInfo(GetPC().WorldInfo.GRI).bMatchInProgress);
	}
}

function UpdateFFAStats(bool matchInProgess)
{
	ActionScriptVoid("root.UnrealUpdateFFAStats");
}

function UpdateTeamStats(bool matchInProgess)
{
	ActionScriptVoid("root.UnrealUpdateTeamStats");
}

DefaultProperties
{
	MovieInfo=SwfMovie'HLW_Package_Paul.EndGameScreen.EndGameScreen'

	bAllowFocus=true
	bAllowInput=true
	bShowHardwareMouseCursor=true
	bIgnoreMouseInput=false
	bCaptureInput=true
	bCaptureMouseInput=true

	bForceFullViewport=true
}
