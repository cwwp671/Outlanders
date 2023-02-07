class HLW_Ability_Volley extends HLW_Ability;

var(Ability) int BaseDamage;
var(Ability) float ArrowSpeed;
var(Ability) float PhysPowPercentageAsDamage;
var(Ability) HLW_UpgradableParameter VolleyHurtRadius;
var(Ability) HLW_UpgradableParameter VolleyDamage;

var ParticleSystem VolleyDownParticle;
var Vector DecalHitLocation, EyeLocation;
var Rotator EyeRotation;
var SoundCue ActivationSound;
var SoundCue ShootSound;
var SoundCue LandSound;

simulated function ActivateAbility()
{
	super.ActivateAbility();
	ConsumeResources();
	StartCooldown();
	AbilityComplete();
	GoToState('ShootStarting');
}

state Aiming
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		AimingDecal.SetRadius(VolleyHurtRadius.CurrentValue);
		
		HLW_Ranged_Bow(HLW_Pawn_Class_Archer(OwnerPC.Pawn).Weapon).GotoState('ResetState');
	}
}

simulated state ShootStarting
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);	
		HLW_Ranged_Bow(HLW_Pawn_Class_Archer(OwnerPC.Pawn).Weapon).GotoState('ResetState');
		//Start Shoot Animation
		//HLW_Pawn_Class(OwnerPC.Pawn).PlayCustomAnim("TPU", 'Archer_Upper_PiercingArrow', 2.2258f, 4.0f);
		HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(UPPERSTATE, _VOLLEY);
		HLW_Pawn_Class(OwnerPC.Pawn).PlayCustomAnim("FP", 'Archer_Hands_Volley', 0.7917f, 1.7f);
		SetTimer(2.2258f/4.0f, false, 'DoShooting');
	}	
	
	simulated function DoShooting()
	{
		GoToState('Shooting');	
	}
	
	simulated function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);	
	}
	
	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		ClearTimer('DoShooting');
	}
}

simulated state Shooting
{
	simulated function BeginState(Name PreviousStateName)
	{
		//local HLW_Projectile_Volley VolleyArrows[32];
		//local Vector AimDir, RandLocation;
		//local int i;
		local HLW_Decal_Cast VolleyTimerDecal;
		local Vector ParticleLocation;
		
		super.BeginState(PreviousStateName);
		
		HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(UPPERSTATE, NORMAL);
		
		if(Role == ROLE_Authority)
		{
			OwnerPC.GetPlayerViewPoint(EyeLocation, EyeRotation);
			
			HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = ActivationSound;
			HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
			
			/*for(i = 0; i < ArrayCount(VolleyArrows); i++)
			{
				RandLocation = EyeLocation;
				RandLocation.X += RandRange(-150, 150);
				RandLocation.Y += RandRange(-150, 150);
				RandLocation.Z += RandRange(-50, 50);

				VolleyArrows[i] = Spawn(class'HLW_Projectile_Volley', Self,,RandLocation);
				VolleyArrows[i].InstigatorController = OwnerPC;
				if(VolleyArrows[i] != None && !VolleyArrows[i].bDeleteMe)
				{
					AimDir = vect(0,0,1);
					VolleyArrows[i].Init(AimDir);
					//VolleyArrows[i].SetOwner(HLW_PlayerController(Owner));
					VolleyArrows[i].Velocity = AimDir * ArrowSpeed; //Added This
					VolleyArrows[i].Damage = BaseDamage + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamage.CurrentValue);
				}
			}*/
			
			PlaySound(ShootSound,,,, OwnerPC.Pawn.Location);
		}
		
		SetTimer(0.25, false, 'DownVolley');
			
		ParticleLocation = HitLocation;
		ParticleLocation.Z += 50;
			
		HLW_Pawn_Class(OwnerPC.Pawn).SpawnEmitter(VolleyDownParticle,
												  ParticleLocation,
												  OwnerPC.Pawn.Rotation,
												  true,
												  1);
												  
		VolleyTimerDecal = Spawn(class'HLW_Decal_Cast', OwnerPC,, HitLocation, Rot(-16384, 0, 0));
		VolleyTimerDecal.SetRadius(VolleyHurtRadius.CurrentValue);
		VolleyTimerDecal.Activate(0.25);
	}	
	
	simulated function DownVolley()
	{
		//local HLW_Projectile_Volley VolleyArrows[50];
		
		HurtRadius(
					VolleyDamage.CurrentValue + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamage),    // Damage
					VolleyHurtRadius.CurrentValue,	            // Radius
					class'HLW_DamageType_Physical',	            // Damage Type
					0,	       				                    // Momentum
					HitLocation,						        // Radius Origin
					OwnerPC.Pawn,	                            // Ignored Actor
					OwnerPC,	                                // Instigator
					true);                                      // Do Full Damage?
		
		/*for(i = 0; i < ArrayCount(VolleyArrows); i++)
		{
			RandLocation = HitLocation;
			RandLocation.X += RandRange(-150, 150);
			RandLocation.Y += RandRange(-150, 150);
			RandLocation.Z += RandRange(-100, 100) + 500;

			VolleyArrows[i] = Spawn(class'HLW_Projectile_Volley', Self,, RandLocation);

			if(VolleyArrows[i] != None && !VolleyArrows[i].bDeleteMe)
			{
				AimDir = vect(0,0, -1);
				VolleyArrows[i].Init(AimDir);
				VolleyArrows[i].InstigatorController = OwnerPC;
				VolleyArrows[i].Velocity = AimDir * ArrowSpeed; //Added This
				VolleyArrows[i].Damage = BaseDamage + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamage.CurrentValue);
			}
		}*/

		if (Role == ROLE_Authority)
		{
			PlaySound(LandSound,,,,HitLocation);
		}
		
		GoToState('ShootEnding');
	}
	
	simulated function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);	
	}
	
	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		
		ClearTimer('DownVolley');
		HLW_Ranged_Bow(HLW_Pawn_Class_Archer(OwnerPC.Pawn).Weapon).GotoState('ResetState');	
	}
}

simulated state ShootEnding
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		GoToState('Inactive');	
	}	
	
	simulated function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);	
	}
	
	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
	}
}

simulated function LevelUp()
{
	super.LevelUp();
	
	VolleyDamage.Upgrade(AbilityLevel);
	VolleyHurtRadius.Upgrade(AbilityLevel);
}

defaultproperties
{
	ActivationSound=SoundCue'HLW_Package_Randolph.Sounds.PiercingShot_Sound'
	ShootSound=SoundCue'HLW_Package_Voices.Archer.Ability_Volley'
	LandSound=SoundCue'HLW_Package_Chris.SFX.Archer_Ability_Volley'
	VolleyDownParticle=ParticleSystem'HLW_Package_Randolph.Farticles.Particle_VolleyDown'
	AimType=HLW_AAT_Free

	ArrowSpeed=1000
	PhysPowPercentageAsDamage=0.1
	
	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=25
		Factor=0.22
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=8.0
		//Factor=0.032
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

	Begin Object Class=HLW_UpgradableParameter Name=HurtRadiusParameter
		BaseValue=250
		Factor=0.075
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	VolleyHurtRadius=HurtRadiusParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=VolleyDamageParameter
		BaseValue=50
		Factor=0.6
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	VolleyDamage=VolleyDamageParameter
	
	DecalImage=Texture2D'HLW_mapProps.guimaterials.SpellSymbol_Volley'
}