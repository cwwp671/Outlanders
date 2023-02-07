class HLW_Ability_HeadShot extends HLW_Ability_Passive;

var float HeadShotDamageMultiplier;

simulated function int GetArrowDamage(int OriginalDamage, Actor Other, Vector StartLocation, Vector HitNormal)
{
	if(HLW_Pawn_Class(Other) != None)
	{
		if(HLW_Pawn_Class(Other).IsLocationOnHead(StartLocation, HitNormal, 1))
		{
			//`log("HEAD SHOT");
			return OriginalDamage * HeadShotDamageMultiplier;
		}
	}
	
	return OriginalDamage;
}

simulated function AbilityComplete(bool bIsPremature = false);

defaultproperties
{
	HeadShotDamageMultiplier=1.25f
}