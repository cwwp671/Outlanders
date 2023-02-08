/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Gfx_InGameStatsScreen extends HLW_Gfx_EndGameScreen;

function Init(optional LocalPlayer Player)
{
	LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(Player);
	if(LocalPlayerOwnerIndex == INDEX_NONE)
	{
		LocalPlayerOwnerIndex = 0;
	}

	if(GetPC().WorldInfo.GRI.GameClass == class'HLW_GameType_LineWars' || GetPC().WorldInfo.GRI.GameClass == class'HLW_GameType_TDM')
	{
		bIsTeamGame = true;
	}

	SetViewScaleMode(SM_ExactFit);

	SetTimingMode(TM_Real);
}

function OpenStatsScreen()
{
	if(!bMovieIsOpen)
	{
		Start();
		Advance(0.f);

		PrepareStatsToSendToAs();
	}
}

function HideStatsScreen()
{
	Close(false);
}

DefaultProperties
{
	bShowHardwareMouseCursor=false
	bCaptureMouseInput=false
	bCaptureInput=false
}
