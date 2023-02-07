class HLW_StatusEffect_Counter_Burn_Mage extends HLW_StatusEffect_Counter;

function Initiate(HLW_Pawn EffectTargetIN, Controller EffectInstigatorIN, optional Actor EffectOwnerIN)
{
	local HLW_StatusEffect_Burn_Mage burnToAdd;
	local int i;
	super.Initiate(EffectTargetIN, EffectInstigatorIN, EffectOwnerIN);

	if (EffectTarget != none)
	{
		if(TotalCounters >= CountersNeeded)
		{
			burnToAdd = Spawn(class'HLW_StatusEffect_Burn_Mage');
			EffectTarget.ApplyStatusEffect(burnToAdd, EffectInstigator);
			`log("YOU BURNED HIM");
			for(i = EffectTarget.ActiveStatusEffects.Length - 1; i >= 0; i--)
			{
				if(EffectTarget.ActiveStatusEffects[i].EffectName == EffectName)
				{
					EffectTarget.ActiveStatusEffects.RemoveItem(EffectTarget.ActiveStatusEffects[i]);
				}
			}
		}
	}
}

defaultproperties
{
	Duration=5.0f
	Period=0.0f
	EffectName="Mage Burn Counter"
}