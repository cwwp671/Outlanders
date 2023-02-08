/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */

class HLW_PlayerStart extends PlayerStart
	placeable;

// A reference to a trigger that will be used to enable / disable the player start
var HLW_Trigger TouchTrigger;

// The class of the trigger
var class<HLW_Trigger> TouchTriggerClass;


event PostBeginPlay()
{
	// Spawn the trigger
	TouchTrigger = Spawn(TouchTriggerClass);

	// Bind the delegates to our custom functions
	TouchTrigger.OnTouch = OnTriggerTouched;
	TouchTrigger.OnUnTouch = OnTriggerUnTouched;
}

/**
 * Function to bind to the trigger's OnTouch delegate to allow us to customize what happens when
 * the trigger gets touched
 */
simulated function OnTriggerTouched(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	// Check to see if other is our pawn type and if this player start is enabled. 
	if(Other.IsA('HLW_Pawn_Class') && bEnabled)
	{
		// Make sure the pawn is alive. Dead pawns shouldn't have collision so we should be able to spawn here
		if(Pawn(Other).Health > 0)
		{
			// Disable the player start because a player is on top of it.
			bEnabled = false;
		}
	}
}

/**
 * Function to bind to the trigger's UnTouch delegate to allow us to customize what happens when
 * the trigger gets touched
 */
simulated function OnTriggerUnTouched(Actor Other)
{
	// Check to see if other is our pawn type and if this player start is disabled. 
	if(Other.IsA('HLW_Pawn_Class') && !bEnabled)
	{
		// Enable the player start.
		bEnabled = true;
	}
}

DefaultProperties
{
	bPrimaryStart=false
	TouchTriggerClass=class'HLW.HLW_Trigger'
}
