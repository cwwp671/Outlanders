/**
 * HLW_Gfx_InGameStatsScreen - Class to handle showing the stats during a match
 * extends upon the End Game Screen that is displayed at the end of a match.
 * Currently only updates when the screen is opened. Could add updating while the window is open
 * in future.
 * 
 * Original Author - Paul Ouellette
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
