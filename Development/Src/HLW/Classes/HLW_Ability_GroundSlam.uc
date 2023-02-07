class HLW_Ability_GroundSlam extends HLW_Ability;

var(Ability) HLW_UpgradableParameter Damage;
var(Ability) HLW_UpgradableParameter StunDuration;
var(Ability) HLW_UpgradableParameter HealAmount;

var(Ability) float PhysPowPercentageAsDamage;
var(Ability) float PhysPowPercentageAsHealing;
var(Ability) float AuraPercentUsage;
var(Ability) float KnockbackStrength;
var(Ability) int GroundSlamRadius;

var(Ability) HLW_StatusEffect StunEffect;

var(Ability) SoundCue VoiceClip;
var(Ability) SoundCue SlamImpactSound;
var(Ability) ParticleSystem SlamEffect;

var(Ability) HLW_AimingDecal SlamDecal;
var(Ability) bool bCanSlamDecal;

var(Ability) float TimeUntilSlam;
var(Ability) float SlamCounter;

state Aiming
{
	simulated function BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		if(HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]) != None)
		{
			AimingDecal.SetRadius((HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]).GetAuraPercentage(AuraPercentUsage) + 1) * Range.CurrentValue);
		}
	}
	
	simulated function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);
		
		if(HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]) != None)
		{
			AimingDecal.SetRadius((HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]).GetAuraPercentage(AuraPercentUsage) + 1) * Range.CurrentValue);
		}
	}
	
	simulated function HandleFixedAiming(int Offset = 200)
	{
		Offset = ((HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]).GetAuraPercentage(AuraPercentUsage) + 1) * Range.CurrentValue) - OwnerPC.Pawn.GetCollisionRadius();
		super.HandleFixedAiming(Offset);
	}
}

simulated function ActivateAbility()
{
	super.ActivateAbility();

	if(OwnerPC == none || OwnerPC.Pawn == none)
	{
		return;
	}
	
	OwnerPC.Pawn.Weapon.GotoState('Active');
	
	if(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).UpperStateList.ActiveChildIndex != GROUNDSLAM)
	{
		HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERSTATE, GROUNDSLAM, 0.1458375);
	}
	
	if(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).LowerStateList.ActiveChildIndex != GROUNDSLAM)
	{
		HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(LOWERSTATE, GROUNDSLAM, 0.1458375);
	}
	
	if(SlamDecal == None)
	{
		SlamDecal = Spawn(class'HLW_AimingDecal',,, HitLocation, Rot(-16384, 0, 0));
		SlamDecal.SetRadius(AimingDecal.Radius);
		SlamDecal.MatInst.SetScalarParameterValue('AbleToCast', 1);
	}
	
	SlamDecal.MatInst.SetScalarParameterValue('CastingTime', 0.0);
	SlamCounter = 0;
	SlamDecal.SetRadius(AimingDecal.Radius);
	SlamDecal.SetLocation(HitLocation);
	SlamDecal.SetHidden(false);
	bCanSlamDecal = true;

	if (Role == ROLE_Authority)
	{
		HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = VoiceClip;
		HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
	}
	
	SetTimer(TimeUntilSlam, false, 'DoGroundSlam');
}

simulated function Tick(float DeltaTime)
{
	local int Offset;
	
	super.Tick(DeltaTime);
	
	if(bCanSlamDecal && OwnerPC != none && OwnerPC.Pawn != none)
	{
		SlamCounter += DeltaTime;
		SlamDecal.MatInst.SetScalarParameterValue('CastingTime', FMin(SlamCounter / TimeUntilSlam, 1.0f));
		
		Offset = ((HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]).GetAuraPercentage(AuraPercentUsage) + 1) * Range.CurrentValue) - OwnerPC.Pawn.GetCollisionRadius();//OwnerPC.Pawn.GetCollisionRadius() + Range.CurrentValue;
		
		SlamDecal.SetLocation( OwnerPC.Pawn.Location + Vector(OwnerPC.Pawn.Rotation) * Offset );
		SlamDecal.SetRotation( MakeRotator(-16384, OwnerPC.Pawn.Rotation.Roll, OwnerPC.Pawn.Rotation.Yaw) );
		
		HitLocation = SlamDecal.Decal.Location;

		if(HitLocation != vect(0,0,0))
		{
			SlamDecal.MatInst.SetScalarParameterValue('AbleToCast', 1);
			bInvalidHitLocation = false;
		}
		else
		{
			SlamDecal.MatInst.SetScalarParameterValue('AbleToCast', 0);
			bInvalidHitLocation = true;
		}
	}
}

simulated function DoGroundSlam()
{
	local Vector ParticleLocation, SlamMomentum;
	local HLW_Pawn HitPawn;
	local float AuraAmount;
	
	SlamDecal.SetHidden(true);
	bCanSlamDecal = false;
	SlamCounter = 0;
		
	if(HitLocation != vect(0,0,0) && OwnerPC != none && OwnerPC.Pawn != none)
	{
		// Get the farthest point the ability can reach
		ParticleLocation = HitLocation;
		ParticleLocation.Z = OwnerPC.Pawn.Location.Z - OwnerPC.Pawn.GetCollisionHeight();
	
		HLW_Pawn_Class(OwnerPC.Pawn).SpawnEmitter(SlamEffect, ParticleLocation, OwnerPC.Pawn.Rotation,, Range.CurrentValue * (HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]).GetAuraPercentage(AuraPercentUsage) + 1) / 225);
		PlaySound(SlamImpactSound,,,, HitLocation);
		
		if(Role == ROLE_Authority)
		{
			if(HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]) != None)
			{
				AuraAmount = HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]).UseAura(AuraPercentUsage);
				//`log("AURA AMOUNT"@AuraAmount);
			}
			
			foreach DynamicActors(class'HLW_Pawn', HitPawn)
			{
				if(VSize(ParticleLocation - HitPawn.Location) < Range.CurrentValue * (AuraAmount + 1))
				{
					if(HitPawn != None && HitPawn != OwnerPC.Pawn)
					{	
						if(OwnerPC.Pawn.IsSameTeam(HitPawn) == false)
						{
							StunEffect= Spawn(class'HLW_StatusEffect_Stun', OwnerPC.Pawn);
							StunEffect.Duration = StunDuration.CurrentValue;
							HitPawn.ApplyStatusEffect(StunEffect, OwnerPC);
				
							SlamMomentum.Z = KnockbackStrength;
							HitPawn.Velocity = vect(0,0,0);
							HitPawn.TakeDamage(Damage.CurrentValue + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamage), OwnerPC, ParticleLocation, SlamMomentum, class'HLW_DamageType_Physical',, self);
						}
						else
						{
							HitPawn.HealDamage((HealAmount.CurrentValue + (PhysPowPercentageAsHealing * OwnerPC.GetPRI().PhysicalPower)), OwnerPC, class'HLW_DamageType_Magical');
						}
					}
				}
			}
		}	
	
		ConsumeResources();	
	}
	
	SetTimer(0.2295, false, 'ResetAnims');
	StartCooldown();
	AbilityComplete();
}

simulated function AbilityComplete(bool bIsPremature = false)
{
	if(bIsPremature)
	{
		if(SlamDecal != None)
		{
			SlamDecal.SetHidden(true);
		}	
	}
	
	super.AbilityComplete(bIsPremature);	
}

simulated function ResetAnims()
{
	if(OwnerPC != none && OwnerPC.Pawn != none)
	{
		HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERSTATE, NORMAL);
		HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(LOWERSTATE, NORMAL);
	}
}

simulated function LevelUp()
{
	super.LevelUp();
	
	Damage.Upgrade(AbilityLevel);
	StunDuration.Upgrade(AbilityLevel);
	HealAmount.Upgrade(AbilityLevel);
}

DefaultProperties
{
	SlamEffect=ParticleSystem'HLW_Package_Randolph.Farticles.GroundSlamEffect'
	
	bPreventsOtherAbilitiesWhileActive=true
	bPreventsPrimaryAttacksWhileActive=true
	bPreventsSecondaryAttacksWhileActive=true
	
	AimType=HLW_AAT_Fixed

	KnockbackStrength=75000
	PhysPowPercentageAsDamage=0.3
	PhysPowPercentageAsHealing=0.15
	AuraPercentUsage=0.2
	GroundSlamRadius=130
	TimeUntilSlam=0.9372
	
	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=20
		Factor=0.25
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=10.0
		//Factor=0.05
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=RangeParameter
		BaseValue=130.0
		UpgradeType=HLW_UT_None
	End Object
	Range=RangeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CastTimeParameter
		BaseValue=0.0
		UpgradeType=HLW_UT_None
	End Object
	CastTime=CastTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=DamageParameter
		BaseValue=30.0
		Factor=0.2
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	Damage=DamageParameter

	Begin Object Class=HLW_UpgradableParameter Name=StunDurationParameter
		BaseValue=1.75
		Factor=0.05
		UpgradeType=HLW_UT_AddFixedValue
	End Object
	StunDuration=StunDurationParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=HealAmountParameter
		BaseValue=15
		Factor=0.4
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	HealAmount=HealAmountParameter
	
	DecalImage=Texture2D'HLW_Package_Lukas.Textures.SpellSymbol_GroundSlam'
	
	VoiceClip=SoundCue'HLW_Package_Voices.Barbarian.Ability_GroundSmash'
	SlamImpactSound=SoundCue'HLW_Package_Chris.SFX.Barbarian_Ability_GroundSmash'
}
