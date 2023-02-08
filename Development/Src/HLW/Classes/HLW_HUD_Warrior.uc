/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_HUD_Warrior extends HLW_HUD_Class;

var HLW_HUD_Combo_GFX ComboComponentHUD;

simulated event PostBeginPlay()
{	
	ComboComponentHUD = new class'HLW_HUD_Combo_GFX';
	ComboComponentHUD.SetTimingMode(TM_Real);
	//ComboComponentHUD.game = HLW_GameType(WorldInfo.Game); // Give the Movie player a reference to do things.
	ComboComponentHUD.Start();
	
	super.PostBeginPlay();
}

simulated event PostRender()
{
   super.PostRender();
}

simulated function DrawHUD()
{
	//if(HLW_Pawn_Class(PlayerOwner.Pawn).bHasDied)
	//{
		//ComboComponentHUD.Close();
	//}
	
	super.DrawHUD();	
}

function CloseAllComponents()
{
	ComboComponentHUD.Close(false);

	super.CloseAllComponents();
}

event Destroyed()
{
	if(ComboComponentHUD != none)
	{
		ComboComponentHUD.Close(true);
	}

	super.Destroyed();
}

defaultproperties
{
	HudMovieClass=class'HLW_HUD_Warrior_GFX'
}