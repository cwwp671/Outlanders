class HLW_Ability_PiercingShot extends HLW_Ability;

//var(Ability) array<int> BaseDamageTiers;
//var(Ability) array<float> PhysPowPercentageAsDamageTiers;
//var(Ability) array<float> ArrowSpeedTiers;
//var Vector DecalHitLocation, EyeLocation;
//var Rotator EyeRotation;
//var SoundCue ActivationSound;

// CJL Move this whole class over to the new scalar system for posterity

//simulated state Aiming
//{
//	simulated function HandleFixedAiming(int Offset = 200)
//	{
//		local Rotator CurrentEyeRotation;
//		local Vector CurrentEyePosition, HitNormal, TraceEnd, TraceStart;

//		OwnerPC.GetPlayerViewPoint(CurrentEyePosition, CurrentEyeRotation);
//		//EyeRotation = CurrentEyeRotation;
//		//EyeLocation = CurrentEyePosition;
		
//		// Set the pitch to looking straight down, because we don't need that component for this aim type
//		CurrentEyeRotation.Pitch = -16384;

//		AimingDecal.SetLocation( OwnerPC.Pawn.Location + Vector(CurrentEyeRotation) * Offset );
//		AimingDecal.SetRotation( MakeRotator(-16384, OwnerPC.Pawn.Rotation.Roll, OwnerPC.Pawn.Rotation.Yaw) );
		
//		TraceEnd = AimingDecal.Location;
//		TraceEnd.Z -= 1500;
//		TraceStart = AimingDecal.Location;
//		TraceStart.Z += 1500;
		
//		Trace(HitLocation, HitNormal, TraceEnd, TraceStart);
//	}

//}

//simulated function ActivateAbility()
//{
//	super.ActivateAbility();
//	//SetTimer(SafeguardTimer, false, 'OnSafeguardTimer');
//	ConsumeResources();
//	StartCooldown();
//	AbilityComplete();
//	GoToState('ShootStarting');
//}

//simulated state ShootStarting
//{
//	simulated function BeginState(Name PreviousStateName)
//	{
//		super.BeginState(PreviousStateName);	
		
//		//Start Shoot Animation
//		HLW_Pawn_Class(OwnerPC.Pawn).PlayCustomAnim("TPU", 'Archer_Upper_PiercingArrow', 2.2258f);
//		SetTimer(2.2258f, false, 'DoShooting');
//	}	
	
//	simulated function DoShooting()
//	{
//		GoToState('Shooting');	
//	}
	
//	simulated function Tick(float DeltaTime)
//	{
//		super.Tick(DeltaTime);	
//	}
	
//	simulated function EndState(Name NextStateName)
//	{
//		super.EndState(NextStateName);
//		ClearTimer('DoShooting');
//	}
//}

//simulated state Shooting
//{
//	simulated function BeginState(Name PreviousStateName)
//	{
//		local HLW_Projectile_PiercingShot PiercingShot;
//		local Vector AimDir;
		
//		super.BeginState(PreviousStateName);
		
//		if(Role == ROLE_Authority)
//		{
//			OwnerPC.GetPlayerViewPoint(EyeLocation, EyeRotation);
//			PlaySound(ActivationSound,,,, EyeLocation);
//			PiercingShot = Spawn(class'HLW_Projectile_PiercingShot', Self,, EyeLocation);
//			PiercingShot.InstigatorController = OwnerPC;
			
//			if(PiercingShot != None && !PiercingShot.bDeleteMe)
//			{
//				AimDir = Vector(EyeRotation);
//				PiercingShot.Init(AimDir);
//				PiercingShot.Velocity += AimDir * ArrowSpeedTiers[AbilityLevel - 1]; //Added This
//				PiercingShot.Damage = BaseDamageTiers[AbilityLevel - 1] + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamageTiers[AbilityLevel - 1]);
//			}
//		}
		
		
		
//		//Fire Projectile
//		//Disable Projectile Collision
		
//		GoToState('ShootEnding');
//	}	
	
//	simulated function Tick(float DeltaTime)
//	{
//		super.Tick(DeltaTime);	
//	}
	
//	simulated function EndState(Name NextStateName)
//	{
//		super.EndState(NextStateName);	
//	}
//}

//simulated state ShootEnding
//{
//	simulated function BeginState(Name PreviousStateName)
//	{
//		super.BeginState(PreviousStateName);
//		GoToState('Inactive');	
//	}	
	
//	simulated function Tick(float DeltaTime)
//	{
//		super.Tick(DeltaTime);	
//	}
	
//	simulated function EndState(Name NextStateName)
//	{
//		super.EndState(NextStateName);
//	}
//}

defaultproperties
{
	//ActivationSound=SoundCue'HLW_Package_Randolph.Sounds.PiercingShot_Sound'
	
	//AimType=HLW_AAT_Fixed

	//ManaCostTiers(0)=20
	//ManaCostTiers(1)=20
	//ManaCostTiers(2)=20
	//ManaCostTiers(3)=20
	//CooldownTimeTiers(0)=10.0
	//CooldownTimeTiers(1)=10.0
	//CooldownTimeTiers(2)=10.0
	//CooldownTimeTiers(3)=10.0
	//ArrowSpeedTiers(0)=3000
	//ArrowSpeedTiers(1)=3000
	//ArrowSpeedTiers(2)=3000
	//ArrowSpeedTiers(3)=3000
	//CastTimeTiers(0)=0.25
	//CastTimeTiers(1)=0.25
	//CastTimeTiers(2)=0.25
	//CastTimeTiers(3)=0.25
	//BaseDamageTiers(0)=100
	//BaseDamageTiers(1)=100
	//BaseDamageTiers(2)=100
	//BaseDamageTiers(3)=100
	//PhysPowPercentageAsDamageTiers(0)=0.4
	//PhysPowPercentageAsDamageTiers(1)=0.4
	//PhysPowPercentageAsDamageTiers(2)=0.4
	//PhysPowPercentageAsDamageTiers(3)=0.4
}