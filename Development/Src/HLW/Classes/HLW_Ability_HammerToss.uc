/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Ability_HammerToss extends HLW_Ability;

var(Ability) HLW_UpgradableParameter Damage;
var(Ability) HLW_UpgradableParameter SlowDuration;
var(Ability) HLW_UpgradableParameter HealAmount;

var(Ability) float SlowPercentage;
var(Ability) float PhysPowPercentageAsDamage;
var(Ability) float PhysPowPercentageAsHealing;
var(Ability) float TeamHealPercentage;

var(Ability) int DamageRadius;
var(Ability) int HealRadius;

var(Ability) float AuraPercentUsage;
var repnotify float AuraAmount;

var ParticleSystem HealParticle;
var ParticleSystem LandParticle;
var ParticleSystem SlowParticle;

var HLW_AimingDecal HealDecal;
var bool bCanHealDecal;

var HLW_Barbarian_ThrowHammer ThrownHammer;
var float ParabolaTime;
var Vector EndLocation;

var byte HealCounter;
var byte MaxHealCount;
var float HealCastCounter;
var float HealTickTime;

var(Ability) SoundCue VoiceClip;
var(Ability) SoundCue HammerImpactSound;



replication 
{
    if(bNetDirty)
        AuraAmount;
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'AuraAmount')
    {
    	ClientSetAuraAmount(AuraAmount);
    	return;
    }
    
    super.ReplicatedEvent(VarName);
}

reliable client function ClientSetAuraAmount(float NewAuraAmount)
{	
	AuraAmount = NewAuraAmount;
} 

simulated state Aiming
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		if(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).UpperStateList.ActiveChildIndex != HAMMERTOSS)
		{
			HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERSTATE, HAMMERTOSS);
		}
		
		HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERHAMMERTOSS, PRETOSS); //0.3750
		SetTimer(0.375, false, 'IdleAnim');
		
		if(HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]) != None)
		{
			AimingDecal.SetRadius((HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]).GetAuraPercentage(AuraPercentUsage) + 1) * DamageRadius);
		}
	}
	
	simulated function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);
		
		if(HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]) != None)
		{
			AimingDecal.SetRadius((HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]).GetAuraPercentage(AuraPercentUsage) + 1) * DamageRadius);
		}	
	}
	
	simulated function IdleAnim()
	{
		HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERHAMMERTOSS, TOSSIDLE);
	}
	
	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		
		ClearTimer('IdleAnim');	
	}
}

simulated function StopAimAnimation()
{
	if(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).UpperStateList.ActiveChildIndex == HAMMERTOSS)
	{
		HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERSTATE, NORMAL, 0.25);
	}
}

simulated function ActivateAbility()
{
	local Vector CasterEyeLoc, TossVel;
	local Vector Dir, Distance;
	local Rotator CasterEyeRot;
	local  HLW_Decal_Cast LandTimeDecal;
	
	super.ActivateAbility();
	
	OwnerPC.Pawn.Weapon.GotoState('Active');
	
	HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERHAMMERTOSS, TOSSEND);
	SetTimer(0.25, false, 'EndTossAnim');
	
	ConsumeResources();
	StartCooldown();
	
	OwnerPC.GetPlayerViewPoint(CasterEyeLoc, CasterEyeRot);
	EndLocation = HitLocation;
	//EndLocation.Z = OwnerPC.Pawn.Location.Z - OwnerPC.Pawn.GetCollisionHeight();
	
	if(Role == ROLE_Authority)
	{
		if(HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]) != None)
		{
			AuraAmount = HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]).UseAura(AuraPercentUsage);
			//`log("AURA AMOUNT"@AuraAmount);
		}
		
		Dir = Vector(Normalize(OwnerPC.Pawn.Rotation));
	
		Distance.X = abs(EndLocation.X - OwnerPC.Pawn.Location.X);
		Distance.Y = abs(EndLocation.Y - OwnerPC.Pawn.Location.Y);
		Distance.Z = abs (200 + (EndLocation.Z - OwnerPC.Pawn.Location.Z));
		
		TossVel.X = ( (Distance.X - (0.5f*((ParabolaTime**2))) ) / (ParabolaTime) );
		TossVel.Y = ( (Distance.Y - (0.5f*((ParabolaTime**2))) ) / (ParabolaTime) );
		TossVel.Z = ( (Distance.Z - (0.5f*((OwnerPC.Pawn.GetGravityZ()) * (ParabolaTime**2)))  / (ParabolaTime)  ) );
	
		if(Dir.X < 0)
		{
			TossVel.X = -TossVel.X;
			
		}
		else
		{
			TossVel.X = TossVel.X;
		}
		
		if(Dir.Y < 0)
		{
			TossVel.Y = -TossVel.Y;
			
		}
		else
		{
			TossVel.Y = TossVel.Y;
		}
		
		ThrownHammer = spawn(class'HLW_Barbarian_ThrowHammer', self,, OwnerPC.Pawn.Location, CasterEyeRot,, true);
		ThrownHammer.HammerSM.AddImpulse(TossVel,OwnerPC.Pawn.Location,, true);
		//ThrownHammer.SetRotation(OwnerPC.Pawn.Rotation);
		//HammerRot = ThrownHammer.HammerSM.Rotation;
		//HammerRot.Pitch -= 180 * DegToUnrRot;
		//ThrownHammer.HammerSM.SetRBRotation(HammerRot,);
		ThrownHammer.EndLocation = EndLocation;

		HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = VoiceClip;
		HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
	}
	
	if(Role < ROLE_Authority)
	{
		LandTimeDecal = Spawn(class'HLW_Decal_Cast', OwnerPC,, HitLocation, Rot(-16384, 0, 0));
		LandTimeDecal.SetRadius((AuraAmount + 1) * DamageRadius);
		LandTimeDecal.Activate(ParabolaTime);
	}
	
	AbilityComplete();
}

simulated function EndTossAnim()
{
	HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERSTATE, NORMAL, 0.25);
}

simulated state HammerLanded
{
	simulated function BeginState(Name PreviousStateName)
	{
		local Actor HitPawn;
		local HLW_StatusEffect_Slow_Hamstring LandSlow;
		//local HLW_Decal_DOT SlowDecal;
		
		foreach VisibleCollidingActors( class'Actor', HitPawn, (AuraAmount + 1) * DamageRadius, EndLocation)
		{
			if(HitPawn != OwnerPC.Pawn && HLW_Pawn(HitPawn) != None)
			{
				LandSlow = Spawn(class'HLW_StatusEffect_Slow_Hamstring', OwnerPC.Pawn);
				LandSlow.SlowPercentage = SlowPercentage;
				LandSlow.Duration = SlowDuration.CurrentValue;
				LandSlow.ParticleEffect = SlowParticle;
				HLW_Pawn(HitPawn).ApplyStatusEffect(LandSlow, OwnerPC);
				//SlowDecal = Spawn(class'HLW_Decal_DOT', OwnerPC,, HitPawn.Location, Rot(-16384, 0, 0));
				//SlowDecal.SetRadius(50);
				//SlowDecal.Activate(HitPawn, 1, LandSlow.Duration);
				HitPawn.TakeDamage(Damage.CurrentValue + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamage), OwnerPC, EndLocation, vect(0, 0, 0), class'HLW_DamageType_Magical',, self);
			}
		}
		
		if(HealDecal == None)
		{
			HealDecal = Spawn(class'HLW_AimingDecal',,, EndLocation, Rot(-16384, 0, 0));
			HealDecal.SetRadius((AuraAmount + 1) * HealRadius);	
			HealDecal.MatInst.SetScalarParameterValue('AbleToCast', 1);
		}

		HealCastCounter = 0;
		HealDecal.SetLocation(EndLocation);
		HealDecal.SetHidden(false);
		bCanHealDecal = true;
		
		SetTimer(HealTickTime, true, 'DoHealRadius');
		PlaySound(HammerImpactSound,,,, HitLocation);
		HLW_Pawn_Class(OwnerPC.Pawn).SpawnEmitter(LandParticle, EndLocation, OwnerPC.Pawn.Rotation,, 1.0f);
		GoToState('Inactive');
	}
	
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	
	if(bCanHealDecal)
	{
		HealCastCounter += DeltaTime;
		HealDecal.MatInst.SetScalarParameterValue('CastingTime', FMin(HealCastCounter / HealTickTime, 1.0f));
	}	
}


simulated function DoHealRadius()
{
	local HLW_Pawn_Class HitPawn;
	
	HealCounter++;
	HealCastCounter = 0;
	
	if(HealCounter > MaxHealCount)
	{
		HealDecal.SetHidden(true);
		ClearTimer('DoHealRadius');
		HealCounter = 0;
		bCanHealDecal = false;
		
		if(ThrownHammer != None)
		{
			ThrownHammer.Destroy();
		}
		
		HealCastCounter = 0;
	}
	
	if(Role == ROLE_Authority)
	{
		foreach DynamicActors(class'HLW_Pawn_Class', HitPawn)
		{
			if(VSize(EndLocation - HitPawn.Location) < (AuraAmount + 1) * HealRadius)
			{
				if(HitPawn != None)
				{
					if(HitPawn == OwnerPC.Pawn)
					{
						HitPawn.HealDamage(HealAmount.CurrentValue + (PhysPowPercentageAsHealing * OwnerPC.GetPRI().PhysicalPower), OwnerPC, class'HLW_DamageType_Magical');
					}
					else if(OwnerPC.Pawn.IsSameTeam(HitPawn))
					{
						HitPawn.HealDamage((HealAmount.CurrentValue + (PhysPowPercentageAsHealing * OwnerPC.GetPRI().PhysicalPower)) * TeamHealPercentage, OwnerPC, class'HLW_DamageType_Magical');
					}
				}		
			}
		}
	}
	
	//HurtRadius(-1 * HealAmount.CurrentValue, 250,class'HLW_DamageType_Magical', 0, EndLocation,,OwnerPC,true);
	
	HLW_Pawn_Class(OwnerPC.Pawn).SpawnEmitter(HealParticle, EndLocation, OwnerPC.Pawn.Rotation,, 1.0f);
}

simulated function AbilityComplete(bool bIsPremature = false)
{
	if(bIsPremature)
	{
		ClearTimer('IdleAnim');	
	}
	
	super.AbilityComplete(bIsPremature);
}

simulated function LevelUp()
{
	super.LevelUp();
	
	Damage.Upgrade(AbilityLevel);
	SlowDuration.Upgrade(AbilityLevel);
	HealAmount.Upgrade(AbilityLevel);
}

defaultproperties
{
	AimType=HLW_AAT_Free
	MaxHealCount=6
	HealCounter=0
	PhysPowPercentageAsDamage=0.3
	PhysPowPercentageAsHealing=0.2
	AuraPercentUsage=0.2
	TeamHealPercentage=0.5
	ParabolaTime=1
	
	bPreventsOtherAbilitiesWhileActive=true
	bPreventsPrimaryAttacksWhileActive=true
	bPreventsSecondaryAttacksWhileActive=true
	
	HealRadius=250
	DamageRadius=250
	HealCastCounter=0
	HealTickTime=1.0
	SlowParticle=ParticleSystem'HLW_AndrewParticles.Particles.FX_IceChunks'
	HealParticle=ParticleSystem'HLW_Package_Randolph.Farticles.Particle_HammerToss_Heal'
	LandParticle=ParticleSystem'HLW_Package_Randolph.Farticles.Particle_HammerToss_Land'
	VoiceClip=SoundCue'HLW_Package_Voices.Barbarian.Ability_HammerToss'
	HammerImpactSound=SoundCue'HLW_Package_Chris.SFX.Barbarian_Ability_HammerToss_Impact'
	
	Begin Object Class=HLW_UpgradableParameter Name=HealAmountParameter
		BaseValue=4
		Factor=0.2
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	HealAmount=HealAmountParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=35
		Factor=0.22
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=13
		//Factor=0.05
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=RangeParameter
		BaseValue=1000.0
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
		Factor=0.3
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	Damage=DamageParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=SlowDurationParameter
		BaseValue=1.5
		Factor=0.2
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	SlowDuration=SlowDurationParameter

	SlowPercentage=0.65
}