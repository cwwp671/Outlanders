class HLW_Ability_Absorb extends HLW_Ability_Passive;

var protectedwrite int killCounter;
var(Ability) int BasicAttackKillsRequired;
var(Ability) int MaxFreeAbilityStacks;

simulated function OwnerGotBasicAttackKill()
{
	killCounter++;

	if (killCounter >= BasicAttackKillsRequired)
	{
		if (OwnerPC.NumFreeAbilities < MaxFreeAbilityStacks)
		{
			OwnerPC.NumFreeAbilities++;
			//`log("HAVE A FREE ABILITY! " @ OwnerPC.NumFreeAbilities @ "/" @ MaxFreeAbilityStacks);
		}

		killCounter = 0;
	}
}

DefaultProperties
{
	AimType=HLW_AAT_None
	killCounter=0
	BasicAttackKillsRequired=3
	MaxFreeAbilityStacks=3
}
