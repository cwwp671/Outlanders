/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Ability_ShieldBash extends HLW_Ability;

var(Ability) HLW_UpgradableParameter Damage;
var(Ability) HLW_UpgradableParameter Radius;
var(Ability) SoundCue VoiceClip;
var(Ability) SoundCue HitSound;
var(Ability) float PhysPowPercentageAsDamage;
var(Ability) float KnockbackStrength;
var(Ability) float AnimationLength;
var(Ability) bool bCanHitSound;

state Aiming
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		AimingDecal.SetRadius(Radius.CurrentValue);
	}
	
	simulated function HandleFixedAiming(int Offset = 0)
	{
		Offset = OwnerPC.Pawn.GetCollisionRadius() + Radius.CurrentValue;
		
		super.HandleFixedAiming(Offset);
	}
}

simulated function ActivateAbility()
{
	local HLW_Pawn HitPawn;
	local Vector KnockbackMomentum;
	local bool bPlayedSound;

	bPlayedSound = false;
	
	super.ActivateAbility();
	
	OwnerPC.Pawn.Weapon.GotoState('Active');
	
	ConsumeResources();
	StartCooldown();
	
	//Safely Set Animation States to Shield Bash
	if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).UpperStateList.ActiveChildIndex != _SHIELDBASH)
	{
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERSTATE, _SHIELDBASH, 0.125);
	}
	
	if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).LowerStateList.ActiveChildIndex != _SHIELDBASH)
	{
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERSTATE, _SHIELDBASH, 0.125);
	}
	
	SetTimer(AnimationLength, false, 'ResetAnim'); //Set Timer For Animation Reset
	SetTimer(AnimationLength, false, 'AbilityComplete');
	
	if(Role == ROLE_Authority)
	{		
		//Play VoiceOver AudioComponent
		HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = VoiceClip;
		HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
		
		
		foreach DynamicActors(class'HLW_Pawn', HitPawn)
		{
			if(VSize(HitLocation - HitPawn.Location) < Radius.CurrentValue)
			{
				if(HitPawn != OwnerPC.Pawn && HitPawn != None)
				{	
					KnockbackMomentum = Vector(OwnerPC.Pawn.Rotation) * KnockbackStrength;
					HitPawn.TakeDamage(Damage.CurrentValue + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamage), OwnerPC, HitLocation, KnockbackMomentum, class'HLW_DamageType_Physical',, self);

					if (!bPlayedSound)
					{
						bPlayedSound = true;
						PlaySound(HitSound,,,,HitLocation);
					}
				}
			}
		}
	}
}

//Safely Set Animation States to Normal
simulated function ResetAnim()
{	
	if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).UpperStateList.ActiveChildIndex == _SHIELDBASH)
	{
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERSTATE, _NORMAL, 0.25);
	}
	
	if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).LowerStateList.ActiveChildIndex == _SHIELDBASH)
	{
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERSTATE, _NORMAL, 0.25);
	}
}

simulated function LevelUp()
{
	super.LevelUp();
	
	Damage.Upgrade(AbilityLevel);
	Radius.Upgrade(AbilityLevel);
}

simulated function AbilityComplete(bool bIsPremature = false)
{
	if(bIsPremature)
	{
		ClearTimer('ResetAnim');
		ClearTimer('AbilityComplete');
	}	
	
	super.AbilityComplete(bIsPremature);
}

DefaultProperties
{
	KnockbackStrength=75000
	PhysPowPercentageAsDamage=0.6
	AnimationLength=1.0
	
	VoiceClip=SoundCue'HLW_Package_Voices.Warrior.Ability_ShieldBash'
	HitSound=SoundCue'HLW_Package_Chris.SFX.Warrior_Ability_ShieldBash'
	DecalImage=Texture2D'HLW_mapProps.guimaterials.SpellSymbol_Bash'
	
	bPreventsPrimaryAttacksWhileActive=true
	bPreventsSecondaryAttacksWhileActive=true
	bPreventsOtherAbilitiesWhileActive=true
	
	AimType=HLW_AAT_Fixed

	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=23
		Factor=0.2
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=10.0
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=RangeParameter
		BaseValue=200.0
		UpgradeType=HLW_UT_None
	End Object
	Range=RangeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CastTimeParameter
		BaseValue=0.0
		UpgradeType=HLW_UT_None
	End Object
	CastTime=CastTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=DamageParameter
		BaseValue=35.0
		Factor=0.3
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	Damage=DamageParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=RadiusParameter
		BaseValue=100
		Factor=0
		UpgradeType=HLW_UT_AddFixedValue
	End Object
	Radius=RadiusParameter
}
