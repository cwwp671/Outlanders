class HLW_StatusEffect_DOT extends HLW_StatusEffect;

var(StatusEffect) float DamageAmount;
var(StatusEffect) class<DamageType> DamageType;

function EffectTick()
{
	local float DamageToDeal;

	if (EffectTarget != none)
	{
		// TODO: Affect the damage dealt here, using armor and damage types
		//DamageToDeal = DamageAmount + (% of MagPower)
		DamageToDeal = DamageAmount;
		EffectTarget.TakeDamage(DamageToDeal, EffectInstigator, EffectTarget.Location, vect(0,0,0), DamageType,,EffectOwner);
	}
}

simulated function bool CanBeAppliedTo(HLW_Pawn Target, Controller EffectInstigatorIN)
{
	// If not on the same team and not self
	return (!Target.IsSameTeam(EffectInstigatorIN.Pawn) && Target != EffectInstigatorIN.Pawn);
}

defaultproperties
{
	DamageType=class'HLW_DamageType_Pure'
	Duration=5.0f
	DamageAmount=10.0f
	Period=0.5f
}