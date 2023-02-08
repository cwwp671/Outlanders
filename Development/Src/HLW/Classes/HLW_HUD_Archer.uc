/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_HUD_Archer extends HLW_HUD_Class;

var HLW_HUD_Reticule_GFX ReticuleComponentHUD;
var HLW_HUD_Power_GFX PowerComponentHUD;

simulated event PostBeginPlay()
{	
	super.PostBeginPlay();
	
	ReticuleComponentHUD = new class'HLW_HUD_Reticule_GFX';
	ReticuleComponentHUD.SetTimingMode(TM_Real);
	//ReticuleComponentHUD.game = HLW_GameType(WorldInfo.Game); // Give the Movie player a reference to do things.
	ReticuleComponentHUD.Start();
	
	PowerComponentHUD = new class'HLW_HUD_Power_GFX';
	PowerComponentHUD.SetTimingMode(TM_Real);
	//PowerComponentHUD.game = HLW_GameType(WorldInfo.Game); // Give the Movie player a reference to do things.
	PowerComponentHUD.Start();
}

simulated event PostRender()
{
   super.PostRender();
}

simulated function DrawHUD()
{
	//if(HLW_Pawn_Class(PlayerOwner.Pawn).bHasDied)
	//{
		//ReticuleComponentHUD.Close();
	//}
	
	super.DrawHUD();	
}

function CloseAllComponents()
{
	PowerComponentHUD.Close(false);
	ReticuleComponentHUD.Close(false);

	super.CloseAllComponents();
}

event Destroyed()
{
	if(ReticuleComponentHUD != none)
	{
		ReticuleComponentHUD.Close(true);
	}

	if(PowerComponentHUD != none)
	{
		PowerComponentHUD.Close(true);
	}

	super.Destroyed();
}

defaultproperties
{
	HudMovieClass=class'HLW_HUD_Archer_GFX'
}