/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_HUD_Creep_GFX extends GFxMoviePlayer;

var HLW_GameType game;
var GFxObject RootMC;

var int GFXCreepNumber;

function Init(Optional LocalPlayer LocPlay)
{
	super.Init(LocPlay);
	RootMC = GetVariableObject("_root");		
}

function getCreepNumber(int creepNumber)
{
	//`log("getCreepNumber GFX");
	GFXCreepNumber = creepNumber;
	HLW_PlayerController(GetPC()).setCreepNumber(GFXCreepNumber);
	HLW_Pawn_Class(GetPC().Pawn).startSpawnCooldown();
}

function bool Start(optional bool StartPaused = false)
{	
	Super.Start(StartPaused);
		SetViewScaleMode(SM_ExactFit);
        Advance(0);
	return TRUE;
}

function int getGFXCreepNumber()
{
	return GFXCreepNumber;
}




defaultproperties
{
	MovieInfo=SwfMovie'HLW_CONNOR_PAKAGE.HUD.CreepHUDs'

	bDisplayWithHudOff=FALSE
	bEnableGammaCorrection=FALSE
	bAllowInput=TRUE
	bAllowFocus=TRUE
	bForceFullViewport=TRUE
	bAutoPlay=FALSE;
	
	GFXCreepNumber=1
}