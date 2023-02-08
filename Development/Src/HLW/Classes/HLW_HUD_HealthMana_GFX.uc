/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_HUD_HealthMana_GFX extends GFxMoviePlayer;

function bool Start(optional bool StartPaused = false)
{	
	Super.Start(StartPaused);
		SetViewScaleMode(SM_ExactFit);
        Advance(0);
	return TRUE;
}

simulated function CallUpdateCurrentHealth(float CurrentHealth)
{
	ActionScriptVoid("_root.UpdateCurrentHealth");
}

simulated function CallUpdateMaxHealth(float MaxHealth)
{
	ActionScriptVoid("_root.UpdateMaxHealth");
}

simulated function CallUpdateCurrentMana(float CurrentMana)
{
	ActionScriptVoid("_root.UpdateCurrentMana");
}

simulated function CallUpdateMaxMana(float MaxMana)
{
	ActionScriptVoid("_root.UpdateMaxMana");
}

defaultproperties
{
	MovieInfo=SwfMovie'HLW_CONNOR_PAKAGE.HUD.HealthAndManaComponent'
	
	//Playback
	bAutoPlay=TRUE
	bAllowInput=false
	bAllowFocus=FALSE
	bCaptureInput=false
}