/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_StatusEffect_Counter extends HLW_StatusEffect;

var int CountersNeeded;
var int TotalCounters;
var bool bCanStack;

function Initiate(HLW_Pawn EffectTargetIN, Controller EffectInstigatorIN, optional Actor EffectOwnerIN)
{
	local int i;
	super.Initiate(EffectTargetIN, EffectInstigatorIN, EffectOwnerIN);

	if (EffectTarget != none)
	{	
		TotalCounters = 0;
		for(i = 0; i < EffectTarget.ActiveStatusEffects.Length; i++)
		{
			if(EffectTarget.ActiveStatusEffects[i].EffectName == EffectName)
			{
				if(!bCanStack)
				{
					EffectTarget.ActiveStatusEffects[i].SetTimer(Duration, false, 'Expire');				
				}

				TotalCounters++;
			}
		}
		//`log("HE CURRENTLY HAS"@totalCounters@"Mage Stun Counters On Him");
	}
}

simulated function bool CanBeAppliedTo(HLW_Pawn Target, Controller EffectInstigatorIN)
{
	// If not on the same team and not self
	return (!Target.IsSameTeam(EffectInstigatorIN.Pawn) && Target != EffectInstigatorIN.Pawn);
}

defaultproperties
{
	Duration=5.0f
	Period=0.0f
	CountersNeeded=5
	EffectName="Mage Counter"
	TotalCounters=0
	bCanStack=FALSE
}