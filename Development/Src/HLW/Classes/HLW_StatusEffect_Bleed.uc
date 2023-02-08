/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_StatusEffect_Bleed extends HLW_StatusEffect_DOT;

function Initiate(HLW_Pawn EffectTargetIN, Controller EffectInstigatorIN, optional Actor EffectOwnerIN)
{
	super.Initiate(EffectTargetIN, EffectInstigatorIN, EffectOwnerIN);

	// Decrease stats or something here.
}

function EffectTick()
{
	super.EffectTick();

	// Do stuff here
	if(HLW_Pawn_Class(EffectTarget) != None)
	{
		HLW_Pawn_Class(EffectTarget).SpawnEmitter(ParticleSystem'HLW_Package_Randolph.Farticles.BleedEffect', EffectTarget.Location, EffectTarget.Rotation, true, 1.0f);
	}
}

function Expire()
{
	// Restore stats or something here.

	super.Expire();
}

defaultproperties
{
	DamageType=class'HLW_DamageType_Physical'
	Duration=5.0f
	DamageAmount=2.0f
	Period=0.25f
}