/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_HUD_Reticule_GFX extends GFxMoviePlayer;

function bool Start(optional bool StartPaused = false)
{	
	Super.Start(StartPaused);
		SetViewScaleMode(SM_ExactFit);
        Advance(0);
	return TRUE;
}

defaultproperties
{
	MovieInfo=SwfMovie'HLW_CONNOR_PAKAGE.HUD.Reticule'
	
	//Playback
	bAutoPlay=TRUE

	bAllowInput=false
	bAllowFocus=FALSE
	bCaptureInput=false
}