class HLW_StatusEffect_Burn extends HLW_StatusEffect_DOT;

function Initiate(HLW_Pawn EffectTargetIN, Controller EffectInstigatorIN, optional Actor EffectOwnerIN)
{
	super.Initiate(EffectTargetIN, EffectInstigatorIN, EffectOwnerIN);

	// Decrease stats or something here.
}

function EffectTick()
{	
	super.EffectTick();
	
	if(HLW_Pawn_Class(EffectTarget) != None)
	{
		HLW_Pawn_Class(EffectTarget).SpawnEmitter(ParticleSystem'HLW_AndrewParticles.Particles.FX_FireChunks', EffectTarget.Location, EffectTarget.Rotation, true, 4);
	}
	// Do stuff here
}

function Expire()
{
	// Restore stats or something here.

	super.Expire();
}

defaultproperties
{
	DamageType=class'HLW_DamageType_Magical'
	Duration=5.0f
	DamageAmount=3.0f
	Period=0.5f
}