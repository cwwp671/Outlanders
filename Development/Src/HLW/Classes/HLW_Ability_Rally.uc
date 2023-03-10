/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Ability_Rally extends HLW_Ability;

var(Ability) int Radius;
var(Ability) float AuraPercentUsage;

var ParticleSystem RallyParticle;
var ParticleSystem BuffParticle;

var(Ability) HLW_UpgradableParameter MoveBuffUP;
var(Ability) HLW_UpgradableParameter HealthPercOverDuration;
var(Ability) HLW_UpgradableParameter ManaPercOverDuration;
var(Ability) HLW_UpgradableParameter Duration;

var(Ability) SoundCue VoiceClip;
var(Ability) SoundCue RallySound;

state Aiming
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		AimingDecal.SetRadius(Radius);
	}
	
	simulated function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);
		
		if(HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]) != None)
		{
			AimingDecal.SetRadius((HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]).GetAuraPercentage(AuraPercentUsage) + 1) * Radius);
		}
	}
}

simulated function ActivateAbility()
{
	local HLW_StatusEffect_Buff MoveBuff;
	local HLW_StatusEffect_Buff HP5Buff;
	local HLW_StatusEffect_Buff MP5Buff;
	local float AuraAmount;
	local HLW_Pawn HitPawn;
	
	//local Vector ParticleLocation;
	
	super.ActivateAbility();
	
	OwnerPC.Pawn.Weapon.GotoState('Active');
	
	ConsumeResources();
	//StartCooldown();
	
	//ParticleLocation = OwnerPC.Pawn.Location;
	//ParticleLocation.Z -= OwnerPC.Pawn.GetCollisionHeight();
	HLW_Pawn(OwnerPC.Pawn).RepParticle = RallyParticle;
	HLW_Pawn(OwnerPC.Pawn).PlayParticleSystem(HLW_Pawn(OwnerPC.Pawn).RepParticle);
	
	
	
	//HLW_Pawn_Class(OwnerPC.Pawn).SpawnEmitter(RallyParticle, ParticleLocation, OwnerPC.Pawn.Rotation,, 1.0f);
	HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERSTATE, RALLY);
	SetTimer(1.0, false, 'ResetRallyAnim');
	
	if(Role == ROLE_Authority)
	{
		HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = VoiceClip;
		HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
		
		if(HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]) != None)
		{
			AuraAmount = HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]).UseAura(AuraPercentUsage);
			//`log("AURA AMOUNT"@AuraAmount);
		}
		
		foreach VisibleCollidingActors( class'HLW_Pawn', HitPawn, Radius * (AuraAmount + 1), OwnerPC.Pawn.Location)
		{
			if(HLW_Pawn_Class(HitPawn) != None && HLW_Pawn_Class(HitPawn).GetPRI() != None && HLW_Pawn_Class(HitPawn).GetPRI().Team != None)
			{
									//TeamMate Buff!!
				if(HLW_Pawn_Class(HitPawn).GetPRI().Team != None && HLW_Pawn_Class(HitPawn).GetPRI().Team.TeamIndex == HLW_Pawn_Class(OwnerPC.Pawn).GetPRI().Team.TeamIndex)
				{
					MoveBuff = Spawn(class'HLW_StatusEffect_Buff', OwnerPC);
					MoveBuff.StatToAffect = HLW_Stat_MovementSpeed;
					MoveBuff.BuffAmount = MoveBuffUP.CurrentValue;
					MoveBuff.Duration = Duration.CurrentValue;
					
					HP5Buff = Spawn(class'HLW_StatusEffect_Rally', OwnerPC.Pawn);
					HP5Buff.StatToAffect = HLW_Stat_HP5;
					HP5Buff.Duration = Duration.CurrentValue;
					HP5Buff.BuffAmount = ((HealthPercOverDuration.CurrentValue * HitPawn.HealthMax) / HP5Buff.Duration) * 5.0f;
	
					MP5Buff = Spawn(class'HLW_StatusEffect_Rally', OwnerPC.Pawn);
					MP5Buff.StatToAffect = HLW_Stat_MP5;
					MP5Buff.Duration = Duration.CurrentValue;
					MP5Buff.BuffAmount = ((ManaPercOverDuration.CurrentValue * HLW_PlayerReplicationInfo(HitPawn.PlayerReplicationInfo).ManaMax) / MP5Buff.Duration) * 5.0f;
					
					HitPawn.ApplyStatusEffect(MoveBuff, OwnerPC);
					HitPawn.ApplyStatusEffect(HP5Buff, OwnerPC);
					HitPawn.ApplyStatusEffect(MP5Buff, OwnerPC);
					
					HitPawn.RepParticle = BuffParticle;
					HitPawn.PlayParticleSystem(HitPawn.RepParticle);
				}
			}
							//Your Buff!!
			if(HitPawn != None && HitPawn == OwnerPC.Pawn)
			{
				MoveBuff = Spawn(class'HLW_StatusEffect_Buff', OwnerPC);
				MoveBuff.StatToAffect = HLW_Stat_MovementSpeed;
				MoveBuff.BuffAmount = MoveBuffUP.CurrentValue;
				MoveBuff.Duration = Duration.CurrentValue;
					
				HP5Buff = Spawn(class'HLW_StatusEffect_Rally', OwnerPC.Pawn);
				HP5Buff.StatToAffect = HLW_Stat_HP5;
				HP5Buff.Duration = Duration.CurrentValue;
				HP5Buff.BuffAmount = ((HealthPercOverDuration.CurrentValue * OwnerPC.Pawn.HealthMax) / HP5Buff.Duration) * 5.0f;
	
				MP5Buff = Spawn(class'HLW_StatusEffect_Rally', OwnerPC.Pawn);
				MP5Buff.StatToAffect = HLW_Stat_MP5;
				MP5Buff.Duration = Duration.CurrentValue;
				MP5Buff.BuffAmount = ((ManaPercOverDuration.CurrentValue * OwnerPC.GetPRI().ManaMax) / MP5Buff.Duration) * 5.0f;
					
				HitPawn.ApplyStatusEffect(MoveBuff, OwnerPC);
				HitPawn.ApplyStatusEffect(HP5Buff, OwnerPC);
				HitPawn.ApplyStatusEffect(MP5Buff, OwnerPC);
				
				HitPawn.RepParticle = BuffParticle;
				HitPawn.PlayParticleSystem(HitPawn.RepParticle);
			}		
		}
	}
	
	PlaySound(RallySound,,,, HitLocation);
	SetTimer(Duration.CurrentValue, false, 'BuffExpire');
	//AbilityComplete();
}

simulated function BuffExpire()
{
	StartCooldown();
	AbilityComplete();
}

simulated function ResetRallyAnim()
{
	HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERSTATE, NORMAL);	
}

simulated function LevelUp()
{
	super.LevelUp();
	
	MoveBuffUP.Upgrade(AbilityLevel);
	HealthPercOverDuration.Upgrade(AbilityLevel);
	ManaPercOverDuration.Upgrade(AbilityLevel);
	Duration.Upgrade(AbilityLevel);
}

simulated function AbilityComplete(bool bIsPremature = false)
{
	if(bIsPremature)
	{
		if(IsTimerActive('BuffExpire'))
		{
			ClearTimer('BuffExpire');
			StartCooldown();
		}
	}
	
	super.AbilityComplete(bIsPremature);
}

defaultproperties
{
	Radius=225
	AuraPercentUsage=0.5f
	RallyParticle=ParticleSystem'hlw_andrewparticles.Particles.FX_RallyShockwave'//ParticleSystem'HLW_Package_Randolph.Farticles.Particle_Rally'
	BuffParticle=ParticleSystem'HLW_Package_Randolph.Farticles.Particle_Rally_Buff'
	VoiceClip=SoundCue'HLW_Package_Voices.Barbarian.Ability_Rally'
	RallySound=SoundCue'HLW_Package_Chris.SFX.Barbarian_Ability_Rally'
	
	AimType=HLW_AAT_Fixed
	
	//bPreventsOtherAbilitiesWhileActive=true
	//bPreventsPrimaryAttacksWhileActive=true
	//bPreventsSecondaryAttacksWhileActive=true

	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=70
		Factor=0.2
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=60.0
		//Factor=0.05
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CastTimeParameter
		BaseValue=0.0
		UpgradeType=HLW_UT_None
	End Object
	CastTime=CastTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=MoveBuffParameter
		BaseValue=50.0
		Factor=0.05
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object	
	MoveBuffUP=MoveBuffParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=HealthPercOverDurationParameter
		BaseValue=0.15
		Factor=0.1
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object	
	HealthPercOverDuration=HealthPercOverDurationParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=ManaPercOverDurationParameter
		BaseValue=0.15
		Factor=0.1
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object	
	ManaPercOverDuration=ManaPercOverDurationParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=DurationParameter
		BaseValue=20.0
		UpgradeType=HLW_UT_None
	End Object
	Duration=DurationParameter
	
//ParticleSystem'HLW_Package_Randolph.Farticles.RallyStart'
//ParticleSystem'HLW_Package_Randolph.Farticles.RallyEffect'
}