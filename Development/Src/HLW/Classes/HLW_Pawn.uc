/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Pawn extends UDKPawn;

struct HLW_HitInfo
{
	var float Time;
	var Controller Who;
};
//var array<HLW_HitInfo> HitInfoList;

var AnimNodePlayCustomAnim CustomAnimation;
var bool bIsOwner;

var int ExpReward;
var(HLW_Pawn) int BaseExpReward;
var(HLW_Pawn) float RegenRate;
var(HLW_Pawn) float LastHitBonusPercentage;
var float HPRegenCounter;
var float MPRegenCounter;

var bool bCanDrawDamage;
var int LastDamageTaken;

var float			HeadOffset;//HEADSHOT STUFF
var float           HeadRadius;
var float           HeadHeight;
var name			HeadBone;

var repnotify byte CanRagdoll;
var repnotify bool bStunPawn;

var array<HLW_StatusEffect> ActiveStatusEffects;

var ParticleSystemComponent PSC[5];

var repnotify ParticleSystem RepParticle;

var repnotify byte DecalByte;

var repnotify string HitDecalType;

replication
{
	if (bNetDirty)
		ExpReward, CanRagDoll, RepParticle, DecalByte, HitDecalType;
	if(bNetDirty && bNetOwner)
		bStunPawn;
}

simulated event ReplicatedEvent(name VarName)
{
    if(VarName == 'CanRagdoll')
    {
        ClientCauseRagdoll();
        return;
    }
    else if(VarName == 'bStunPawn')
    {
		ClientStunPlayer();
    }
	else if(VarName == 'DecalByte')
    {
		SpawnImpactDecal();
    }
	else if(VarName == 'HitDecalType')
    {
		SpawnHitDecal(HitDecalType);
		ResetHitDecal();
    }
    else if(VarName == 'RepParticle')
	{
		if(RepParticle != None)
		{
			PlayParticleSystem(RepParticle);
		}
		else
		{
			DeleteParticleSystem();	
		}
		
		return;
	}
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
    	AimNode = AnimNodeAimOffset(SkelComp.FindAnimNode('AimNode'));
		CustomAnimation = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('CustomAnimation'));
    }
}

simulated function StartFire(byte FireModeNum)
{
	//`log("Pawn:: Global StartFire - IsStunned:"@IsStunned());
	//if (!IsStunned())
	//{
		super.StartFire(FireModeNum);
	//}
}

simulated event Tick(float DeltaTime)
{
	local HLW_PlayerReplicationInfo PRI;
	
	PRI = HLW_PlayerReplicationInfo(PlayerReplicationInfo);

	super.Tick(DeltaTime);

	if (PRI != none && Controller != none && HLW_HUD_Class(HLW_PlayerController(Controller).myHUD) != none)
	{
		//HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).HudMovie.CallUpdateHealth(HealthMax, Health);
		//HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).HudMovie.CallUpdateMana(PRI.ManaMax, PRI.Mana);
		
		HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).HealthAndManaComponentHUD.CallUpdateCurrentHealth(Health);
		PRI.SetHealth(Health);
		HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).HealthAndManaComponentHUD.CallUpdateMaxHealth(HealthMax);
		HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).HealthAndManaComponentHUD.CallUpdateCurrentMana(PRI.Mana);
		HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).HealthAndManaComponentHUD.CallUpdateMaxMana(PRI.ManaMax);
	}
	
}

function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
	local int i;
	local HLW_PlayerReplicationInfo PRI;
	local int OriginalDamage;

	OriginalDamage = InDamage;

	super.AdjustDamage(InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);

	PRI = HLW_PlayerReplicationInfo(PlayerReplicationInfo);

	if (PRI != none)
	{
		// Negate some of the damage based on damage/armor type
		if (DamageType == class'HLW_DamageType_Physical')
		{
			InDamage -= (PRI.PhysicalDefense * InDamage);
		}
		else if (DamageType == class'HLW_DamageType_Magical')
		{
			InDamage -= (PRI.MagicalDefense * InDamage);
		}

		// Allow abilities to adjust damage
		for (i = 0; i < 5; i++)
		{
			if (PRI.Abilities[i] != none)
			{
				PRI.Abilities[i].AdjustDamage(InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);
			}
		}
	}

	if (DamageType == class'HLW_DamageType_Pure') // If it is pure damage, we don't want anything to affect it
	{
		InDamage = OriginalDamage;
	}

	if(PRI != none && InstigatedBy != Controller)
	{
		PRI.IncreaseTotalDamageTaken(InDamage);
	}
	if(InstigatedBy != Controller && HLW_PlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo) != none)
	{
		HLW_PlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo).IncreaseTotalDamageDone(InDamage);
	}
}

simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int i;
	local HLW_PlayerReplicationInfo PRI;
	local Controller ReplacementInstigator;
	local int NewDamage;
	
	//`log("HitInfo:"@HitInfo.Material@"&&"@HitInfo.PhysMaterial@"&&"@HitInfo.Item@"&&"@HitInfo.LevelIndex@"&&"@HitInfo.BoneName@"&&"@HitInfo.HitComponent);
	
	// Ignore the damage if we are the source of it
	if ((InstigatedBy != Controller || InstigatedBy == none))
	{
		// This allows us to get away with passing in "none" for InstigatedBy. May be a bad thing to keep in.
		ReplacementInstigator = InstigatedBy == none ? Controller : InstigatedBy;

		if(ReplacementInstigator != none && !IsSameTeam(ReplacementInstigator.Pawn))
		{
			PRI = HLW_PlayerReplicationInfo(PlayerReplicationInfo);
			NewDamage = Damage * DamageScaling;
			
			if(Role == ROLE_Authority)
			{
				if(DamageType == class'HLW_DamageType_Physical')
				{
					SpawnHitDecal("blood");
				}
				else if(DamageType == class'HLW_DamageType_Magical')
				{
					if(HLW_Projectile_Meteor(DamageCauser) != None || HLW_Projectile_Fire(DamageCauser) != None)
					{
						SpawnHitDecal("fire");
					}
					else if(HLW_Ability_FrostShield(DamageCauser) != None || HLW_Projectile_Frost(DamageCauser) != None)
					{
						SpawnHitDecal("frost");
					}
				}
			}
			
			super.TakeDamage(NewDamage, ReplacementInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
			
			//if(HLW_PlayerController(InstigatedBy) != None && Role == ROLE_Authority)
			//{
				//HLW_PlayerController(InstigatedBy).DrawDamage(Damage, "Physical");
			//}
			
			if (PRI != none)
			{
				//ManageAssists(InstigatedBy);

				// Notify abilities that we took damage
				for (i = 0; i < 5; i++)
				{
					if (PRI.Abilities[i] != none)
					{
						PRI.Abilities[i].OwnerPawnTookDamage(Damage, ReplacementInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
					}
				}
			}

			if (Health <= 0)
			{
				if (PRI != none)
				{
					for (i = 0; i < 5; i++)
					{
						PRI.Abilities[i].OwnerPawnDied(InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
					}
				}

				//for (i = 0; i < HitInfoList.Length; i++)
				//{
				//	if (HitInfoList[i].Who != none && HitInfoList[i].Who != InstigatedBy)
				//	{
				//		if (HitInfoList[i].Time - HLW_GameReplicationInfo(WorldInfo.GRI).MatchTimer < 10)
				//		{
				//			// award an assist eh?
				//			HLW_PlayerController(HitInfoList[i].Who).GetPRI().SetAssists();
				//		}
				//	}
				//}

				//HitInfoList.Remove(0, HitInfoList.Length);

				if (InstigatedBy != None && HLW_Pawn(InstigatedBy.Pawn) != none)
				{
					// Notify the killer that they killed this pawn, and what the damage causer was
					HLW_Pawn(InstigatedBy.Pawn).KilledPawnWith(self, DamageCauser, Location);

					// If the killer is not on the same team as this pawn...
					if (!IsSameTeam(InstigatedBy.Pawn))
					{
						// Handle the logic for distributing experience to eligible players in a separate function
						DistributeExperience(HLW_Pawn(InstigatedBy.Pawn), Location);
					}
				}
			}
		}
	}
}



simulated function StunPlayer(float Duration = 10.0)
{
	if(Role == ROLE_Authority)
	{
		bStunPawn = true;
		GetPC().StunPlayer(Duration);
	}
}

reliable client function ClientStunPlayer()
{
	GetPC().StunPlayer();	
}

simulated function HLW_PlayerController GetPC()
{
	return HLW_PlayerController(Controller);
}

//simulated function ManageAssists(Controller Attacker)
//{
//	local int i;
//	local HLW_HitInfo NewInfo;
//	local bool bAddNew;

//	bAddNew = true;

//	// Remove all entries whose time has expired
//	for (i = 0; i < HitInfoList.Length; i++)
//	{
//		if (HLW_GameReplicationInfo(WorldInfo.GRI).MatchTimer - HitInfoList[i].Time >= 10)
//		{
//			HitInfoList.Remove(i, 1);
//		}
//	}

//	for (i = 0; i < HitInfoList.Length; i++)
//	{
//		// Refresh the time on every entry that is still valid
//		HitInfoList[i].Time = HLW_GameReplicationInfo(WorldInfo.GRI).MatchTimer;

//		// If the current attacker already has an entry, we don't want to add it again
//		if (HitInfoList[i].Who == Attacker)
//		{
//			bAddNew = false;
//		}
//	}

//	if (bAddNew)
//	{
//		NewInfo.Who = Attacker;
//		NewInfo.Time = HLW_GameReplicationInfo(WorldInfo.GRI).MatchTimer;
//		HitInfoList.AddItem(NewInfo);
//	}
//}

simulated function DistributeExperience(HLW_Pawn Killer, Vector KillLocation);

// This is meant to be used for detecting what weapon/projectile, etc the pawn was killed by
// More parameters can be added if needed
simulated function KilledPawnWith(HLW_Pawn Killed, Actor KilledWith, Vector KillLocation);

function bool Died(Controller Killer, class<DamageType> DamageType, Vector HitLocation)
{
	local int i;


	for (i = 0; i < ActiveStatusEffects.Length; i++)
	{
		ActiveStatusEffects[i].Expire();
		//ActiveStatusEffects.Remove(i--, 1);
	}


	return super.Died(Killer, DamageType, HitLocation);
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    GotoState('Dying');
    bReplicateMovement = false;
    CauseRagdoll();
    bTearOff = true;
    Velocity += TearOffMomentum;
    SetDyingPhysics();
    bPlayedDeath = true;

    KismetDeathDelayTime = default.KismetDeathDelayTime + WorldInfo.TimeSeconds;
}

simulated function CauseRagdoll()
{
    EnableRagdoll();
    CanRagdoll++;
    
    if(Role < ROLE_Authority)
    {
        ServerCauseRagdoll();
    }
}

reliable server function ServerCauseRagdoll()
{
    CauseRagdoll(); 
}

reliable client function ClientCauseRagdoll()
{
    EnableRagdoll();
}

function EnableRagdoll()
{
    if(Mesh.PhysicsAssetInstance != None)
    {
        Mesh.SetOwnerNoSee(false);
        Mesh.MinDistFactorForKinematicUpdate = 0.f;
        Mesh.SetRBChannel(RBCC_Pawn);
        Mesh.SetRBCollidesWithChannel(RBCC_Default, true);
        Mesh.SetRBCollidesWithChannel(RBCC_Pawn, false);
        Mesh.SetRBCollidesWithChannel(RBCC_Vehicle, false);
        Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, false);
        Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume, true);
        Mesh.ForceSkelUpdate();
        Mesh.SetTickGroup(TG_PostAsyncWork);
        CollisionComponent = Mesh;
        CylinderComponent.SetActorCollision(false, false);
        Mesh.SetActorCollision(true, false);
        Mesh.SetTraceBlocking(true, true);
        SetPhysics(PHYS_Falling);
        Mesh.PhysicsWeight = 1.0;
    
        if (Mesh.bNotUpdatingKinematicDueToDistance)
        {
            Mesh.UpdateRBBonesFromSpaceBases(true, true);
        }
    
        Mesh.PhysicsAssetInstance.SetAllBodiesFixed(false);
        Mesh.bUpdateKinematicBonesFromAnimation = false;
        Mesh.SetRBLinearVelocity(Velocity, false);
        Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
        Mesh.SetNotifyRigidBodyCollision(true);
        Mesh.WakeRigidBody();
    }
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	SetTimer(RegenRate, true, 'OnRegen');
}

simulated function OnRegen()
{
	local int HealthRegenAmount, ManaRegenAmount;
	local HLW_Pawn_Class ClassSelf;

	ClassSelf = HLW_Pawn_Class(self);

	if (ClassSelf != none && PlayerReplicationInfo != none)
	{
		HPRegenCounter += (ClassSelf.GetPRI().HP5 / 5.0) * RegenRate;
		HealthRegenAmount = FFloor(HPRegenCounter);
		HPRegenCounter -= HealthRegenAmount;
		Health = Min(HealthMax, Health + HealthRegenAmount);

		MPRegenCounter += (ClassSelf.GetPRI().MP5 / 5.0) * RegenRate;
		ManaRegenAmount = FFloor(MPRegenCounter);
		MPRegenCounter -= ManaRegenAmount;
		ClassSelf.GetPRI().SetMana( ClassSelf.GetPRI().Mana + ManaRegenAmount );
	}
}

function ApplyStatusEffect(HLW_StatusEffect StatusEffect, Controller EffectInstigator, optional Actor EffectOwner)
{
	if (StatusEffect != none && EffectInstigator != none)
	{
		if (StatusEffect.CanBeAppliedTo(self, EffectInstigator))
		{
			ActiveStatusEffects.AddItem(StatusEffect);
			StatusEffect.Initiate(self, EffectInstigator, EffectOwner);
		}
	}
}

/*
 * Status effects will remove themselves when their lifetime is up (as long as they were Initiate()ed).
 * However, this function can still be called to remove them prematurely.
 */
function RemoveStatusEffect(HLW_StatusEffect StatusEffect)
{
	local int i;

	if (StatusEffect != none)
	{
		if (!StatusEffect.HasExpired())
		{
			StatusEffect.Expire();
		}

		for (i = 0; i < ActiveStatusEffects.Length; i++)
		{
			if (ActiveStatusEffects[i] == StatusEffect)
			{
				ActiveStatusEffects.Remove(i--, 1);
			}
		}
	}
}


simulated state Stunned
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		
	}
	
	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		
		
	}	
}

function StunTimer()
{
	`log("Pawn:: Stun Expire");
	if (HLW_PlayerController(Controller) != none)
	{
		HLW_PlayerController(Controller).SetCinematicMode(false, false, false, true, true, false);

		HLW_PlayerController(Controller).bCanAttackPrimary = true;
		HLW_PlayerController(Controller).bCanAttackSecondary = true;
		HLW_PlayerController(Controller).bCanUseAbilities = true;
		HLW_PlayerController(Controller).bCanAcceptLookInput = true;
		HLW_PlayerController(Controller).IgnoreMoveInput(false);
	}
}

function bool IsStunned()
{
	return IsTimerActive('StunTimer');
}

function float GetRemainingStunTime()
{
	return IsStunned() ? GetRemainingTimeForTimer('StunTimer') : 0.0f;
}

simulated function PlayParticleSystem(ParticleSystem NewParticle)
{
	local byte i;
	
	RepParticle = NewParticle;
	
	for(i = 0; i < ArrayCount(PSC); i++)
	{
		if((PSC[i]).SystemHasCompleted() || !(PSC[i]).bIsActive)
		{
			(PSC[i]).SetTemplate(NewParticle);
			(PSC[i]).ActivateSystem();
			(PSC[i]).SetActive(true);
			(PSC[i]).OnSystemFinished = ResetParticleSystem;
			
			return;
		}
	}
}

reliable server function DeleteParticleSystem()
{
	RepParticle = None;
}

simulated function ResetParticleSystem(ParticleSystemComponent CompletedParticleSystemComponent)
{
	RepParticle = None;
	CompletedParticleSystemComponent.DeactivateSystem();
	CompletedParticleSystemComponent.SetActive(false);
	DeleteParticleSystem();
}

simulated function SpawnImpactDecal()
{
	local Vector spawnloc;
	
	DecalByte++;
	
	if(Role < ROLE_Authority)
	{
		spawnloc = Location;
		spawnloc.Z -= GetCollisionHeight();
		Spawn(class'HLW_Decal_Blood', self,, spawnloc, Rot(-16384,0,0));
		WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'HLW_Package_Randolph.Farticles.Blood_Particle_Temp', Location, Rotation);
	}
}

simulated function SpawnHitDecal(string DecalType)
{
	local Vector spawnloc;
	
	HitDecalType = DecalType;
	
	if(Role < ROLE_Authority)
	{
		spawnloc = Location;
		spawnloc.Z -= GetCollisionHeight();

		switch(DecalType)
		{
			case "blood":
				Spawn(class'HLW_Decal_Blood', self,, spawnloc, Rot(-16384,0,0));
				WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'HLW_Package_Randolph.Farticles.Blood_Particle_Temp', Location, Rotation);
				break;
			case "fire":
				Spawn(class'HLW_Decal_Fireburn', self,, spawnloc, Rot(-16384,0,0));
				break;
			case "frost":
				Spawn(class'HLW_Decal_Frostburn', self,, spawnloc, Rot(-16384,0,0));
				break;	
		}
	}
}

unreliable server function ResetHitDecal()
{
	`log("Reset decal");
	HitDecalType = "none";	
}

defaultproperties
{
	LastHitBonusPercentage=0.2
	RegenRate=2.0
	HealthMax=300 // This is currently using Pawn's Health, which is an int. Might need to use our own as a float
	Health=300
	GroundSpeed=400

	BaseExpReward=50
	ExpReward=50
	
	bAlwaysRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	HPRegenCounter=0.0
	MPRegenCounter=0.0
	
	HeadRadius=+9.0
	HeadHeight=5.0
	HeadScale=+1.0
	HeadOffset=32
	
	bStunPawn=false
	DecalByte=0
	
	HitDecalType=""
	
	Begin Object Class=ParticleSystemComponent Name=PSC_1
		bAutoActivate=false
		bIsActive=false
	End Object
	//PSC1=PSC_1
	PSC(0)=PSC_1
	Components.Add(PSC_1)
	
	Begin Object Class=ParticleSystemComponent Name=PSC_2
		bAutoActivate=false
		bIsActive=false
	End Object
	//PSC2=PSC_2
	PSC(1)=PSC_2
	Components.Add(PSC_2)
	
	Begin Object Class=ParticleSystemComponent Name=PSC_3
		bAutoActivate=false
		bIsActive=false
	End Object
	//PSC3=PSC_3
	PSC(2)=PSC_3
	Components.Add(PSC_3)
	
	Begin Object Class=ParticleSystemComponent Name=PSC_4
		bAutoActivate=false
		bIsActive=false
	End Object
	//PSC4=PSC_4
	PSC(3)=PSC_4
	Components.Add(PSC_4)
	
	Begin Object Class=ParticleSystemComponent Name=PSC_5
		bAutoActivate=false
		bIsActive=false
	End Object
	//PSC5=PSC_5
	PSC(4)=PSC_5
	Components.Add(PSC_5)
}