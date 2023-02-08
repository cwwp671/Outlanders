/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_HUD_Finance_GFX extends GFxMoviePlayer;

function bool Start(optional bool StartPaused = false)
{	
	Super.Start(StartPaused);
		SetViewScaleMode(SM_ExactFit);
        Advance(0);
	return TRUE;
}

simulated function CallUpdateGold(float SpendingMoney)
{
	ActionScriptVoid("_root.UpdateGold");
}

simulated function CallUpdateIncome(float PayCheck)
{
	ActionScriptVoid("_root.UpdateIncome");
}

simulated function CallUpdateIncomeTime(float WorkWeek)
{
	ActionScriptVoid("_root.UpdateIncomeTime");	
}
//fire 0
//ice 1
//lightning 2

defaultproperties
{
	MovieInfo=SwfMovie'HLW_CONNOR_PAKAGE.HUD.GoldComponent'
	
	//Playback
	bAutoPlay=TRUE

	bAllowInput=false
	bAllowFocus=FALSE
	bCaptureInput=false
}