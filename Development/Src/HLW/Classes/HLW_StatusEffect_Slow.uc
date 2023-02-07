class HLW_StatusEffect_Slow extends HLW_StatusEffect;

var float SlowPercentage;
var ParticleSystem ParticleEffect;

function Initiate(HLW_Pawn EffectTargetIN, Controller EffectInstigatorIN, optional Actor EffectOwnerIN)
{
	super.Initiate(EffectTargetIN, EffectInstigatorIN, EffectOwnerIN);

	if (EffectTarget != none)
	{
		if(EffectTarget.MovementSpeedModifier > 0)
		{
			EffectTarget.MovementSpeedModifier = FMax(EffectTarget.MovementSpeedModifier - SlowPercentage, 0.0f);
		}
		
		if(ParticleEffect != None && HLW_Pawn_Class(EffectTarget) != None)
		{
			HLW_Pawn_Class(EffectTarget).SpawnEmitter(ParticleEffect, EffectTarget.Location, EffectTarget.Rotation, true, 4);
		}
	}
}

function Expire()
{
	if (EffectTarget != none)
	{
		if(EffectTarget.MovementSpeedModifier < 1)
		{
			EffectTarget.MovementSpeedModifier = FMin(EffectTarget.MovementSpeedModifier + SlowPercentage, 1);
		}
		
		if(ParticleEffect != None && HLW_Pawn_Class(EffectTarget) != None)
		{
			HLW_Pawn_Class(EffectTarget).SpawnEmitter(ParticleEffect, EffectTarget.Location, EffectTarget.Rotation, true, 4);
		}
	}
	
	super.Expire();
}

simulated function bool CanBeAppliedTo(HLW_Pawn Target, Controller EffectInstigatorIN)
{
	// If not on the same team and not self
	return (!Target.IsSameTeam(EffectInstigatorIN.Pawn) && Target != EffectInstigatorIN.Pawn);
}

defaultproperties
{
	EffectName="Slow"
	Duration=2.0f
	Period=0.0f
	SlowPercentage=0.05f
}