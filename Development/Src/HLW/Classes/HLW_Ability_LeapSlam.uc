class HLW_Ability_LeapSlam extends HLW_Ability;

var(Ability) HLW_UpgradableParameter Damage;
var(Ability) HLW_UpgradableParameter Radius;
var(Ability) HLW_AimingDecal LandDecal;
var(Ability) SoundCue VoiceClip;
var(Ability) SoundCue ImpactSound;
var(Ability) SoundCue LeapSound;
var(Ability) ParticleSystem LandParticle;
var(Ability) Vector LeapStartLocation;
var(Ability) Vector LeapEndLocation;
var(Ability) bool bCanLandDecal;
var(Ability) bool bIsLeapSlamming;
var(Ability) float ParabolaTime;
var(Ability) float ParabolaVertex;
var(Ability) float KnockbackStrength;
var(Ability) float LandCounter;
var(Ability) float SafeguardTimer;
var(Ability) float AnimationEndLength;
var(Ability) float PhysPowPercentageAsDamage;

simulated function ActivateAbility()
{
	super.ActivateAbility();
	
	OwnerPC.Pawn.Weapon.GotoState('Active');
	
	if(LandDecal == None)
	{
		LandDecal = Spawn(class'HLW_AimingDecal',,, HitLocation, Rot(-16384, 0, 0));	
		LandDecal.SetRadius(Radius.CurrentValue);
		LandDecal.MatInst.SetScalarParameterValue('AbleToCast', 1);
	}
	
	LandDecal.SetRadius(Radius.CurrentValue);
	LandDecal.MatInst.SetScalarParameterValue('CastingTime', 0.0);
	LandDecal.SetLocation(HitLocation);
	LandDecal.SetHidden(false);
	LandCounter = 0;
	
	SetTimer(SafeguardTimer, false, 'OnSafeguardTimer');
	
	GoToState('LeapStarting');
}

state Aiming
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		AimingDecal.SetRadius(Radius.CurrentValue);
	}
}

simulated function OnSafeguardTimer()
{
	ConsumeResources();
	StartCooldown();
	AbilityComplete();
	bIsLeapSlamming = false;
	LandDecal.SetHidden(true);
	bCanLandDecal = false;
	LandCounter = 0;
	
	if(HLW_Pawn_Class(OwnerPC.Pawn) != None)
	{
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).KillRainbow();
	}
	
	GotoState('Inactive');
}

state LeapStarting
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn) != None)
		{
			if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).UpperStateList.ActiveChildIndex != _LEAPSLAM)
			{
				HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERSTATE, _LEAPSLAM);
			}
	
			if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).LowerStateList.ActiveChildIndex != _LEAPSLAM)
			{
				HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERSTATE, _LEAPSLAM);
			}
	
			HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERLEAPSLAM, _PRELEAPSLAM, 0.0545625);
			HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERLEAPSLAM, _PRELEAPSLAM, 0.0545625);
			
			OwnerPC.Pawn.JumpZ = 0;
			OwnerPC.Pawn.bJumpCapable = False;
			
			LeapStartLocation = OwnerPC.Pawn.Location;
		}
	}
}

state Leaping
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn) != None)
		{
			if (Role == ROLE_Authority)
			{
				HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = VoiceClip;
				HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
				
				PlaySound(LeapSound,,,, OwnerPC.Pawn.Location);
			}
			
			HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERLEAPSLAM, _LEAPSLAMAIR);
			HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERLEAPSLAM, _LEAPSLAMAIR);
			
			Leap();		
			bCanLandDecal = true;
			bIsLeapSlamming = true;
		}
	}
	
}

state LeapEnding
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn) != None)
		{
			HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERLEAPSLAM, _LEAPSLAMEND);
			HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERLEAPSLAM, _LEAPSLAMEND);
			SetTimer(AnimationEndLength, false, 'ResetAnim');
			
			LeapEndLocation = HLW_Pawn_Class_Warrior(OwnerPC.Pawn).Location;
			
			AbilityComplete();
			ConsumeResources();
			StartCooldown();
			ClearTimer('OnSafeguardTimer');
			bIsLeapSlamming = false;
			
			OwnerPC.Pawn.JumpZ = OwnerPC.Pawn.default.JumpZ;
			OwnerPC.Pawn.bJumpCapable = true;
				
			LandDecal.SetHidden(true);
			bCanLandDecal = false;
			LandCounter = 0;
			
			HLW_Pawn_Class_Warrior(OwnerPC.Pawn).KillRainbow();
		}
		
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).KillRainbow();
		GoToState('LeapSlamming');
	}
}

state LeapSlamming
{
	simulated function BeginState(Name PreviousStateName)
	{
		local HLW_Pawn HitPawn;
		local Vector KnockbackMomentum;
		local Rotator RotationTemp;
		
		super.BeginState(PreviousStateName);
		
		foreach VisibleCollidingActors( class'HLW_Pawn', HitPawn, Radius.CurrentValue, HitLocation)
		{
			if(HitPawn != OwnerPC.Pawn && !OwnerPC.Pawn.IsSameTeam(HitPawn))
			{
				KnockbackMomentum = Normal(HitPawn.Location - HitLocation) * (KnockbackStrength * 0.1);
				KnockbackMomentum.Z = KnockbackStrength;
				HitPawn.Velocity = vect(0,0,0);
				
				HitPawn.TakeDamage(Damage.CurrentValue + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamage), OwnerPC, HitLocation, KnockbackMomentum, class'HLW_DamageType_Physical',, self);
			}
		}

		LeapEndLocation.Z -= 60;	

        HLW_Pawn_Class(OwnerPC.Pawn).SpawnEmitter(LandParticle, LeapEndLocation, RotationTemp,, Radius.CurrentValue / 600.0); //Create Particle At LeapEndLocation
         
		if(Role == ROLE_Authority)
		{
			PlaySound(ImpactSound,,,, LeapEndLocation);
		}

		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).KillRainbow();
		GoToState('Inactive'); //Transition To Inactive State
	}
}

//Safely Set Animation States to Normal
simulated function ResetAnim()
{	
	if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).UpperStateList.ActiveChildIndex == _LEAPSLAM)
	{
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERSTATE, _NORMAL, 0.25);
	}
	
	if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).LowerStateList.ActiveChildIndex == _LEAPSLAM)
	{
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERSTATE, _NORMAL, 0.25);
	}
}

function bool Leap()
{
	local Vector Dir, Distance;

	Dir = Vector(Normalize(OwnerPC.Pawn.Rotation));
	
	Distance.X = abs(HitLocation.X - LeapStartLocation.X);
	Distance.Y = abs(HitLocation.Y - LeapStartLocation.Y);
	Distance.Z = abs (ParabolaVertex + (HitLocation.Z - LeapStartLocation.Z));
	
	return PerformLeap(Dir, Distance);
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	
	if(bCanLandDecal)
	{
		LandCounter += DeltaTime;
		LandDecal.MatInst.SetScalarParameterValue('CastingTime', FMin(LandCounter / ParabolaTime, 1.0f));
	}
}

function bool PerformLeap(Vector Dir, Vector Distance)
{
	local Vector InitialVelocity;
	
	//DO MATH COMPUTA
	
	//Vi = d - ½(a * t^2)
	//		---------------
	//			   t
	
	//d = Vi * t + ½(a * t^2)
	
	InitialVelocity.X = ( (Distance.X - (0.5f*(OwnerPC.Pawn.Acceleration.X * (ParabolaTime**2))) ) / (ParabolaTime) );
	InitialVelocity.Y = ( (Distance.Y - (0.5f*(OwnerPC.Pawn.Acceleration.Y * (ParabolaTime**2))) ) / (ParabolaTime) );
	InitialVelocity.Z = ( (Distance.Z - (0.5f*((OwnerPC.Pawn.GetGravityZ() + OwnerPC.Pawn.Acceleration.Z ) * (ParabolaTime**2)))  / (ParabolaTime)  ) );
	
	if(Dir.X < 0)
	{
		OwnerPC.Pawn.Velocity.X = -InitialVelocity.X;
	}
	else
	{
		OwnerPC.Pawn.Velocity.X = InitialVelocity.X;
	}
	if(Dir.Y < 0)
	{
		OwnerPC.Pawn.Velocity.Y = -InitialVelocity.Y;
	}
	else
	{
		OwnerPC.Pawn.Velocity.Y = InitialVelocity.Y;
	}
	
	OwnerPC.Pawn.Velocity.Z = InitialVelocity.Z;
	OwnerPC.Pawn.SetPhysics(PHYS_Falling);

	return true;
}

simulated function LeapStartEnd()
{
	GoToState('Leaping');	
}

simulated function LevelUp()
{
	super.LevelUp();
	
	Damage.Upgrade(AbilityLevel);
	Radius.Upgrade(AbilityLevel);
}

simulated function AbilityComplete(bool bIsPremature = false)
{
	if(bIsPremature == true)
	{
		bIsLeapSlamming = false;
		bCanLandDecal = false;
		LandCounter = 0;
		
		if(LandDecal != None)
		{
			LandDecal.SetHidden(true);
		}
		
		if(IsTimerActive('OnSafeguardTimer'))
		{
			ClearTimer('OnSafeguardTimer');
			StartCooldown();
		}
		
	}
	
	super.AbilityComplete(bIsPremature);		
}

defaultproperties
{
	bIsLeapSlamming=false
	ParabolaTime=2
	ParabolaVertex=500
	PhysPowPercentageAsDamage=0.4
	KnockbackStrength=20000
	AnimationEndLength=0.7083
	SafeguardTimer=5.0f
	
	VoiceClip=SoundCue'HLW_Package_Voices.Warrior.Ability_LeapSlam'
	ImpactSound=SoundCue'HLW_Package_Chris.SFX.Warrior_Ability_LeapSlam_Impact'
	LeapSound=SoundCue'HLW_Package_Chris.SFX.Warrior_Ability_LeapSlam_Leap'
	LandParticle=ParticleSystem'HLW_Package_Randolph.Farticles.Particle_LeapSlam'
	DecalImage=Texture2D'HLW_mapProps.guimaterials.SpellSymbol_LeapSlam'

	bPreventsMoveInputWhileActive=true
	bPreventsOtherAbilitiesWhileActive=true
	bPreventsPrimaryAttacksWhileActive=true
	bPreventsSecondaryAttacksWhileActive=true
	
	AimType=HLW_AAT_Free
	
	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=40.0
		Factor=0.4
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=50.0
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=RangeParameter
		BaseValue=1500.0
		UpgradeType=HLW_UT_None
	End Object
	Range=RangeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CastTimeParameter
		BaseValue=0.25
		UpgradeType=HLW_UT_None
	End Object
	CastTime=CastTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=DamageParameter
		BaseValue=50
		Factor=0.4		
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	Damage=DamageParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=RadiusParameter
		BaseValue=600
		Factor=-20
		UpgradeType=HLW_UT_AddFixedValue
	End Object
	Radius=RadiusParameter
}