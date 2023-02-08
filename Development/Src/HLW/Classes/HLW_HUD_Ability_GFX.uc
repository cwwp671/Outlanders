/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_HUD_Ability_GFX extends GFxMoviePlayer;

function bool Start(optional bool StartPaused = false)
{	
	//local int ResX, ResY;
	
	Super.Start(StartPaused);
        Advance(0);
        SetViewScaleMode(SM_ExactFit);
        
        //ResX = class'Engine'.static.GetEngine().GetSystemSettingInt("ResX");
		//ResY = class'Engine'.static.GetEngine().GetSystemSettingInt("ResY");

		//SetViewport(0, 0, ResX, ResY);
	return TRUE;
}

// When an ability point is available
simulated function CallAbilityPointAvailable(int Points)
{
	ActionScriptVoid("_root.AbilityPointAvailable");
}

simulated function CallStopAbilityAvailable()
{
	ActionScriptVoid("_root.StopAbilityAvailable");	
}

// Initializing of abilities
simulated function CallCreateAbility(int AbilityNumber, string AbilityName, int CharIndex)
{
	ActionScriptVoid("_root.CreateAbility");
}
		
// When an ability levels up
simulated function CallAbilityLevelUp(int AbilityNumber, int Rank)
{
	ActionScriptVoid("_root.AbilityLevelUp");
}

// Ability tick (manages cooldown, mana cost, and active state)
simulated function CallAbilityUpdate(int AbilityNumber, float CooldownTime, bool EnoughMana, bool IsActive)
{
	ActionScriptVoid("_root.AbilityUpdate");
}

defaultproperties
{
	MovieInfo=SwfMovie'HLW_CONNOR_PAKAGE.HUD.AbilitySquares4'
	
	//Playback
	bAutoPlay=TRUE

	bAllowInput=false
	bAllowFocus=FALSE
	bCaptureInput=false
}