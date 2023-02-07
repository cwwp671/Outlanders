class HLW_HUD_Mage extends HLW_HUD_Class;

var HLW_HUD_SpellSelector_GFX SpellSelectorComponentHUD;
var HLW_HUD_Reticule_GFX ReticuleComponentHUD;

simulated event PostBeginPlay()
{	
	super.PostBeginPlay();
	
	SpellSelectorComponentHUD = new class'HLW_HUD_SpellSelector_GFX';
	SpellSelectorComponentHUD.SetTimingMode(TM_Real);
	//SpellSelectorComponentHUD.game = HLW_GameType(WorldInfo.Game); // Give the Movie player a reference to do things.
	SpellSelectorComponentHUD.Start();
	
	ReticuleComponentHUD = new class'HLW_HUD_Reticule_GFX';
	ReticuleComponentHUD.SetTimingMode(TM_Real);
	//ReticuleComponentHUD.game = HLW_GameType(WorldInfo.Game); // Give the Movie player a reference to do things.
	ReticuleComponentHUD.Start();
}

simulated event PostRender()
{
   super.PostRender();
}

simulated function DrawHUD()
{
	//if(HLW_Pawn_Class(PlayerOwner.Pawn).bHasDied)
	//{
		//SpellSelectorComponentHUD.Close();
		//ReticuleComponentHUD.Close();
	//}
	
	super.DrawHUD();	
}

function CloseAllComponents()
{
	SpellSelectorComponentHUD.Close(false);
	ReticuleComponentHUD.Close(false);

	super.CloseAllComponents();
}

event Destroyed()
{
	if(SpellSelectorComponentHUD != none)
	{
		SpellSelectorComponentHUD.Close(true);
	}

	if(ReticuleComponentHUD != none)
	{
		ReticuleComponentHUD.Close(true);
	}

	super.Destroyed();
}

defaultproperties
{
	HudMovieClass=class'HLW_HUD_Mage_GFX'
}