/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_StatusEffect_Poison extends HLW_StatusEffect_DOT;

function Initiate(HLW_Pawn EffectTargetIN, Controller EffectInstigatorIN, optional Actor EffectOwnerIN)
{
	super.Initiate(EffectTargetIN, EffectInstigatorIN, EffectOwnerIN);

	// Decrease stats or something here.
}

function EffectTick()
{
	super.EffectTick();

	// Do stuff here
}

function Expire()
{
	// Restore stats or something here.

	super.Expire();
}

defaultproperties
{
	DamageType=class'HLW_DamageType_Physical'
	Duration=7.0f
	DamageAmount=3.0f
	Period=1.0f
}