class HLW_HUD_Power_GFX extends GFxMoviePlayer;

function bool Start(optional bool StartPaused = false)
{	
	Super.Start(StartPaused);
		SetViewScaleMode(SM_ExactFit);
        Advance(0);
	return TRUE;
}

simulated function CallUpdatePower(int CurrentPower)
{
	ActionScriptVoid("_root.UpdatePower");	
}

simulated function CallUpdateUp(float CurrentState)
{
	ActionScriptVoid("_root.UpdateUp");
}

simulated function CallUpdateDown(float CurrentState)
{
	ActionScriptVoid("_root.UpdateDown");
}

defaultproperties
{
	MovieInfo=SwfMovie'HLW_CONNOR_PAKAGE.HUD.ArcherComponent'
	
	//Playback
	bAutoPlay=TRUE

	bAllowInput=false
	bAllowFocus=FALSE
	bCaptureInput=false
}