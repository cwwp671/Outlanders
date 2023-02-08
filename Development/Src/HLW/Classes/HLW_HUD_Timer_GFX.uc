/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_HUD_Timer_GFX extends GFxMoviePlayer;

function bool Start(optional bool StartPaused = false)
{	
	Super.Start(StartPaused);
		SetViewScaleMode(SM_ExactFit);
        Advance(0);
	return TRUE;
}

simulated function CalculateGameTime(int ElapsedTime)
{
	local string GameTime;
	local int TimeMinutes;
	local int TimeSecondsOfMinute;
	
	// GRI.Elapsed time gives us only seconds. Math it for a 0:00 format
	TimeMinutes = ElapsedTime / 60;
	TimeSecondsOfMinute = ElapsedTime - (TimeMinutes * 60);
	GameTime = string(TimeMinutes)$":"$string(TimeSecondsOfMinute / 10)$string(TimeSecondsOfMinute - ((TimeSecondsOfMinute / 10) * 10));

	CallUpdateGameTime(GameTime);
}

simulated function CallUpdateGameTime(string GameTime)
{
	ActionScriptVoid("_root.UpdateGameTime");
}

defaultproperties
{
	MovieInfo=SwfMovie'HLW_CONNOR_PAKAGE.HUD.GameTimerComponent'
	
	//Playback
	bAutoPlay=TRUE

	bAllowInput=false
	bAllowFocus=FALSE
	bCaptureInput=false
}