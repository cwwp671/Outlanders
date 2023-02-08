/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Ability_Passive extends HLW_Ability;

simulated function bool CanBeCast()
{
	return false;
}

DefaultProperties
{
	AimType=HLW_AAT_None
	
	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=0
		UpgradeType=HLW_UT_None
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=0
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter
}
