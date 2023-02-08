/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Ranged_Bow extends HLW_Ranged_Weapon;

var AnimNodePlayCustomAnim BowAnimation;
var StaticMeshComponent ArrowDummy;
var class<Projectile> ProjectileClass;
var bool bReleased;
var int ArrowPierceLevel;
var float ArrowDamage;
var float ArrowSpeed;
var float ArrowSpread;
var float ArrowSpeedAmount;
var float ArrowDamageAmount;
var float ArrowSpreadAmount;
var float ArrowSpeedInterval;
var float ArrowSpreadInterval;
var float MaxArrowSpeed;
var float MaxArrowDamage;
var float MaxArrowSpread;
var int MaxArrowPierceLevel;
var Name ArrowSocket;
var Vector ArrowLoc;
var SoundCue ReleaseSound;
var() float PhysPowerPercentage;

enum AnimShootList
{
	_NOTCH,
	_DRAW,
	_HOLD,
	_RELEASE
};

enum AnimStateList
{
	_NORMAL,
	_SHOOT
};

var UDKAnimBlendBase StateList;
var UDKAnimBlendBase ShootList;

//var repnotify byte AnimStateIndex;
//var repnotify byte AnimShootIndex;

//StaticMesh'HLW_Package_Randolph.models.Archer_Arrow'
//Arrow_Socket

simulated function PostBeginPlay()
{
	super.PostBeginPlay();	
}

simulated function DetachWeapon()
{
	DetachComponent(Mesh);
}

simulated function Destroyed()
{
	super.Destroyed();
	
	BowAnimation = None;
	StateList = None;
	ShootList = None;	
}

simulated function StartFire(byte FireModeNum)
{
	if(IsInState('Active'))
	{
		GoToState('Notch');	
	}
	
	ServerStartFire(FireModeNum);
}

reliable server function ServerStartFire(byte FireModeNum)
{	
	if(IsInState('Active'))
	{
		GoToState('Notch');	
	}
}

reliable client function SetStateAnim(byte AnimState, float BlendIn = 0.0f)
{
	StateList.SetActiveChild(AnimState, BlendIn);
}

reliable client function SetShootAnim(byte AnimState, float BlendIn = 0.0f)
{
	ShootList.SetActiveChild(AnimState, BlendIn);
}

/**********STATES**********/

//Built In State (Using To Attach First Person Bow Mesh)
simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
		local Vector BowPosition;
		local Rotator BowRotation;
		local MaterialInstanceConstant BowMatInst, ArrowMatInst;
		
		if(HLW_Pawn_Class_Archer(Owner)	!= None)
		{
			//Combine Shadows With First Person Player Model
			Mesh.SetShadowParent(HLW_Pawn_Class_Archer(Owner).Mesh);
		
			BowMatInst = new(None) Class'MaterialInstanceConstant';
			ArrowMatInst = new(None) Class'MaterialInstanceConstant';
		
			BowMatInst.SetParent(Material'HLW_mapProps.Materials.BowMat');
			ArrowMatInst.SetParent(Material'HLW_mapProps.Materials.ArrowMat');
		
			if(HLW_Pawn_Class_Archer(Owner) != None)
			{
				BowMatInst.SetVectorParameterValue('TeamColor', HLW_Pawn_Class_Archer(Owner).CurrentTeamColor); //TODO:Switch back to PawnClass when fixed
				ArrowMatInst.SetVectorParameterValue('TeamColor', HLW_Pawn_Class_Archer(Owner).CurrentTeamColor); //TODO:Switch back to PawnClass when fixed
			}
			
			Mesh.SetMaterial(0, BowMatInst);
			ArrowDummy.SetMaterial(0, ArrowMatInst);
			
			//Material'HLW_mapProps.Materials.BowMat'
			//Adjust Bow Local Rotation
			BowRotation.Roll = 135.70 * DegToUnrRot;
			BowRotation.Pitch = -68.43 * DegToUnrRot;
			BowRotation.Yaw = -140.77 * DegToUnrRot;
			Mesh.SetRotation(BowRotation);
        
			//Adjust Bow Local Position
			BowPosition = Mesh.Translation;
			BowPosition.X = 2.663826;
			BowPosition.Y = 1.846539;
			BowPosition.Z = 0.103650;
			Mesh.SetTranslation(BowPosition);
			
			//Attach Skeletal Meshes To First Person Player
			HLW_Pawn_Class_Archer(Owner).Mesh.AttachComponentToSocket(Mesh, HLW_Pawn_Class_Archer(Owner).BowSocket);
			
			//BowAnimation = AnimNodePlayCustomAnim(SkeletalMeshComponent(Mesh).FindAnimNode('CustomAnim'));
			StateList = UDKAnimBlendBase(SkeletalMeshComponent(Mesh).FindAnimNode('StateList'));
			ShootList = UDKAnimBlendBase(SkeletalMeshComponent(Mesh).FindAnimNode('ShootList'));
		}
		
		super.BeginState(PreviousStateName);
	}
}

//State For Notching Arrow From Quiver
simulated state Notch
{
	simulated function BeginState(Name PreviousStateName)
	{
		local Vector dArrowLoc; 
		local Rotator dArrowRot; 
		
		//Play Archer Notch Arrow Animation
		HLW_Pawn_Class_Archer(Owner).ArcherNotchArrow();
		
		if(Role < ROLE_Authority)
		{
			SetStateAnim(_SHOOT);
			SetShootAnim(_NOTCH, 0.0989625f);
		}
		
		dArrowLoc.X = 4.503214;
		dArrowLoc.Y = -8.916301;
		dArrowLoc.Z = 19.411978;
		ArrowDummy.SetTranslation(dArrowLoc);

		dArrowRot.Roll = 33.34 * DegToUnrRot;
		dArrowRot.Pitch = -62.27 * DegToUnrRot;
		dArrowRot.Yaw = 122.19 * DegToUnrRot;
		ArrowDummy.SetRotation(dArrowRot);
		
		ArrowDummy.SetScale(ArrowDummy.Scale * 0.32f);
		
		//Attach Arrow To Archer's First Person Right Hand Socket
		HLW_Pawn_Class_Archer(Owner).Mesh.AttachComponentToSocket(ArrowDummy, HLW_Pawn_Class_Archer(Owner).StringSocket);
	}
	
	simulated function StopFire(byte FireModeNum)
	{
		//`log("Client Notch");
		//Released During Notch
		bReleased = true;

		//Make Sure Server Stops Firing
		ServerStopFire(FireModeNum);
	}
	
	reliable server function ServerStopFire(byte FireModeNum)
	{	
		//`log("Server Notch");
		//Released During Notch
		bReleased = true;
	}
	
	simulated function EndState(Name NextStateName)
	{
		local Vector dArrowLoc; 
		local Rotator dArrowRot;
		
		HLW_Pawn_Class_Archer(Owner).Mesh.DetachComponent(ArrowDummy);

		//Rest = -52
		//Notch = -36
		//Draw = 34
		dArrowLoc.X = -52;
		dArrowLoc.Y = 0;
		dArrowLoc.Z = 0;
		ArrowDummy.SetTranslation(dArrowLoc);

		dArrowRot.Roll = -90 * DegToUnrRot;
		dArrowRot.Pitch = 0;
		dArrowRot.Yaw = 0;
		ArrowDummy.SetRotation(dArrowRot);
		
		ArrowDummy.SetScale(1.0f);
		
		ArrowLoc.X = dArrowLoc.X;
		
		//Attach Arrow To Archer's First Person Right Hand Socket
		
		SkeletalMeshComponent(Mesh).AttachComponentToSocket(ArrowDummy, ArrowSocket);
	}
}

//State For Drawing The Notched Arrow
simulated state Draw
{
	simulated function BeginState(Name PreviousStateName)
	{	
		//Play Archer Draw Arrow Animation
		HLW_Pawn_Class_Archer(Owner).ArcherDrawArrow();
		//ShootList.SetActiveChild(_DRAW, 0.0f);
		if(Role < ROLE_Authority)
		{
			SetShootAnim(_DRAW);
		}
	}
	
	simulated function Tick(float DeltaTime)
	{
		ArrowLoc.X = lerp(ArrowLoc.X, 52.0f, (1.75f * 1.5) * DeltaTime);
		ArrowLoc.Y = 0;
		ArrowLoc.Z = 0;
		ArrowDummy.SetTranslation(ArrowLoc);
		
		super.Tick(DeltaTime);
	}
	
	simulated function StopFire(byte FireModeNum)
	{
		//`log("Client Early");
		//Released During Draw
		bReleased = true;
		
		//Make Sure Server Stops Firing
		ServerStopFire(FireModeNum);
	}
	
	reliable server function ServerStopFire(byte FireModeNum)
	{
		//`log("Server Early");
		//Released During Draw
		bReleased = true;
	}
	
	simulated function EndState(Name NextStateName)
	{
	}
}

//State For Holding The Drawn Arrow
simulated state Hold
{
	simulated function BeginState(Name PreviousStateName)
	{
		//Play Archer Hold Animation (Loops)
		HLW_Pawn_Class_Archer(Owner).ArcherDrawIdle();
		
		//Enables Spread Increase
		SetTimer(2.0, false, 'EnableSpread');

		//Enables piercing arrow
		SetTimer(2.0, true, 'EnablePiercingArrow');

		//Increase Speed Interval
		SetTimer(ArrowSpeedInterval, true, 'IncreaseSpeed');
	}
	
	simulated function EnableSpread()
	{
		//Increase Spread Interval						   
		SetTimer(ArrowSpreadInterval, true, 'IncreaseSpread');							   
	}	
	
	simulated function EnablePiercingArrow()
	{
		if(ArrowPierceLevel >= MaxArrowPierceLevel)
		{
			ClearTimer('EnablePiercingArrow');
			ArrowPierceLevel = MaxArrowPierceLevel;	
		}
		else
		{
			ArrowPierceLevel ++;
		}						   
	}														   
	
	//Calculate Speed Increase
	simulated function IncreaseSpeed() // DAMAGE INCREASE
	{
		if(ArrowDamage >= MaxArrowDamage)
		{
			ClearTimer('IncreaseSpeed');
			ArrowDamage = MaxArrowDamage;	
		}
		else
		{
			ArrowDamage += ArrowDamageAmount;
		}
	}
	
	//Calculate Spread Increase													   
	simulated function IncreaseSpread()									   
	{														   
		if(ArrowSpread >= MaxArrowSpread)
		{
			ClearTimer('IncreaseSpread');
			ArrowSpread = MaxArrowSpread;	
		}
		else
		{
			ArrowSpread += ArrowSpreadAmount;
		}							   
	}												   
																   
	simulated function StopFire(byte FireModeNum)				   
	{				
		//`log("Client Hold");
		//Will Call Hold's EndState and Release's BeginState										   
		GoToState('Release');
		
		//Make Sure Server Stops Firing
		ServerStopFire(FireModeNum);								   
	}
	
	reliable server function ServerStopFire(byte FireModeNum)
	{
		//`log("Server Hold");
		//Will Call Hold's EndState and Release's BeginState
		GoToState('Release');
	}														   
																   
	simulated function EndState(Name NextStateName)				   
	{											
		//Clear Timers								   
		ClearTimer('EnableSpread'); 
		ClearTimer('IncreaseSpread');
		ClearTimer('IncreaseSpeed');	
		ClearTimer('EnablePiercingArrow');											   
	}																		   
}																			   
		
//State For Firing The Arrow																	   
simulated state Release														   
{																			   
	simulated function BeginState(Name PreviousStateName)					   
	{														   																			   
		//Detach Dummy Arrow From First Person Archer
		//HLW_Pawn_Class_Archer(Owner).Mesh.DetachComponent(ArrowDummy); 
		SkeletalMeshComponent(Mesh).DetachComponent(ArrowDummy);
		ArrowLoc.X = 0;
		
		//Fire Arrow
		ProjectileFire();
		
		PlaySound(ReleaseSound,,,,Owner.Location);
		
		//Transition Back To Active State
		GoToState('Active');
	}
	
	simulated function EndState(Name NextStateName)
	{
		//Reset Early Shoot bool
		bReleased = false;
		
		//Reset Spread, Speed, and Damage
		ArrowSpread = default.ArrowSpread;
		ArrowSpeed = default.ArrowSpeed;
		ArrowDamage = default.ArrowDamage;
		ArrowPierceLevel = default.ArrowPierceLevel; 
			
		//Currently Stops Custom Animations
		//TO DO: Implement Return To Idle Animations
		HLW_Pawn_Class_Archer(Owner).ArcherReleaseArrow();

		if(Role < ROLE_Authority)
		{
			SetStateAnim(_NORMAL, 0.05f);
		}
		
		GoToState('Active');
	}
}

simulated state ResetState
{
	simulated function BeginState(Name PreviousStateName)
	{
		ClearTimer('EnableSpread'); 
		ClearTimer('IncreaseSpread');
		ClearTimer('IncreaseSpeed');	
		ClearTimer('EnablePiercingArrow');	
		
		//Reset Early Shoot bool
		bReleased = false;
		
		//Reset Spread, Speed, and Damage
		ArrowSpread = default.ArrowSpread;
		ArrowSpeed = default.ArrowSpeed;
		ArrowDamage = default.ArrowDamage;
		ArrowPierceLevel = default.ArrowPierceLevel;
		
		HLW_Pawn_Class_Archer(Owner).Mesh.DetachComponent(ArrowDummy);
		SkeletalMeshComponent(Mesh).DetachComponent(ArrowDummy);
		
		ArrowLoc.X = 0;
		
		GoToState('Active');
	}
}

//Spawns Projectile (Built In)
simulated function Projectile ProjectileFire()
{
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
	local Projectile	SpawnedProjectile;

	if(Role == ROLE_Authority)
	{
		// This is where we would start an instant trace. (what CalcWeaponFire uses)
		StartTrace = Instigator.GetWeaponStartTraceLocation();
		AimDir = Vector(GetAdjustedAim( StartTrace ));

		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc(AimDir);

		if( StartTrace != RealStartLoc )
		{
			// if projectile is spawned at different location of crosshair,
			// then simulate an instant trace where crosshair is aiming at, Get hit info.
			EndTrace = StartTrace + AimDir * GetTraceRange();
			TestImpact = CalcWeaponFire( StartTrace, EndTrace );

			// Then we realign projectile aim direction to match where the crosshair did hit.
			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
		}

		// Spawn projectile
		SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc);

		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( AimDir );
			SpawnedProjectile.Velocity += AimDir * ArrowSpeed; //Added This
			SpawnedProjectile.Damage = ArrowDamage + (HLW_Pawn_Class(Owner).GetPRI().PhysicalPower * PhysPowerPercentage); // + (0.002 * ArrowSpeed); //Added This (Should use the classes base Physical POWER)
			HLW_Projectile_Arrow(SpawnedProjectile).hitCount = ArrowPierceLevel; 
		}

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	
	if(Owner != None)
	{
		if(Role < ROLE_Authority)
		{
			if(HLW_Pawn_Class_Archer(Owner).GetPRI() != none && HLW_Pawn_Class_Archer(Owner).GetPRI().Abilities[4] != None && HLW_Pawn_Class_Archer(Owner).Controller != none)
			{
				if(!HLW_PlayerController(HLW_Pawn_Class_Archer(Owner).Controller).GetAbility(4).bIsActive)
				{
					HLW_HUD_Archer(HLW_PlayerController(HLW_Pawn_Class_Archer(Owner).Controller).myHUD).PowerComponentHUD.CallUpdatePower((ArrowDamage / MaxArrowDamage) * 100);
				}
			}
		}
	}
	
	//`log(ArrowDummy.Scale);
	
	//`log(ArrowDamage);	
}

//Gets Projectile Type (Overwrote Built In Function)
simulated function class<Projectile> GetProjectileClass()
{
	return ProjectileClass;
}

//Adds Spread To Projectile (Overwrote Built In Function)
simulated function rotator AddSpread(rotator BaseAim)
{
	local vector X, Y, Z;
	local float CurrentSpread, RandY, RandZ;
	
	CurrentSpread = ArrowSpread; //Changed This
	
	if (CurrentSpread == 0)
	{
		return BaseAim;
	}
	else
	{
		// Add in any spread.
		GetAxes(BaseAim, X, Y, Z);
		RandY = FRand() - 0.5;
		RandZ = Sqrt(0.5 - Square(RandY)) * (FRand() - 0.5);
		return rotator(X + RandY * CurrentSpread * Y + RandZ * CurrentSpread * Z);
	}
}

//Gets Projectile Spawn Location (Built In)
simulated function vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	return super.GetPhysicalFireStartLoc(AimDir); //Comment This Out If You Want To Get Your Own Projectile Spawn Location
}

/**********Animation Script Notifies**********/

//Call At End Of Notch Animation
simulated function SetNotchEnd()
{
	//`log("who?");
	GoToState('Draw'); //Will Call Notch's EndState and Draw's BeginState
}

//Call At End Of Draw Animation
simulated function SetDrawEnd()
{
	//`log("Draw End:" @Role);
	//`log("DRAW ENDING:"@bReleased);
	
	if(!bReleased)
	{
		GoToState('Hold'); //Will Call Draw's EndState and Hold's BeginState
	}
	else
	{
		GoToState('Release'); //Will Call Draw's EndState and Release's BeginState
	}
}

////Call At End Of Release Animation
//simulated function SetReleaseEnd()
//{
	//`log("SetReleaseEnd"); 
	//GoToState('Active'); //Will Call Release's EndState and Active's BeginState
//}

defaultproperties
{
	bReleased = false
	
	PhysPowerPercentage=0.3
	
	//Defaults
	ArrowSpeed=5000
	ArrowDamage=30
	ArrowSpread=0
	
	//PiercingArrow
	ArrowPierceLevel=1
	MaxArrowPierceLevel=4
	
	//Amount Per Increase
	ArrowDamageAmount=5
	ArrowSpreadAmount=0.02
	
	//Time Per Increase
	ArrowSpeedInterval=0.1 
	ArrowSpreadInterval=1.0
	
	//Maximums
	MaxArrowDamage=60
	MaxArrowSpeed=5000
	MaxArrowSpread=0.1
	
	MyDamageType=class'HLW_DamageType_Physical' //Damage Type (Gets Rid Of Warnings + Needed For Future Damage Resistances)
	AttachmentClass=class'HLW_Bow_Attachment' //Third Person Bow
	ProjectileClass=class'HLW.HLW_Projectile_Arrow' //Type Of Projectile
	
	//First Person Bow Skeletal Mesh
	Begin Object Class=SkeletalMeshComponent Name=Bow_SM
		bAcceptsDynamicDecals=TRUE //Future Blood Decals?
		bAllowAmbientOcclusion=FALSE //No Ambient Occulsion Please (I Don't Think This Works)
		AlwaysLoadOnClient=TRUE //IDK
		AlwaysLoadOnServer=TRUE //IDK
		BlockRigidBody=FALSE //No Collision Please
		bCacheAnimSequenceNodes=FALSE //IDK
		bCastDynamicShadow=TRUE //Dynamic Shadow
		CastShadow=TRUE //Shadow
		bChartDistanceFactor=TRUE //IDK
		bOnlyOwnerSee=TRUE //Only Visible To Player
		bOverrideAttachmentOwnerVisibility=TRUE //Anything Attached Gets My Visibility Setting
		bPerBoneMotionBlur=TRUE //IDK
		bUseOnePassLightingOnTranslucency=TRUE //IDK
		bUpdateKinematicBonesFromAnimation=TRUE //IDK
		bUpdateSkelWhenNotRendered=TRUE //Needed For Accurate Tracer Positions When Invisible
		RBChannel=RBCC_Untitled3 //IDK
		RBCollideWithChannels=(Untitled3=TRUE) //IDK
		RBDominanceGroup=20 //IDK
		MinDistFactorForKinematicUpdate=0.2f //IDK
		TickGroup=TG_PreAsyncWork //Ticks Before Asynchronous Updates (Physics + Others Things)
		Scale=0.32
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Dat_Bow'
		AnimTreeTemplate=AnimTree'HLW_Package_Randolph.Animations.Bow_AnimTree'
		AnimSets(0)=AnimSet'HLW_Package_Randolph.Animations.Bow_AnimSet'
		//PhysicsAsset=//something
	End Object
	Mesh=Bow_SM
	Components.Add(Bow_SM)
	
	//First Person Dummy Arrow Static Mesh (For Animations)
	Begin Object Class=StaticMeshComponent Name=Arrow_StM
		CastShadow=false
		bCastDynamicShadow=false
		StaticMesh=StaticMesh'HLW_Package_Randolph.models.Dat_Arrow'
        bAcceptsDynamicDecals=true
		//Scale=1.0
		//Rotation=(Yaw=32768,Roll=0,Pitch=0)
	End Object
	ArrowDummy=Arrow_StM
	
	ArrowSocket=Arrow_Socket
	
	ReleaseSound=SoundCue'HLW_Package_Chris.SFX.Archer_BowRelease'
}