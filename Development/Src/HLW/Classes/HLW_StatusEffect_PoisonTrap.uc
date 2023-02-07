class HLW_StatusEffect_PoisonTrap extends HLW_StatusEffect_DOT;

var ParticleSystem PoisonParticle;

function EffectTick()
{	
	super.EffectTick();
	
	if(HLW_Pawn_Class(EffectTarget) != None)
	{
		HLW_Pawn_Class(EffectTarget).SpawnEmitter(PoisonParticle, EffectTarget.Location, EffectTarget.Rotation, true, 1.0f);
	}
}

defaultproperties
{
	DamageType=class'HLW_DamageType_Pure'
	Duration=5.0f
	DamageAmount=200.0f
	Period=1.0f
	
	PoisonParticle=ParticleSystem'HLW_Package_Randolph.Farticles.FX_PoisonEffect'
}