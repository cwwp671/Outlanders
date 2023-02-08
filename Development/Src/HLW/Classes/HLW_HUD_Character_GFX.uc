/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_HUD_Character_GFX extends GFxMoviePlayer;

function bool Start(optional bool StartPaused = false)
{	
	//local int ResX, ResY;
	
	Super.Start(StartPaused);
		SetViewScaleMode(SM_ExactFit);
        Advance(0);
        
        //ResX = class'Engine'.static.GetEngine().GetSystemSettingInt("ResX");
		//ResY = class'Engine'.static.GetEngine().GetSystemSettingInt("ResY");

		//SetViewport(0, 0, ResX, ResY);
	return TRUE;
}

simulated function CallUpdateExperience(float MaxExperience, float CurrentExperience)
{
	ActionScriptVoid("_root.UpdateExperience");
}

simulated function CallUpdateLevel(float CurrentLevel)
{
	ActionScriptVoid("_root.UpdateLevel");
}

simulated function CallUpdateKills(float KillScore)
{
	ActionScriptVoid("_root.UpdateKills");
}

simulated function CallUpdateDeaths(float DeathScore)
{
	ActionScriptVoid("_root.UpdateDeaths");
}

simulated function CallUpdateAssists(float AssistScore)
{
	ActionScriptVoid("_root.UpdateAssists");
}

defaultproperties
{
	MovieInfo=SwfMovie'HLW_CONNOR_PAKAGE.HUD.CharacterComponent'
	
	//Playback
	bAutoPlay=TRUE

	bAllowInput=false
	bAllowFocus=FALSE
	bCaptureInput=false
}