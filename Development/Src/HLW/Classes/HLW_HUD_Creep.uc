class HLW_HUD_Creep extends HUD;

var HLW_HUD_Creep_GFX HudMovie;

simulated event PostBeginPlay()
{
    HudMovie = new class'HLW_HUD_Creep_GFX';
	HudMovie.SetTimingMode(TM_Real);
	HudMovie.game = HLW_GameType(WorldInfo.Game); // Give the Movie player a reference to do things.
}

event PostRender()
{
   super.PostRender();
   //`log("Still Updating bitch");
}

exec function OpenHUD()
{
	// Not using this right now so just break out of the function
	return;
	//worldinfo.game.Broadcast(self,"OPEN HUD");
	
	if (!HudMovie.bMovieIsOpen)
	{
		HudMovie.Start();
	}
	
	HudMovie.SetPause(false);
	PlayerOwner.SetCinematicMode(true, false, false, false, true, false);
}

exec function CloseHUD()
{
	// Not using this right now so just break out of the function
	return;

	//worldinfo.game.Broadcast(self,"Close HUD");
	HudMovie.SetPause(true);
	HudMovie.Close(false);
	PlayerOwner.SetCinematicMode(false, false, false, false, true, false);
}

defaultproperties
{
}