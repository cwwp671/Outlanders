/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */

class HLW_Trigger_TeamOnly extends HLW_Trigger
	placeable
	ClassGroup(HLW_Trigger);

var() int TeamIndex;
var array<HLW_Pawn_Class> TouchedList;

/**
 * The touch event gets called when another actor touches this trigger. It then calls the function associated
 * with the delegate.
 */
simulated event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	local PlayerController PC;

	if(Other == none || HLW_Pawn_Class(Other) == none)
	{
		return;
	}

	PC = PlayerController(Pawn(Other).Controller);

	if(PC != none)
	{
		if(PC.PlayerReplicationInfo != none && PC.PlayerReplicationInfo.Team != none)
		{
			if(PC.PlayerReplicationInfo.Team.TeamIndex == TeamIndex)
			{
				// Add the pawn to the touched list
				TouchedList.AddItem(HLW_Pawn_Class(Other));

				// Only trigger the touch event when the match is in progress
				if(HLW_GameReplicationInfo(WorldInfo.GRI).bMatchInProgress)
				{
					TriggerEventClass(class'HLW_SeqEvent_Touch', self, 0);
				}
			}
		}
	}
}

/**
 * The touch event gets called when another actor leaves this trigger, or stops touching it. It then calls the function associated
 * with the delegate.
 */
simulated event UnTouch(Actor Other)
{
	local PlayerController PC;

	if(Other == none || HLW_Pawn_Class(Other) == none)
	{
		return;
	}

	PC = PlayerController(Pawn(Other).Controller);

	if(PC != none)
	{
		if(PC.PlayerReplicationInfo != none && PC.PlayerReplicationInfo.Team != none)
		{
			if(PC.PlayerReplicationInfo.Team.TeamIndex == TeamIndex)
			{
				TouchedList.RemoveItem(HLW_Pawn_Class(Other));

				// Only trigger the gate to close if there are no more pawns in the trigger, and only if the match is in progress.
				if(TouchedList.Length == 0 && HLW_GameReplicationInfo(WorldInfo.GRI).bMatchInProgress)
				{
					TriggerEventClass(class'HLW_SeqEvent_Touch', self, 1);
				}
			}
		}
	}
	
}

function NotifyTouchingPawnDied(HLW_Pawn_Class HLW_P)
{
	// Send the pawn variable to check if this pawn was on the same team.
	// No need to trigger the event if pawn was on other team
	UnTouch(HLW_P);
}

DefaultProperties
{
	SupportedEvents.Empty()
	SupportedEvents(0)=class'HLW.HLW_SeqEvent_Touch'
}
