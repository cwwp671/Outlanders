/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Ability_Hamstring extends HLW_Ability;

var(Ability) HLW_UpgradableParameter Damage;
var(Ability) HLW_UpgradableParameter Radius;
var(Ability) HLW_UpgradableParameter SlowDuration;
var(Ability) HLW_UpgradableParameter SlowPercentage;
var(Ability) SoundCue VoiceClip;
var(Ability) SoundCue HitSound;
var(Ability) ParticleSystem SlowParticle;
var(Ability) float KnockbackStrength;
var(Ability) float PhysPowPercentageAsDamage;
var(Ability) float AnimationLength;

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
		//AimingDecal.SetRadius(Radius.CurrentValue);
		super.HandleFixedAiming(Offset);
	}
}

simulated function ActivateAbility()
{
	local HLW_Pawn HitPawn;
	local Vector KnockbackMomentum;
	local HLW_StatusEffect_Slow_Hamstring SlowStatus;
	local bool bPlayedSound;

	bPlayedSound = false;
	
	super.ActivateAbility();
	
	OwnerPC.Pawn.Weapon.GotoState('Active');
	
	ConsumeResources();
	StartCooldown();
	
	//Safely Set Animation States to Shin Kick
	if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).UpperStateList.ActiveChildIndex != _SHINKICK)
	{
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERSTATE, _SHINKICK, 0.0885375);
	}
	
	if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).LowerStateList.ActiveChildIndex != _SHINKICK)
	{
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERSTATE, _SHINKICK, 0.0885375);
	}
	
	SetTimer(AnimationLength, false, 'ResetAnim'); //Set Timer For Animation Reset
	SetTimer(AnimationLength, false, 'AbilityComplete');
	
	if(Role == ROLE_Authority)
	{		
		//Play VoiceOver AudioComponent
		HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = VoiceClip;
		HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
		
		foreach VisibleCollidingActors( class'HLW_Pawn', HitPawn, Radius.CurrentValue, HitLocation)
		{
			if(HitPawn != OwnerPC.Pawn && !OwnerPC.Pawn.IsSameTeam(HitPawn))
			{
				KnockbackMomentum = Normal(HitPawn.Location - HitLocation) * KnockbackStrength;
				HitPawn.TakeDamage(Damage.CurrentValue + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamage), OwnerPC, HitLocation, KnockbackMomentum, class'HLW_DamageType_Physical',, self);
				
				SlowStatus = Spawn(class'HLW_StatusEffect_Slow_Hamstring', OwnerPC);
				SlowStatus.Duration = SlowDuration.CurrentValue;
				SlowStatus.SlowPercentage = SlowPercentage.CurrentValue;
				SlowStatus.ParticleEffect = SlowParticle;
				HitPawn.ApplyStatusEffect(SlowStatus, OwnerPC);

				if (!bPlayedSound)
				{
					bPlayedSound = true;
					PlaySound(HitSound,,,,HitLocation);
				}
			}
		}
	}	
}

//Safely Set Animation States to Normal
simulated function ResetAnim()
{	
	if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).UpperStateList.ActiveChildIndex == _SHINKICK)
	{
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERSTATE, _NORMAL, 0.25f);
	}
	
	if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).LowerStateList.ActiveChildIndex == _SHINKICK)
	{
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERSTATE, _NORMAL, 0.25f);
	}
}

simulated function LevelUp()
{
	super.LevelUp();
	
	Damage.Upgrade(AbilityLevel);
	Radius.Upgrade(AbilityLevel);
	SlowDuration.Upgrade(AbilityLevel);
	SlowPercentage.Upgrade(AbilityLevel);
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

defaultproperties
{
	PhysPowPercentageAsDamage=0.25
	KnockbackStrength=0
	AnimationLength=0.7083
	
	VoiceClip=SoundCue'HLW_Package_Voices.Warrior.Ability_Hamstring'
	HitSound=SoundCue'HLW_Package_Chris.SFX.Warrior_Ability_Hamstring'
	SlowParticle=ParticleSystem'HLW_AndrewParticles.Particles.FX_IceChunks'
	
	bPreventsPrimaryAttacksWhileActive=true
	bPreventsSecondaryAttacksWhileActive=true
	bPreventsOtherAbilitiesWhileActive=true
	
	AimType=HLW_AAT_Fixed
	
	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=20
		Factor=0.25
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=11.0
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
		BaseValue=35
		Factor=0.15
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	Damage=DamageParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=RadiusParameter
		BaseValue=75
		Factor=0
		UpgradeType=HLW_UT_AddFixedValue
	End Object
	Radius=RadiusParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=SlowDurationParameter
		BaseValue=4.0
		Factor=0
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	SlowDuration=SlowDurationParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=SlowPercentageParameter
		BaseValue=0.2
		Factor=0.15
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	SlowPercentage=SlowPercentageParameter
}