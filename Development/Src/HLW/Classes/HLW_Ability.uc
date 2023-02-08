/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 * Base class for all class abilities.
 * Any code the abilities share in common should go here.
 * Contains code for positioning the aiming mesh, and base functions for activation/etc
 */
 
class HLW_Ability extends ReplicationInfo;

// Subclasses should set this to their individual aiming decals
var(Ability) HLW_AimingDecal AimingDecal;

enum AbilityAimType
{
	HLW_AAT_Free,           // Aim with mouse movement
	HLW_AAT_Fixed,          // Stays at a fixed position (caster location + offset)
	HLW_AAT_MovementBased,  // Positioned in front of the caster in whichever direction he is moving
	HLW_AAT_ActorTarget,    // Is positioned under a traced HLW_Pawn or under the caster if no target
	HLW_AAT_FixedCone,		// LUKAS - Trying to add a fixed cone to be used for a lot of our melee stuff
	HLW_AAT_Instant,        // Skips aiming state and goes straight to casting
	HLW_AAT_None            // For passives only
};

var(Ability) AbilityAimType AimType;
var(Ability) HLW_UpgradableParameter ManaCost;
var(Ability) HLW_UpgradableParameter CooldownTime;
var(Ability) HLW_UpgradableParameter Range;
var(Ability) HLW_UpgradableParameter CastTime;
var(Ability) int AbilityLevel;
var(Ability) bool bPreventsOtherAbilitiesWhileActive;
var(Ability) bool bPreventsPrimaryAttacksWhileActive;
var(Ability) bool bPreventsSecondaryAttacksWhileActive;
var(Ability) bool bPreventsMoveInputWhileActive;
var(Ability) bool bPreventsLookInputWhileActive;
var(Ability) bool bUsableWhenStunned;
var(Ability) bool bInvalidHitLocation;

var Texture2D DecalImage;

var Vector HitLocation;
var byte AbilityIndex;
var HLW_Pawn TraceHitPawn;
var protectedwrite bool bIsFree;
var HLW_PlayerController OwnerPC;
var protectedwrite bool bIsActive;
var bool bIsCasting;
var float CastingCounter;

replication
{
	if (bNetDirty && bNetOwner)
		bIsFree, OwnerPC, bIsActive, AbilityIndex,
		bPreventsOtherAbilitiesWhileActive, bPreventsPrimaryAttacksWhileActive,
		bPreventsSecondaryAttacksWhileActive, bPreventsLookInputWhileActive, bPreventsMoveInputWhileActive;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if (HLW_PlayerController(Owner) != none)
	{
		OwnerPC = HLW_PlayerController(Owner);
	}
}

auto state Inactive
{
	simulated event BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		//HideTheDangDecal();
	}
}

state Aiming
{
	simulated event BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		// The server needs to know about the decal position, but only the client should determine if it's being shown
		if (AimingDecal == none)
		{
			AimingDecal = Spawn(class'HLW_AimingDecal',,,OwnerPC.Pawn.Location, Rot(-16384,0,0));  
			AimingDecal.MatInst.SetScalarParameterValue('CastingTime', 0);
			AimingDecal.MatInst.SetTextureParameterValue('SpellSymbol', DecalImage);
		}
		
		if(AimType == HLW_AAT_FixedCone)
		{
			AimingDecal.MatInst.SetParent(Material'HLW_mapProps.guimaterials.SpellCast_Cone_Master');	
		}
		
		if (Role < ROLE_Authority)
		{
			AimingDecal.SetHidden(false);
		}
	}

	simulated event Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);
	
		// CJL see about making it so only client will tick this, but server sets the locations in EndState or similar?
		if(AimType != HLW_AAT_None && OwnerPC != none && OwnerPC.Pawn != none)
		{
			if (AimType == HLW_AAT_Free)
			{
				HandleFreeAiming();
			}
			else if (AimType == HLW_AAT_Fixed)
			{
				HandleFixedAiming();
			}
			else if (AimType == HLW_AAT_FixedCone)
			{
				HandleFixedConeAiming();
			}
			else if (AimType == HLW_AAT_MovementBased)
			{
				HandleMovementBasedAiming();
			}
			else if (AimType == HLW_AAT_ActorTarget)
			{
				HandleActorTargetAiming();
			}
		}
	}
	
	simulated function HandleFreeAiming()
	{
		local Rotator CurrentEyeRotation;
		local Vector CurrentEyePosition, HitNormal, TraceEnd, TraceStart, TraceDownEnd, GroundLocation;

		OwnerPC.GetPlayerViewPoint(CurrentEyePosition, CurrentEyeRotation);

		TraceEnd = OwnerPC.Pawn.Location + Vector(CurrentEyeRotation) * Range.CurrentValue;
		TraceStart = OwnerPC.Pawn.Location;
		TraceStart.Z += OwnerPC.Pawn.GetCollisionHeight();
		
		Trace(HitLocation, HitNormal, TraceEnd, TraceStart);
		
		//DrawDebugLine(TraceStart, TraceEnd, 255, 0, 0, false);
		
		if(HitLocation != vect(0,0,0) && VSize(HitLocation - OwnerPC.Pawn.Location) <= Range.CurrentValue)
		{
			AimingDecal.MatInst.SetScalarParameterValue('AbleToCast', 1);
			bInvalidHitLocation = false;		
		}
		else
		{
			if(VSize(HitLocation - OwnerPC.Pawn.Location) > Range.CurrentValue)
			{
				HitLocation.X = OwnerPC.Pawn.Location.X + Vector(CurrentEyeRotation).X * Range.CurrentValue;
				HitLocation.Y = OwnerPC.Pawn.Location.Y + Vector(CurrentEyeRotation).Y * Range.CurrentValue;
				TraceDownEnd = TraceEnd;
				TraceDownEnd.Z -= Range.CurrentValue;

				//DrawDebugLine(TraceEnd, TraceDownEnd, 0, 255, 0, false);
				
				Trace(GroundLocation, HitNormal, TraceDownEnd, TraceEnd);
				HitLocation.Z = GroundLocation.Z;
				
				if(VSize(GroundLocation - OwnerPC.Pawn.Location) <= Range.CurrentValue + 15/*abs(GroundLocation.Z - OwnerPC.Pawn.Location.Z) <= Range.CurrentValue && abs(GroundLocation.X - OwnerPC.Pawn.Location.X) <= Range.CurrentValue && abs(GroundLocation.Y - OwnerPC.Pawn.Location.Y) <= Range.CurrentValue*/)
				{
					bInvalidHitLocation = false;
					AimingDecal.MatInst.SetScalarParameterValue('AbleToCast', 1);
				}
				else
				{
					bInvalidHitLocation = true;
					AimingDecal.MatInst.SetScalarParameterValue('AbleToCast', 0);
				}
			}
			else
			{
				bInvalidHitLocation = true;
				AimingDecal.MatInst.SetScalarParameterValue('AbleToCast', 0);
			}
		}
		
		AimingDecal.SetLocation(HitLocation);
		AimingDecal.SetRotation( MakeRotator(-16384, OwnerPC.Pawn.Rotation.Roll, OwnerPC.Pawn.Rotation.Yaw) );
	}

	simulated function HandleFixedAiming(int Offset = 0)
	{
		AimingDecal.SetLocation( OwnerPC.Pawn.Location + Vector(OwnerPC.Pawn.Rotation) * Offset );
		AimingDecal.SetRotation( MakeRotator(-16384, OwnerPC.Pawn.Rotation.Roll, OwnerPC.Pawn.Rotation.Yaw) );
		
		HitLocation = AimingDecal.Decal.Location;

		if(HitLocation != vect(0,0,0))
		{
			AimingDecal.MatInst.SetScalarParameterValue('AbleToCast', 1);
			bInvalidHitLocation = false;
		}
		else
		{
			AimingDecal.MatInst.SetScalarParameterValue('AbleToCast', 0);
			bInvalidHitLocation = true;
		}
	}
	
	simulated function HandleFixedConeAiming(int Offset = 0)
	{
		AimingDecal.SetLocation( OwnerPC.Pawn.Location + Vector(OwnerPC.Pawn.Rotation) * Offset );
		AimingDecal.SetRotation( MakeRotator(-16384, OwnerPC.Pawn.Rotation.Roll, OwnerPC.Pawn.Rotation.Yaw) );
		
		HitLocation = AimingDecal.Decal.Location;
		
		if(HitLocation != vect(0,0,0))
		{
			AimingDecal.MatInst.SetScalarParameterValue('AbleToCast', 1);
			bInvalidHitLocation = false;
		}
		else
		{
			AimingDecal.MatInst.SetScalarParameterValue('AbleToCast', 0);
			bInvalidHitLocation = true;
		}
	}
	
	simulated function HandleMovementBasedAiming(int Offset = 300)
	{
		local Rotator CurrentEyeRotation;
		local Vector CurrentEyePosition, HitNormal, TraceEnd, TraceStart;

		OwnerPC.GetPlayerViewPoint(CurrentEyePosition, CurrentEyeRotation);

		AimingDecal.SetLocation( OwnerPC.Pawn.Location + Normal(OwnerPC.Pawn.Velocity) * Offset);
		AimingDecal.SetRotation( MakeRotator(-16384, OwnerPC.Pawn.Rotation.Roll, OwnerPC.Pawn.Rotation.Yaw) );
		
		TraceEnd = AimingDecal.Location;
		TraceEnd.Z -= 1000;
		TraceStart = AimingDecal.Location;
		TraceStart.Z += 1000;
		
		Trace(HitLocation, HitNormal, TraceEnd, TraceStart);

		if(HitLocation != vect(0,0,0))
		{
			AimingDecal.MatInst.SetScalarParameterValue('AbleToCast', 1);
			bInvalidHitLocation = false;
		}
		else
		{
			AimingDecal.MatInst.SetScalarParameterValue('AbleToCast', 0);
			bInvalidHitLocation = true;
		}
	}

	// TODO: add options for bTargetAllies, bTargetEnemies, bCanTargetSelf
	simulated function HandleActorTargetAiming()
	{
		local Vector TraceHitLocation, TraceHitNormal, CasterEyePosition, TraceEndLocation;
		local Rotator CasterEyeRotation;

		// Get the caster's eye position and rotation
		OwnerPC.GetPlayerViewPoint(CasterEyePosition, CasterEyeRotation);

		// Get the farthest point the ability can reach
		TraceEndLocation = OwnerPC.Pawn.Location + Vector(CasterEyeRotation) * Range.CurrentValue;

		// Look for someone to target
		// TODO: Try using TraceActors instead
		TraceHitPawn = HLW_Pawn( OwnerPC.Pawn.Trace(TraceHitLocation, TraceHitNormal, TraceEndLocation,,,vect(100,100,1)) );

		if (TraceHitPawn != none)
		{
			AimingDecal.SetLocation( TraceHitPawn.Location );
			AimingDecal.SetRotation( MakeRotator(-16384, OwnerPC.Pawn.Rotation.Roll, OwnerPC.Pawn.Rotation.Yaw) );
		}
		else
		{
			// If we didn't find someone to target, target the caster
			AimingDecal.SetLocation( OwnerPC.Pawn.Location );
			AimingDecal.SetRotation( MakeRotator(-16384, OwnerPC.Pawn.Rotation.Roll, OwnerPC.Pawn.Rotation.Yaw) );

			TraceHitPawn = HLW_Pawn(OwnerPC.Pawn);
		}
		

		AimingDecal.MatInst.SetScalarParameterValue('AbleToCast', 1);
	}

	simulated event EndState(name NextStateName)
	{
		super.EndState(NextStateName);

		// CJL sometimes the decal doesn't go away. it seems like it may be because of network lag.
		// could possibly because the client is never actually being told to call this function?
		// maybe make a client function for it to make sure it gets called?
		bInvalidHitLocation = false;
		//HideTheDangDecal();
	}
}

// Any other necessary or aesthetic code can be added here
simulated function StartAiming()
{
	GotoState('Aiming');
}

// Any other necessary or aesthetic code can be added here
simulated function StopAiming()
{
	//HideTheDangDecal();
	GotoState('Inactive');
}

simulated function StopAimAnimation(); //For abilities with aiming animations

// This will start the casting timer and play casting animations/effects
simulated function StartCasting(optional HLW_Pawn_Class UserIn, optional bool bIsFreeAbility = false)
{
	bIsFree = bIsFreeAbility;
	bIsCasting = true;

	ServerSetIsFreeAbility(bIsFree);

	StopAiming();

	if (CastTime.CurrentValue <= 0.0f)
	{
		if(AimingDecal != None)
		{
			AimingDecal.MatInst.SetScalarParameterValue('CastingTime', 1.0);
		}
		
		bIsCasting = false;
		HideTheDangDecal();
		ActivateAbility();
	}
	else
	{
		if(AimingDecal != None)
		{
			AimingDecal.MatInst.SetScalarParameterValue('CastingTime', 0.0);
		}
		
		CastingCounter = 0;
		SetTimer(CastTime.CurrentValue, false, 'ActivateAbility');
	}
}

reliable server function ServerSetIsFreeAbility(bool bIsFreeAbility)
{
	bIsFree = bIsFreeAbility;
}

simulated function ActivateAbility()
{
	HideTheDangDecal();
	bIsCasting = false;
	bIsActive = true;

	OwnerPC.AbilityActivated(self);
}

simulated function AbilityComplete(bool bIsPremature = false)
{
	if(bIsPremature == true)
	{
		GoToState('Inactive');
	}
	
	HideTheDangDecal();
	bIsActive = false;
	bIsFree = false;
	OwnerPC.AbilityEnded(self);
}

simulated function ConsumeResources()
{
	//HideTheDangDecal();

	if (Role < ROLE_Authority)
	{
		ServerConsumeResources();
		return;
	}

	if (!bIsFree)
	{
		OwnerPC.GetPRI().SetMana( OwnerPC.GetPRI().Mana - ManaCost.CurrentValue );
	}
}

reliable server function ServerConsumeResources()
{
	//HideTheDangDecal();

	if (Role == ROLE_Authority)
	{
		ConsumeResources();
	}
}

simulated function StartCooldown()
{
	local float time;
	//HideTheDangDecal();

	if (!bIsFree)
	{
		time = CooldownTime.CurrentValue;

		if (OwnerPC.GetPRI() != none)
		{
			time -= (CooldownTime.CurrentValue * OwnerPC.GetPRI().CooldownReduction);
		}
	
		SetTimer(time, false, 'OnCooldownComplete');
	}

	if (Role < ROLE_Authority)
	{
		ServerStartCooldown();
	}

	if (bIsFree)
	{
		OnCooldownComplete();
	}
}

reliable server function ServerStartCooldown()
{
	//HideTheDangDecal();

	if (Role == ROLE_Authority)
	{
		StartCooldown();
	}
}

simulated function Tick(float DeltaTime)
{
	if (Role < ROLE_Authority && OwnerPC != none && HLW_HUD_Class(OwnerPC.myHUD) != none && OwnerPC.GetPRI() != none)
	{
		HLW_HUD_Class(OwnerPC.myHUD).AbilityComponentHUD.CallAbilityUpdate(AbilityIndex, RemainingCooldown(), OwnerPC.GetPRI().Mana >= ManaCost.CurrentValue, bIsActive);
	}
	
	if(bIsCasting)
	{
		CastingCounter += DeltaTime;
		AimingDecal.MatInst.SetScalarParameterValue('CastingTime', FMin(CastingCounter / CastTime.CurrentValue, 1.0f));
	}

	super.Tick(DeltaTime);	
}

simulated function OnCooldownComplete()
{
}

simulated function LevelUp()
{
	if (Role == ROLE_Authority && WorldInfo.NetMode != NM_Standalone)
	{
		ClientLevelUp();
	}

	AbilityLevel++;

	CastTime.Upgrade(AbilityLevel);
	CooldownTime.Upgrade(AbilityLevel);
	ManaCost.Upgrade(AbilityLevel);
	Range.Upgrade(AbilityLevel);
}

reliable client function ClientLevelUp()
{
	LevelUp();
	
	// Might need to put this back in?
	HLW_HUD_Class(OwnerPC.myHUD).AbilityComponentHUD.CallAbilityLevelUp(AbilityIndex, AbilityLevel);
}

simulated function bool IsInCone(Pawn P, float AngleDeg, float Distance)
{
	local Rotator angle;
	local float angle1;
	local float angle2;
	
	if(Role == ROLE_Authority)
	{
		if(VSize(P.Location - OwnerPC.Pawn.Location) <= Distance)
		{
			angle = Normalize(Rotator(P.Location - OwnerPC.Pawn.Location));
			angle1 = (Abs((angle.Yaw * UnrRotToDeg) % 360));
			angle2 = (Abs((OwnerPC.Pawn.Rotation.Yaw * UnrRotToDeg) % 360));
			
			//`log("HERES THE PERFECT ANGLE: ME:"@angle2@"OTHER :"@angle1);
			if(Abs(angle1 - angle2) <= AngleDeg)
			{
				return true;
			}
		}
	}
	return false;
}

simulated function GotStunned()
{
	//`log(self@"Got Stunned");
	
	if(IsInState('Aiming'))
	{
		StopAiming();	
	}
	else
	{
		// If this ability was being cast
		if (IsBeingCast())
		{
			ClearTimer('ActivateAbility');
		}

		AbilityComplete(true);
	}

	HideTheDangDecal();
}

simulated function OwnerCastingAbility(HLW_Ability AbilityBeingCast);

simulated function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector DamageHitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser);

simulated function OwnerPawnTookDamage(int Damage, Controller InstigatedBy, vector DamageHitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser);

simulated function OwnerChangedWeapon(Weapon PrevWeapon, Weapon NewWeapon);

// This is only being called on the server...
simulated function OwnerPawnDied(Controller InstigatedBy, vector DamageHitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// If this ability was being aimed, stop it
	if (IsInState('Aiming'))
	{
		StopAiming();
	}
	else
	{
		// If this ability was being cast
		if (IsBeingCast())
		{
			ClearTimer('ActivateAbility');
		}

		AbilityComplete(true);
	}

	HideTheDangDecal();
}

simulated function bool CanBeCast()
{
	return AbilityLevel > 0 && !IsOnCooldown() && !IsBeingCast() && !bIsActive && !HLW_Pawn_Class(OwnerPC.Pawn).IsInState('Stunned');
}

simulated function bool IsOnCooldown()
{
	return IsTimerActive('OnCooldownComplete');
}

simulated function float RemainingCooldown()
{
	return GetRemainingTimeForTimer('OnCooldownComplete');
}

simulated function bool IsBeingCast()
{
	return IsTimerActive('ActivateAbility');
}


simulated function HLW_PlayerReplicationInfo GetOwnerPRI()
{
	return HLW_PlayerReplicationInfo(Pawn(Owner).PlayerReplicationInfo);
}

simulated function HideTheDangDecal()
{
	if (AimingDecal != none)
	{
		AimingDecal.SetHidden(true);
		AimingDecal.MatInst.SetScalarParameterValue('CastingTime', 0);
		CastingCounter = 0;
	}
}

DefaultProperties
{
	bHidden=true

	AimType=HLW_AAT_Free

	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=10
		Factor=0.2
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=3.0
		Factor=0.05
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	CooldownTime=CooldownTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=RangeParameter
		BaseValue=0.0
		UpgradeType=HLW_UT_None
	End Object
	Range=RangeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CastTimeParameter
		BaseValue=0.0
		UpgradeType=HLW_UT_None
	End Object
	CastTime=CastTimeParameter
	
	AbilityLevel=0
	
	//TickGroup=TG_DuringAsyncWork
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	NetUpdateFrequency=1

	bPreventsOtherAbilitiesWhileActive=false
	bPreventsPrimaryAttacksWhileActive=false
	bPreventsSecondaryAttacksWhileActive=false
	bPreventsMoveInputWhileActive=false
	bPreventsLookInputWhileActive=false
	bUsableWhenStunned=false
	bInvalidHitLocation=false
	
	DecalImage=Texture2D'HLW_mapProps.guimaterials.SpellSymbol_None'
}
