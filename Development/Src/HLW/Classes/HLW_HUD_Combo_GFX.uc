class HLW_HUD_Combo_GFX extends GFxMoviePlayer;

function bool Start(optional bool StartPaused = false)
{	
	Super.Start(StartPaused);
		SetViewScaleMode(SM_ExactFit);
        Advance(0);
	return TRUE;
}

simulated function CallUpdateCombo(int numHits)
{
	ActionScriptVoid("_root.UpdateCombo");
}

defaultproperties
{
	MovieInfo=SwfMovie'HLW_CONNOR_PAKAGE.HUD.WarriorComponent'
	
	bAllowInput=false
	bAllowFocus=false
	bCaptureInput=false
}