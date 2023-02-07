class HLW_StatusEffect_Slow_Hamstring extends HLW_StatusEffect_Slow;

var float ParticleTickRate;

function Initiate(HLW_Pawn EffectTargetIN, Controller EffectInstigatorIN, optional Actor EffectOwnerIN)
{
	super.Initiate(EffectTargetIN, EffectInstigatorIN, EffectOwnerIN);
	
	SetTimer(ParticleTickRate, true, 'SlowEffectSpawn');
}

function SlowEffectSpawn()
{
	if(HLW_Pawn_Class(EffectTarget) != None)
	{
		HLW_Pawn_Class(EffectTarget).SpawnEmitter(ParticleEffect, EffectTarget.Location, EffectTarget.Rotation, true, 4);
	}
}

function Expire()
{
	super.Expire();
	
	ClearTimer('SlowEffectSpawn');	
}

defaultproperties
{
	ParticleTickRate=0.1
}