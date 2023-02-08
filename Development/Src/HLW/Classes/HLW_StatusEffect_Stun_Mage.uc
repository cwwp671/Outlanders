/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_StatusEffect_Stun_Mage extends HLW_StatusEffect_Stun;

var int CountersNeeded;

function Initiate(HLW_Pawn EffectTargetIN, Controller EffectInstigatorIN, optional Actor EffectOwnerIN)
{
	local int i, TotalCounters;
	
	self.EffectTarget = EffectTargetIN;
	self.EffectInstigator = EffectInstigatorIN;
	self.EffectOwner = EffectOwnerIN == none ? EffectInstigator : EffectOwnerIN;
	
	//`log("Made the Stun Effect");
	
	if (EffectTarget != none)
	{
		TotalCounters = 0;
		for(i = 0; i < EffectTarget.ActiveStatusEffects.Length; i++)
		{
			if(EffectTarget.ActiveStatusEffects[i].EffectName == "Mage Stun Counter")
			{
				TotalCounters++;
				//`log("WE FOUND"@TotalCounters@"Stun Counters");
			}
		}
			
		if(TotalCounters >= CountersNeeded)
		{
			//`log("YOU STUNNED HIM");
			super.Initiate(EffectTargetIN, EffectInstigatorIN, EffectOwnerIN);
		}
	}
	else
	{
		//`log("I Guess effectTarget is no good because its"@EffectTarget);	
	}
}

defaultproperties
{
	Duration=3.0f
	Period=0.0f
	EffectName="Mage Pulsing Thunder Stun"
	CountersNeeded=5
}