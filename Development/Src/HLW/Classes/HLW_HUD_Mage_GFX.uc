/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_HUD_Mage_GFX extends HLW_HUD_Class_GFX;

defaultproperties
{
	//Datastore
	
	//Display
	bDisplayWithHudOff=FALSE
	bEnableGammaCorrection=FALSE
	bForceFullViewport=TRUE
	
	//General
	MovieInfo=SwfMovie'HLW_Package.HUD.MageUI'
	
	//Input
	bAllowInput=false
	bAllowFocus=FALSE
	bCaptureInput=false
	
	//Playback
	bAutoPlay=TRUE
	
	//Sound
}