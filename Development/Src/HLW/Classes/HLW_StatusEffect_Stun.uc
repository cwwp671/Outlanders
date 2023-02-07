class HLW_StatusEffect_Stun extends HLW_StatusEffect;

enum StunBehaviors
{
	HLW_SB_Stacks,
	HLW_SB_OverrideForce,
	HLW_SB_OverrideIfGreater
};

var(Effect) ParticleSystem StunParticle;
var(Effect) StunBehaviors StunBehavior;

function Initiate(HLW_Pawn EffectTargetIN, Controller EffectInstigatorIN, optional Actor EffectOwnerIN)
{
	`log("StatusEffect_Stun:: Initiate - EffectTargetIN:"@EffectTargetIN);
	super.Initiate(EffectTargetIN, EffectInstigatorIN, EffectOwnerIN);

	if (EffectTarget != none)
	{
		if (StunBehavior == HLW_SB_Stacks)
		{
			// Add this stun's duration to the target's remaining stun duration
			InitiateStun(EffectTarget.GetRemainingStunTime() + Duration);
		}
		else if (StunBehavior == HLW_SB_OverrideForce)
		{
			// Replace target's stun duration with this one
			InitiateStun(Duration);
		}
		else if (StunBehavior == HLW_SB_OverrideIfGreater)
		{
			// Only replace target's stun duration if this new one is greater than the current
			if (Duration > EffectTarget.GetRemainingStunTime())
			{
				InitiateStun(Duration);
			}
		}

	}
}

protected function InitiateStun(float StunDuration)
{
	`log("StatusEffect_Stun:: InitiateStun - StunDuration:"@StunDuration);
	EffectTarget.SetTimer(StunDuration, false, 'StunTimer');
		
	EffectTarget.Acceleration = vect(0,0,0);

	if (HLW_PlayerController(EffectTarget.Controller) != none)
	{
		HLW_PlayerController(EffectTarget.Controller).SetCinematicMode(true, false, false, true, true, false);
	}
		
	if(HLW_Pawn_Class(EffectTarget) != None)
	{
		HLW_Pawn_Class(EffectTarget).SpawnEmitter(StunParticle, EffectTarget.Location, EffectTarget.Rotation, true, 4);
	}
}

function Expire()
{
	`log("StatusEffect_Stun:: Expire - TargetController:"@HLW_PlayerController(EffectTarget.Controller));
	super.Expire();

	if (HLW_PlayerController(EffectTarget.Controller) != none)
	{
		HLW_PlayerController(EffectTarget.Controller).SetCinematicMode(false, false, false, true, true, false);
	}
}

simulated function bool CanBeAppliedTo(HLW_Pawn Target, Controller EffectInstigatorIN)
{
	// If not on the same team and not self
	return (!Target.IsSameTeam(EffectInstigatorIN.Pawn) && Target != EffectInstigatorIN.Pawn);
}

defaultproperties
{
	EffectName="Stun"
	StunParticle=ParticleSystem'HLW_Package_Randolph.Farticles.StunEffect'
	StunBehavior=HLW_SB_OverrideIfGreater
	Duration=0.25f
	Period=0.0f
}