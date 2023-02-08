/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Ability_Barrage extends HLW_Ability;

var(Ability) float ConeSpread;
var(Ability) float ConeSpreadMin;
var(Ability) float ConeDecreasePS; //Decrease Per Second
var(Ability) float PhysPowPercentageAsDamage;
var(Ability) HLW_UpgradableParameter NumArrows;
var(Ability) HLW_UpgradableParameter BaseDamage;

var Vector EyeLocation;
var Rotator EyeRotation;
var SoundCue ShootVoice;
var SoundCue ShootSound;
var SoundCue ChargeUpSound;
var bool bCanCloseCone;
var bool bReleased;
var float ArrowSpeed;
var bool bReleasedEarly;
var Name ArrowSocket;
var StaticMeshComponent ArrowDummy[3];
var Vector ArrowLoc;

state Aiming
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		AimingDecal.SetRadius(50);
		
		HLW_Ranged_Bow(HLW_Pawn_Class_Archer(OwnerPC.Pawn).Weapon).GotoState('ResetState');
	}
}

simulated function ActivateAbility()
{
	super.ActivateAbility();
	
	GoToState('BarrageNotch'); //Transition To BarrageNotch State
	ServerStartNotch();
}

reliable server function ServerStartNotch()
{
	GoToState('BarrageNotch');	
}


simulated function StopFire()
{
	ClearTimer('StartConeClose'); //Clear Timer To Close Cone Spread
	GoToState('BarrageRelease'); //Transition To BarrageRelease
	//`log("BARRAGE STOP FIRE");
	ServerStopFire();
}
	
reliable server function ServerStopFire()
{
	//`log("BARRAGE STOP FIRE SERVER");
	ClearTimer('StartConeClose'); //Clear Timer To Close Cone Spread
	GoToState('BarrageRelease'); //Transition To BarrageRelease
}

/*simulated function StopFire()
{
	bReleasedEarly = true;
	ServerStopFire();	
}

reliable server function ServerStopFire()
{
	bReleasedEarly = true;	
}*/

simulated state BarrageNotch
{
	simulated function BeginState(Name PreviousStateName)
	{
		local Vector dArrowLoc; 
		local Rotator dArrowRot; 
		local byte i;
		
		super.BeginState(PreviousStateName);
		
		HLW_Ranged_Bow(HLW_Pawn_Class_Archer(OwnerPC.Pawn).Weapon).GotoState('ResetState');
		
		if(Role < ROLE_Authority)
		{
			//Shoot State Animation
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(UPPERSTATE, _BARRAGE);
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(LOWERSTATE, _BARRAGE);
			HLW_Ranged_Bow(HLW_Pawn_Class_Archer(OwnerPC.Pawn).Weapon).SetStateAnim(_SHOOT);
			
			//Notch Animation
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(UPPERBARRAGE, _NOTCH, 0.0989625f);
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(LOWERBARRAGE, BARRAGEPRE, 0.0989625f);
			HLW_Ranged_Bow(HLW_Pawn_Class_Archer(OwnerPC.Pawn).Weapon).SetShootAnim(_NOTCH, 0.0989625f);
		}
		
		dArrowLoc.X = 4.503214;
		dArrowLoc.Y = -8.916301;
		dArrowLoc.Z = 0;//19.411978;
		
		dArrowRot.Roll = 33.34 * DegToUnrRot;
		dArrowRot.Pitch = -62.27 * DegToUnrRot;
		dArrowRot.Yaw = 122.19 * DegToUnrRot;

		for(i = 0; i < ArrayCount(ArrowDummy); i++)
		{
			ArrowDummy[i].SetTranslation(dArrowLoc);	
			ArrowDummy[i].SetRotation(dArrowRot);
			ArrowDummy[i].SetScale(ArrowDummy[i].Scale * 0.32f);
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).Mesh.AttachComponentToSocket(ArrowDummy[i], HLW_Pawn_Class_Archer(OwnerPC.Pawn).StringSocket);
		}
		
		OwnerPC.Pawn.JumpZ = 0;
		OwnerPC.Pawn.bJumpCapable = False;
		
		//`log("BARRAGE NOTCH BEGIN");
		
		ConeSpread = default.ConeSpread; //Set Initial Cone Spread (Wide)
		bCanCloseCone = default.bCanCloseCone; //Set Bool For Closing Cone
		SetTimer(0.25f, false, 'BeginBarrageHold'); //Set Timer For Hold Transition

		if (Role == ROLE_Authority)
		{
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).BowSound = ChargeUpSound;
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).PlayBowSound(HLW_Pawn_Class_Archer(OwnerPC.Pawn).BowSound);
			//PlaySound(ChargeUpSound,,,,HitLocation);
		}
	}
	
	simulated function BeginBarrageHold()
	{
		GoToState('BarrageHold'); //Transition To BarrageHold State	
	}
	
	simulated function StopFire()
	{
		bReleasedEarly = true;
		ServerStopFire();
	}
	
	reliable server function ServerStopFire()
	{
		bReleasedEarly = true;
	}
	
	simulated function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);
		//`log("BARRAGE NOTCH TICK");	
	}
	
	simulated function EndState(Name NextStateName)
	{
		local Vector dArrowLoc; 
		local Rotator dArrowRot;
		local byte i;
		
		super.EndState(NextStateName);
		
		//`log("BARRAGE NOTCH END");	
		
		ClearTimer('BeginBarrageHold'); //Clear Timer For Hold Transition
		
		dArrowLoc.X = 50;//-52;
		dArrowLoc.Y = 0;
		dArrowLoc.Z = 0;
		
		dArrowRot.Roll = -90 * DegToUnrRot;
		dArrowRot.Pitch = 0;
		dArrowRot.Yaw = 0;
		
		for(i = 0; i < ArrayCount(ArrowDummy); i++)
		{
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).Mesh.DetachComponent(ArrowDummy[i]);
			ArrowDummy[i].SetTranslation(dArrowLoc);
			dArrowRot.Yaw += (30 / 5 * i) * DegToUnrRot;
			ArrowDummy[i].SetRotation(dArrowRot);
			ArrowDummy[i].SetScale(1.0f);
			dArrowRot.Yaw = 0;
			SkeletalMeshComponent(HLW_Ranged_Bow(HLW_Pawn_Class_Archer(OwnerPC.Pawn).Weapon).Mesh).AttachComponentToSocket(ArrowDummy[i], ArrowSocket);
		}
		
		ArrowLoc.X = dArrowLoc.X;
	}
}

simulated state BarrageHold
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		if(bReleasedEarly)
		{
			StopFire();
			return;
		}
		
		if(Role < ROLE_Authority)
		{
			//Draw Animation
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(UPPERBARRAGE, _DRAW);
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(LOWERBARRAGE, BARRAGEIDLE);
			HLW_Ranged_Bow(HLW_Pawn_Class_Archer(OwnerPC.Pawn).Weapon).SetShootAnim(_DRAW);
		}
		
		//`log("BARRAGE HOLD BEGIN");
		
		//Spawn Hold Particle
		SetTimer(1.0f, false, 'StartConeClose'); //Set Timer To Close Cone Spread
	}
	
	simulated function StartConeClose()
	{
		bCanCloseCone = true; //Set Bool For Closing Cone

		if(Role < ROLE_Authority)
		{
			//Hold Animation
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(UPPERBARRAGE, _HOLD);
		}
	}
	
	simulated function Tick(float DeltaTime)
	{
		local byte i;
		
		super.Tick(DeltaTime);
		
		//`log("BARRAGE HOLD TICK");
		
		if(bCanCloseCone)
		{
			if(ConeSpread <= ConeSpreadMin)
			{
				ConeSpread = ConeSpreadMin; //ConeSpread
				bCanCloseCone = false;
			}
			else
			{
				ConeSpread -= ConeDecreasePS * DeltaTime; //Gradually Close Cone Spread (After Timer Fires)
			}	
		}

		ArrowLoc.X = lerp(ArrowLoc.X, 90.0f, 1.0f * DeltaTime);
		ArrowLoc.Y = 0;
		ArrowLoc.Z = 0;
			
		for(i = 0; i < ArrayCount(ArrowDummy); i++)
		{
			ArrowDummy[i].SetTranslation(ArrowLoc);
		}	
	}
	
	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		//`log("BARRAGE HOLD END");
		bReleasedEarly = false;
		ClearTimer('StartConeClose'); //Clear Timer To Close Cone Spread
	}
}

simulated state BarrageRelease
{
	simulated function BeginState(Name PreviousStateName)
	{
		//local array<HLW_Projectile_Arrow> BarrageArrows;
		local HLW_Projectile_Barrage RightArrows[10];
		local HLW_Projectile_Barrage LeftArrows[10];
		local Vector AimDir, SpawnLocation;
		local Rotator SpawnRotation;
		local int i, k;
		
		//`log("BARRAGE RELEASE BEGIN");
		
		super.BeginState(PreviousStateName);
		
		if(Role < ROLE_Authority)
		{
			//Release Animation
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(UPPERBARRAGE, _RELEASE);
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(LOWERBARRAGE, BARRAGEEND);
			
			//Normal State Animation
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(UPPERSTATE, _NORMAL);
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).SetAnimState(LOWERSTATE, _NORMAL);
			HLW_Ranged_Bow(HLW_Pawn_Class_Archer(OwnerPC.Pawn).Weapon).SetStateAnim(_NORMAL);
		}
		
		
		if(Role == ROLE_Authority)
		{
			OwnerPC.GetPlayerViewPoint(EyeLocation, EyeRotation);
			
			//Fire Right Projectiles
			for(i = 0; i < (int(NumArrows.CurrentValue) / 2); i++)
			{
				SpawnLocation = OwnerPC.Pawn.Location;
				SpawnLocation.Z += OwnerPC.Pawn.GetCollisionHeight();
				SpawnRotation = OwnerPC.Pawn.GetBaseAimRotation();

				if(i != 0)
				{
					SpawnRotation.Yaw += (ConeSpread / int(NumArrows.CurrentValue) * i) * DegToUnrRot;
				}

				AimDir = Vector(Normalize(SpawnRotation));
				
				RightArrows[i] = Spawn(class'HLW_Projectile_Barrage', Self,, SpawnLocation);
				RightArrows[i].InstigatorController = OwnerPC;
				
				if(RightArrows[i] != None && !RightArrows[i].bDeleteMe)
				{
					//AimDir = vect(0, 0, 1);
					RightArrows[i].Init(AimDir);
					RightArrows[i].Velocity = AimDir * ArrowSpeed;
					RightArrows[i].Damage = BaseDamage.CurrentValue + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamage);
				}
			}
			
			//Fire Left Projectiles
			for(k = 0; k < int(NumArrows.CurrentValue) / 2; k++)
			{
				SpawnLocation = OwnerPC.Pawn.Location; 
				SpawnLocation.Z += OwnerPC.Pawn.GetCollisionHeight();
				SpawnRotation = OwnerPC.Pawn.GetBaseAimRotation();
				
				if(k != 0)
				{
					SpawnRotation.Yaw += (((-ConeSpread) / int(NumArrows.CurrentValue) * k) * DegToUnrRot);
				}
				
				AimDir = Vector(Normalize(SpawnRotation));
				
				LeftArrows[k] = Spawn(class'HLW_Projectile_Barrage', Self,, SpawnLocation);
				LeftArrows[k].InstigatorController = OwnerPC;
				
				if(LeftArrows[k] != None && !LeftArrows[k].bDeleteMe)
				{
					//AimDir = vect(0, 0, 1);
					LeftArrows[k].Init(AimDir);
					LeftArrows[k].Velocity = AimDir * ArrowSpeed;
					LeftArrows[k].Damage = BaseDamage.CurrentValue + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamage);
				}
			}
			
			HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = ShootVoice;
			HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);

			HLW_Pawn_Class_Archer(OwnerPC.Pawn).BowSound = ShootSound;
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).PlayBowSound(HLW_Pawn_Class_Archer(OwnerPC.Pawn).BowSound);
			//PlaySound(ShootSound,,,,HitLocation);
			
		}
		
		for(i = 0; i < ArrayCount(ArrowDummy); i++)
		{
			HLW_Pawn_Class_Archer(OwnerPC.Pawn).Mesh.DetachComponent(ArrowDummy[i]);
			SkeletalMeshComponent(HLW_Ranged_Bow(HLW_Pawn_Class_Archer(OwnerPC.Pawn).Weapon).Mesh).DetachComponent(ArrowDummy[i]);
		}
		
		
		GoToState('Inactive'); //Transition To Inactive State
	}
	
	simulated function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);	
		//`log("BARRAGE RELEASE TICK");
	}
	
	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
			
		ConsumeResources();
		StartCooldown();
		AbilityComplete();
		//`log("BARRAGE RELEASE END");
		
		OwnerPC.Pawn.JumpZ = OwnerPC.Pawn.default.JumpZ;
		OwnerPC.Pawn.bJumpCapable = True;
		OwnerPC.IgnoreMoveInput(False);
		HLW_Ranged_Bow(HLW_Pawn_Class_Archer(OwnerPC.Pawn).Weapon).GotoState('ResetState');
	}
}

simulated function LevelUp()
{
	super.LevelUp();
	
	BaseDamage.Upgrade(AbilityLevel); //Upgrade Ability Stats
	NumArrows.Upgrade(AbilityLevel);
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	
	if(Role < ROLE_Authority)
	{
		if(bIsActive)
		{
			HLW_HUD_Archer(OwnerPC.myHUD).PowerComponentHUD.CallUpdatePower(((ConeSpread - default.ConeSpreadMin) / (default.ConeSpread - default.ConeSpreadMin)) * 100);
		}
	}
}

defaultproperties
{
	ConeSpread=100
	ConeSpreadMin=5
	ConeDecreasePS=50
	ArrowSpeed=1300
	PhysPowPercentageAsDamage=0.1
	bCanCloseCone=false
	
	AimType=HLW_AAT_Fixed
	
	bPreventsMoveInputWhileActive=true
	bPreventsOtherAbilitiesWhileActive=true
	bPreventsPrimaryAttacksWhileActive=true
	bPreventsSecondaryAttacksWhileActive=true
	
	ShootVoice=SoundCue'HLW_Package_Voices.Archer.Ability_Barrage'
	ChargeUpSound=SoundCue'HLW_Package_Chris.SFX.Archer_Ability_Barrage_Charge'
	ShootSound=SoundCue'HLW_Package_Chris.SFX.Archer_Ability_Barrage_Shoot'
	
	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=80.0
		Factor=0.3
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
	
	Begin Object Class=HLW_UpgradableParameter Name=BarrageDamage
		BaseValue=11.0
		Factor=0.6
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	BaseDamage=BarrageDamage

	Begin Object Class=HLW_UpgradableParameter Name=NumberOfArrowsParameter
		BaseValue=20
		UpgradeType=HLW_UT_None
	End Object
	NumArrows=NumberOfArrowsParameter
	
	//First Person Dummy Arrow Static Mesh (For Animations)
	Begin Object Class=StaticMeshComponent Name=Arrow_StM1
		CastShadow=false
		bCastDynamicShadow=false
		StaticMesh=StaticMesh'HLW_Package_Randolph.models.Barrage_Arrow'//StaticMesh'HLW_Package_Randolph.models.Dat_Arrow'
		//Scale=1.0
		//Rotation=(Yaw=32768,Roll=0,Pitch=0)
	End Object
	ArrowDummy(0)=Arrow_StM1
	
	Begin Object Class=StaticMeshComponent Name=Arrow_StM2
		CastShadow=false
		bCastDynamicShadow=false
		StaticMesh=StaticMesh'HLW_Package_Randolph.models.Barrage_Arrow'
		//Scale=1.0
		//Rotation=(Yaw=32768,Roll=0,Pitch=0)
	End Object
	ArrowDummy(1)=Arrow_StM2
	
	Begin Object Class=StaticMeshComponent Name=Arrow_StM3
		CastShadow=false
		bCastDynamicShadow=false
		StaticMesh=StaticMesh'HLW_Package_Randolph.models.Barrage_Arrow'
		//Scale=1.0
		//Rotation=(Yaw=32768,Roll=0,Pitch=0)
	End Object
	ArrowDummy(2)=Arrow_StM3
	
	//Begin Object Class=StaticMeshComponent Name=Arrow_StM4
		//CastShadow=false
		//bCastDynamicShadow=false
		//StaticMesh=StaticMesh'HLW_Package_Randolph.models.Barrage_Arrow'
		////Scale=1.0
		////Rotation=(Yaw=32768,Roll=0,Pitch=0)
	//End Object
	//ArrowDummy(3)=Arrow_StM4
	//
	//Begin Object Class=StaticMeshComponent Name=Arrow_StM5
		//CastShadow=false
		//bCastDynamicShadow=false
		//StaticMesh=StaticMesh'HLW_Package_Randolph.models.Barrage_Arrow'
		////Scale=1.0
		////Rotation=(Yaw=32768,Roll=0,Pitch=0)
	//End Object
	//ArrowDummy(4)=Arrow_StM5
	
	ArrowSocket=Arrow_Socket
}