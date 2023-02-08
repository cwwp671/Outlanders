/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Pawn_Class extends HLW_Pawn;

var bool bInitiliazedHUD;
var class<HLW_Ability> AbilityClasses[5];

var(Stats) float MoveSprintPercentage;
var(Stats) float MoveBackwardPercentage;
var(Stats) float MoveStrafePercentage;
var(Stats) float BaseMovementSpeed;
var(Stats) float BaseAttackSpeed;
var(Stats) float BasePhysicalPower;
var(Stats) float BaseMagicalPower;
var(Stats) float BasePhysicalDefense;
var(Stats) float BaseMagicalDefense;
var(Stats) float BaseCooldownReduction;
var(Stats) float BaseResistance;
var(Stats) float BaseHP5;
var(Stats) float BaseMP5;
var(Stats) int BaseMana;
var(Stats) int BaseManaMax;
var(Stats) int BaseHealth;
var(Stats) int BaseHealthMax;
var(Stats) float ManaIncreaseOnLevelPercentage;
var(Stats) float HealthIncreaseOnLevelPercentage;
var(Stats) float PhysicalPowerIncreaseOnLevelPercentage;
var(Stats) float MagicalPowerIncreaseOnLevelPercentage;
var(Stats) float HP5IncreaseOnLevelPercentage;
var(Stats) float MP5IncreaseOnLevelPercentage;
var(Voice) SoundCue VoiceCueDied;
var(Voice) SoundCue VoiceCueLevelUp;
var(Voice) SoundCue VoiceCueIdle;
var(Voice) SoundCue VoiceCueHurt;
var(Voice) SoundCue VoiceCueKill;

var Vector DeathMomentum;

var int AmbientExpPerTick;
var bool bIsStrafing;
var bool bIsMovingBackwards;

var int BaseUpgradePoints;

var AudioComponent VoiceComponent;

var repnotify SoundCue VoiceOver;

var int creepToSpawn;
var int creepLevel;
var HLW_Factory_Creep Factory;
var bool bSpawnCooldown;

var bool bCanHurtVO;

var bool inPathBlockingVolume;

var bool pauseCreeps;

var byte Incrementer;
var byte eIncrementer;

var AnimNodeBlend AnimNodeBlend;
var AnimNodeBlend AnimNodeBlendTP;
var AnimNodeAimOffset AimNodeTP;

var MaterialInstanceConstant MatInst;
var repnotify LinearColor CurrentTeamColor;
var repnotify float Opacity; 

var Name CachedPreviousState;

var Controller LastPlayerToHitMe;

struct ReplicatedAim
{
    var float X;
    var float Y;    
};

enum AnimNodes
{
	UPPERSTATE,
	LOWERSTATE
};

var SkeletalMeshComponent ThirdPerson;

//Animation Replication Struct
struct ReplicatedAnimation
{
    var bool Toggle;
    var Name AnimName;
    var float Rate;
    var float BlendInTime;
    var float BlendOutTime;
    var bool bLoop;
    var bool bOverride;
    var float StartTime;
    var byte BerryImportant; //Incrementing Variable Because If Nothing Changes In The Struct It Won't Be Replicated
	var AnimNodePlayCustomAnim CustomNode;
};

struct ReplicatedEmitter
{
    var ParticleSystem ParticleSystemName;
    var Vector SpawnLocation;
    var Rotator SpawnRotation;
    var float Scale;
    var bool DistroyOnFinish;
    var byte BerryImportant;
};

//Local Current Attachment
var HLW_WeaponAttachment CurrentWeaponAttachment;

var AnimNodePlayCustomAnim CustomAnim;
var AnimNodePlayCustomAnim CustomAnimTP_Upper;
var AnimNodePlayCustomAnim CustomAnimTP_Lower;

var UDKAnimBlendBase StateList;
var UDKAnimBlendBase UpperStateList;
var UDKAnimBlendBase LowerStateList;

var repnotify byte UpperStateIndex;
var repnotify byte LowerStateIndex;

var repnotify ReplicatedAnimation RepAnim;
var repnotify ReplicatedEmitter RepEmit;
var repnotify ReplicatedAnimation RepAnimTP_Upper;
var repnotify ReplicatedAnimation RepAnimTP_Lower;
var repnotify ReplicatedAnimation RepAnimDynamic;

var repnotify ReplicatedAim RepAim;

//Replicated Class of Current Attachment
var repnotify class<HLW_WeaponAttachment> CurrentWeaponAttachmentClass;

//var repnotify byte CanRagdoll;
var repnotify bool SwitchToCast;

var bool bDrawNamePlate; 

var bool bHasDied;

var DroppedPickup DroppedWeapon;
var SkeletalMeshComponent DroppedWeaponMesh;
var class<DroppedPickup> DroppedWeaponClass;

var	eDoubleClickDir CurrentDir;
var float DodgeSpeed;
var float DodgeSpeedZ;
var bool bDodging;

var LinearColor BlueTeamColor;//WOULD REALLY LIKE TO MOVE THESE TO A GLOBAL PLACE
var LinearColor YellowTeamColor;
var LinearColor FFATeamColor;

enum AudioType
{
	AT_Hurt, AT_Died, AT_LevelUp, AT_Idle
};

replication 
{
    if(bNetDirty)
        Factory, creepToSpawn, creepLevel, Opacity,CurrentTeamColor,
		RepAnim, RepEmit, RepAim, RepAnimTP_Upper, RepAnimTP_Lower, RepAnimDynamic, CurrentWeaponAttachmentClass, SwitchToCast, VoiceOver;
		
	if(bNetDirty && !bNetOwner)
		UpperStateIndex, LowerStateIndex;
}

//****************************
//****************************
//****************************

simulated event PostBeginPlay()
{   
    super.PostBeginPlay();
	
    Health = BaseHealth;
    HealthMax = BaseHealthMax;

    SetTimer(10.f, true, NameOf(PayIncome));
	
	SetTimer(10.f, true, NameOf(AmbientExp));
}

reliable server function ServerInitializeStats()
{
	local HLW_PlayerReplicationInfo HLW_PRI;
	HLW_PRI = GetPRI();
    HLW_PRI.SetMovementSpeed(BaseMovementSpeed);
    HLW_PRI.SetAttackSpeed(BaseAttackSpeed);
    HLW_PRI.SetPhysicalPower(BasePhysicalPower);
    HLW_PRI.SetMagicalPower(BaseMagicalPower);
    HLW_PRI.SetPhysicalDefense(BasePhysicalDefense);
    HLW_PRI.SetMagicalDefense(BaseMagicalDefense);
    HLW_PRI.SetCooldownReduction(BaseCooldownReduction);
    HLW_PRI.SetResistance(BaseResistance);
    HLW_PRI.SetHP5(BaseHP5);
    HLW_PRI.SetMP5(BaseMP5);
    HLW_PRI.SetManaMax(BaseManaMax);
    HLW_PRI.SetMana(BaseMana);
	HLW_PRI.SetHealthMax(BaseHealthMax);
	HLW_PRI.SetUpgradePoints(BaseUpgradePoints);
	Health = HealthMax;
}

simulated event Tick(float DeltaTime)
{
	local HLW_Factory_Creep tempFactory;
	
    super.Tick(DeltaTime);

    if (Role == ROLE_Authority && GetPRI() != none && !GetPRI().bStatsSet)
    {
        ServerInitializeStats();
		GetPRI().bStatsSet = true;
    }
	
	if(!bInitiliazedHUD && Controller != None && HLW_PlayerController(Controller).myHUD != None && GetPRI() != none && GetPRI().bStatsSet && GetPRI().Abilities[0] != None)
	{
		bInitiliazedHUD = true;
		PlayerInitialized();
	}
	
	if(Factory == none && Controller != none)
	{
		foreach DynamicActors(class'HLW_Factory_Creep', tempFactory)
		{
			if(self.Controller.PlayerReplicationInfo.Team.TeamIndex == tempFactory.teamIndex)
			{
				Factory = tempFactory;
				//`log("Added factory" @ tempFactory);
			}
		}
	}
	else if (Controller == none)
	{
		Factory = none;
	}
}

simulated function PlayerInitialized()
{
    HealthMax = GetPRI().HLW_HealthMax;
    Health = HealthMax;
	ExpReward = ((BaseExpReward * GetPRI().Level) + ((BaseExpReward * GetPRI().Level) / GetPRI().Level)) / 2;
	GetPRI().SetMana(GetPRI().ManaMax);
	GetPRI().SetIndicator();
	ResetHealth();
	if(Role < ROLE_Authority)
	{
		if(HLW_PlayerController(Controller).CameraStyle != '' && HLW_Camera(HLW_PlayerController(Controller).PlayerCamera).CameraStyle != HLW_PlayerController(Controller).CameraStyle)
		{
			HLW_PlayerController(Controller).SwitchCam();
		}
	}
	
}

reliable server function ResetHealth()
{
    HealthMax = GetPRI().HLW_HealthMax;
    Health = HealthMax;
	ExpReward = ((BaseExpReward * GetPRI().Level) + ((BaseExpReward * GetPRI().Level) / GetPRI().Level)) / 2;
	GetPRI().SetMana(GetPRI().ManaMax);
	//GetPRI().SetIndicator();
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree( SkelComp);
    
    if(SkelComp == Mesh)
    {
        AnimNodeBlend = AnimNodeBlend(SkelComp.FindAnimNode('CastingSwitch'));
    }
    
    if(SkelComp == ThirdPerson)
    {
		AimNodeTP = AnimNodeAimOffset(SkelComp.FindAnimNode('AimNodeTP'));	
		AnimNodeBlendTP = AnimNodeBlend(SkelComp.FindAnimNode('CastingSwitch'));
    }
}

simulated function SetAnimState(byte AnimNode, byte AnimState, float BlendIn = 0.0f)
{
	switch(AnimNode)
	{
		case UPPERSTATE:
			UpperStateList.SetActiveChild(AnimState, BlendIn);
			StateList.SetActiveChild(AnimState, BlendIn);
			break;
		case LOWERSTATE:
			LowerStateList.SetActiveChild(AnimState, BlendIn);
			break;
	}
	
	if(Role < ROLE_Authority)
	{
		ServerSetAnimState(AnimNode, AnimState);
	}
}

//Put In Individual Pawn Classes and Use Their Custom States Too
reliable server function ServerSetAnimState(byte AnimNode, byte AnimState)
{
	switch(AnimNode)
	{
		case UPPERSTATE:
			UpperStateIndex = AnimState;
			return;
		case LOWERSTATE:
			LowerStateIndex = AnimState;
			return;	
	}
}

//Put In Individual Pawn Classes and Use Their Custom States Too
reliable client function ClientSetAnimState(byte AnimNode, byte AnimState)
{
	switch(AnimNode)
	{
		case UPPERSTATE:
			UpperStateList.SetActiveChild(AnimState, 0.0f);
			StateList.SetActiveChild(AnimState, 0.0f);
			return;
		case LOWERSTATE:
			LowerStateList.SetActiveChild(AnimState, 0.0f);
			return;
	}
}

reliable server function ResetAnimState()
{
	UpperStateIndex = 0;
	LowerStateIndex = 0;	
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'CurrentTeamColor')
    {
    	ClientSetTeamColor(CurrentTeamColor);
    	return;
    }
	if ( VarName == 'Opacity')
    {
        ClientSetOpacity(Opacity);
        return;
    }
    if ( VarName == 'RepAnim')
    {
        ClientPlayAnim(RepAnim);
        return;
    }
    if ( VarName == 'RepAnimTP_Upper')
    {
        ClientPlayAnimTP_Upper('CustomAnimTP_Upper', RepAnimTP_Upper.AnimName, RepAnimTP_Upper.Rate, RepAnimTP_Upper.BlendInTime, RepAnimTP_Upper.BlendOutTime, RepAnimTP_Upper.bLoop, RepAnimTP_Upper.bOverride, RepAnimTP_Upper.StartTime);
        return;
    }
    if ( VarName == 'RepAnimTP_Lower')
    {
        ClientPlayAnimTP_Lower('CustomAnimTP_Lower', RepAnimTP_Lower.AnimName, RepAnimTP_Lower.Rate, RepAnimTP_Lower.BlendInTime, RepAnimTP_Lower.BlendOutTime, RepAnimTP_Lower.bLoop, RepAnimTP_Lower.bOverride, RepAnimTP_Lower.StartTime);
        return;
    }
    else if( VarName == 'RepEmit')
    {
        ClientSpawnEmitter(RepEmit);
        return;
    }
    else if ( VarName == 'RepAim')
    {
        ClientFaceRotation(RepAim);
        return;
    }
    else if (VarName == 'RepAnimDynamic')
    {
		ClientPlayAnimDynamic(RepAnimDynamic.CustomNode, RepAnimDynamic.AnimName, RepAnimDynamic.Rate, RepAnimDynamic.BlendInTime, RepAnimDynamic.BlendOutTime, RepAnimDynamic.bLoop, RepAnimDynamic.bOverride, RepAnimDynamic.StartTime);
		return;
    }
    else if ( VarName == 'CurrentWeaponAttachmentClass' )
    {
        WeaponAttachmentChanged();
        return;
    }
    else if(VarName == 'CanRagdoll')
    {
        ClientCauseRagdoll();
        return;
    }
	else if(VarName =='SwitchToCast')
	{
		if(HLW_Pawn_Class_Warrior(self) == NONE)
		{
			if(SwitchToCast)
			{
				ClientAnimNodeBlend(AnimNodeBlendTP, 1.0f, 0.35f);
			}
			else
			{
				ClientAnimNodeBlend(AnimNodeBlendTP, 0.0f, 0.35f);
			}
		}
		return;	
	}
	else if(VarName == 'UpperStateIndex')
	{

	}
	else if(VarName == 'LowerStateIndex')
	{
	
	}
	else if(VarName == 'VoiceOver')
	{
		PlayVoiceOver(VoiceOver);
		
		return;
	}
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}

reliable client function ClientSetOpacity(float NewOpacity)
{
	
}

reliable client function ClientSetTeamColor(LinearColor NewTeamColor)
{
	
}

reliable server function DrawNamePlate(bool ShouldDraw)//TODO: If someone can get this working that'd be cool
{
	bDrawNamePlate = ShouldDraw;
}

simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
    super.FaceRotation(NewRotation, DeltaTime);
    RepAim.X = AimNode.Aim.X;
    RepAim.Y = AimNode.Aim.Y;   
}

unreliable client function ClientFaceRotation(ReplicatedAim Aim)
{
    AimNodeTP.Aim.X = Aim.X;
    AimNodeTP.Aim.Y = Aim.Y;
}

simulated event Destroyed()
{
    Super.Destroyed();
  
    AnimNodeBlend = None;
	AnimNodeBlendTP = None;
    AimNodeTP = None;
    CustomAnim = None;
	CustomAnimTP_Upper = None;
	CustomAnimTP_Lower = None;
	StateList = None;
	UpperStateList = None;
	LowerStateList = None;
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	bHasDied = true;
	
	if(LastPlayerToHitMe != none)
	{
		HLW_PlayerController(Controller).SendTextToServer(PlayerReplicationInfo.PlayerName @"was killed By" @LastPlayerToHitMe.PlayerReplicationInfo.PlayerName, , true);
		HLW_PlayerController(Controller).bSuicided = false;
	}
	else
	{
		HLW_PlayerController(Controller).SendTextToServer(PlayerReplicationInfo.PlayerName @"has died.", , true);
		HLW_PlayerController(Controller).bSuicided = true;
	}
	
    return Super.Died(LastPlayerToHitMe, DamageType, HitLocation);
}

simulated function KilledPawnWith(HLW_Pawn Killed, Actor KilledWith, Vector KillLocation)
{
	super.KilledPawnWith(Killed, KilledWith, KillLocation);
}

simulated function AddDefaultInventory()
{
	if(playerReplicationInfo != None)
	{
		if(PlayerReplicationInfo.Team != None)
		{
			CurrentTeamColor = ColorToLinearColor(PlayerReplicationInfo.Team.TeamColor);
		}
		else
		{
			CurrentTeamColor.R = FRand();
			CurrentTeamColor.G = FRand();
			CurrentTeamColor.B = FRand();
		}
	}
}

simulated function DistributeExperience(HLW_Pawn Killer, Vector KillLocation)
{
	local int EligiblePlayers;
	local HLW_Pawn_Class CurPawn;

	// Get the number of players eligible for the EXP
	EligiblePlayers = 0;
	foreach WorldInfo.AllPawns(class'HLW_Pawn_Class', CurPawn, KillLocation, 2000)
	{
		if (!IsSameTeam(CurPawn) && CurPawn != Killer)
		{
			EligiblePlayers++;
		}
	}

	// For each enemy within a radius of my death...
	foreach WorldInfo.AllPawns(class'HLW_Pawn_Class', CurPawn, KillLocation, 2000)
	{
		if (CurPawn.GetPRI() != none)
		{
			if (!IsSameTeam(CurPawn) && CurPawn != Killer) // Excluding the actual killer...
			{
				// Evenly divide my experience among each eligible player
				CurPawn.GetPRI().SetExperience(CurPawn.GetPRI().Experience + (ExpReward / EligiblePlayers));
			}

			if (CurPawn == Killer)
			{
				// Award full EXP to actual killer
				CurPawn.GetPRI().SetExperience(CurPawn.GetPRI().Experience + ExpReward);
			}
		}
	}
}

simulated function LeveledUp()
{
	local Vector ParticleLocation;
	ParticleLocation = Location;
	ParticleLocation.Z -= GetCollisionHeight();
	SpawnEmitter(ParticleSystem'HLW_AndrewParticles.Particles.FX_Level', ParticleLocation, Rotation,, 3.0);
	VoiceOver = VoiceCueLevelUp;
	PlayVoiceOver(VoiceOver);
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

simulated function PlayDyingSound()
{
	super.PlayDyingSound();
	
	VoiceOver = VoiceCueDied;
	PlayVoiceOver(VoiceOver);
}

function PayIncome()
{
    if (PlayerReplicationInfo != none)
    {
        GetPRI().SetGold( GetPRI().Gold + GetPRI().Income );
    }
}

unreliable server function AmbientExp()
{
	if (PlayerReplicationInfo != none)
    {
        GetPRI().SetExperience( GetPRI().Experience + AmbientExpPerTick );
    }
}

simulated function ScaleMovement(float Rate)
{
	MovementSpeedModifier += Rate;
	
	if(MovementSpeedModifier < 0.0f)
	{
		MovementSpeedModifier = 0.0f;
	}
	else if(MovementSpeedModifier > 1.0f)
	{
		MovementSpeedModifier = 1.0f;
	}
}

simulated function ScaleDamage(float Rate)
{
	DamageScaling += Rate;
	
	if(DamageScaling < 0.0f)
	{
		DamageScaling = 0.0f;
	}
	else if(DamageScaling > 1.0f)
	{
		DamageScaling = 1.0f;
	}
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
    if(ThirdPerson.PhysicsAssetInstance != None)
    {
        ThirdPerson.SetOwnerNoSee(false);
        ThirdPerson.MinDistFactorForKinematicUpdate = 0.f;
        ThirdPerson.SetRBChannel(RBCC_Pawn);
        ThirdPerson.SetRBCollidesWithChannel(RBCC_Default, true);
        ThirdPerson.SetRBCollidesWithChannel(RBCC_Pawn, false);
        ThirdPerson.SetRBCollidesWithChannel(RBCC_Vehicle, false);
        ThirdPerson.SetRBCollidesWithChannel(RBCC_Untitled3, false);
        ThirdPerson.SetRBCollidesWithChannel(RBCC_BlockingVolume, true);
        ThirdPerson.ForceSkelUpdate();
        ThirdPerson.SetTickGroup(TG_PostAsyncWork);
        CollisionComponent = ThirdPerson;
        CylinderComponent.SetActorCollision(false, false);
        ThirdPerson.SetActorCollision(true, false);
        ThirdPerson.SetTraceBlocking(true, true);
        SetPhysics(PHYS_Falling);
        ThirdPerson.PhysicsWeight = 1.0;
    
        if (ThirdPerson.bNotUpdatingKinematicDueToDistance)
        {
            ThirdPerson.UpdateRBBonesFromSpaceBases(true, true);
        }
    
        ThirdPerson.PhysicsAssetInstance.SetAllBodiesFixed(false);
        ThirdPerson.bUpdateKinematicBonesFromAnimation = false;
        ThirdPerson.SetRBLinearVelocity(DeathMomentum * 0.1, false);
        ThirdPerson.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
        ThirdPerson.SetNotifyRigidBodyCollision(true);
        ThirdPerson.WakeRigidBody();
    }
}

//****************************
//********REPLICATION*********
//****************************

//****************************
//WEAPON MESH REPLICATION
//****************************

//Called When Weapon Attachment Is Changed
simulated function WeaponAttachmentChanged()
{
    if ((CurrentWeaponAttachment == None || CurrentWeaponAttachment.Class != CurrentWeaponAttachmentClass) && ThirdPerson.SkeletalMesh != None)
    {
        //Detach/Destroy The Current Attachment If It Exists
        if (CurrentWeaponAttachment != None)
        {
            CurrentWeaponAttachment.DetachFrom(ThirdPerson);
            CurrentWeaponAttachment.Destroy();
        }
        
        //Create New Attachment
        if (CurrentWeaponAttachmentClass != None)
        {
            CurrentWeaponAttachment = Spawn(CurrentWeaponAttachmentClass, Self);
            CurrentWeaponAttachment.Instigator = Self;
        }
        else
        {
            CurrentWeaponAttachment = None;
        }

        //Attach To Pawn Mesh
        if (CurrentWeaponAttachment != None)
        {
            CurrentWeaponAttachment.AttachTo(Self);
        }
    }
}

//****************************
//CUSTOM ANIMATION REPLICATION
//****************************

function PlayAnim(Name NewAnimSlot, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, bool NewbOverride, optional float NewStartTime = 0.0f)
{
    local ReplicatedAnimation NewRepAnim;
    
    Incrementer++;
    
    NewRepAnim.Toggle = !RepAnim.Toggle;
    NewRepAnim.AnimName = NewAnimName;
    NewRepAnim.Rate = NewRate;
    NewRepAnim.BlendInTime = NewBlendInTime;
    NewRepAnim.BlendOutTime = NewBlendOutTime;
    NewRepAnim.bLoop = NewbLoop;
    NewRepAnim.bOverride = NewbOverride;
    NewRepAnim.StartTime = NewStartTime;
    NewRepAnim.BerryImportant = Incrementer;
    
    RepAnim = NewRepAnim;
    
    if(Role < ROLE_Authority)
    {
        ServerPlayAnim(NewAnimSlot, NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop, NewbOverride, NewStartTime);
    }
}

reliable server function ServerPlayAnim(Name NewAnimSlot, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, bool NewbOverride, optional float NewStartTime = 0.0f)
{
    PlayAnim(NewAnimSlot, NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop, NewbOverride, NewStartTime);
}

reliable client function ClientPlayAnim(ReplicatedAnimation Anim)
{
    CustomAnim.PlayCustomAnim(Anim.AnimName, Anim.Rate, Anim.BlendInTime, Anim.BlendOutTime, Anim.bLoop, Anim.bOverride);
}

function PlayAnimTP_Upper(Name NewAnimSlot, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, bool NewbOverride, optional float NewStartTime = 0.0f)
{
    local ReplicatedAnimation NewRepAnim;
    
    Incrementer++;
    
    NewRepAnim.Toggle = !RepAnimTP_Upper.Toggle;
    NewRepAnim.AnimName = NewAnimName;
    NewRepAnim.Rate = NewRate;
    NewRepAnim.BlendInTime = NewBlendInTime;
    NewRepAnim.BlendOutTime = NewBlendOutTime;
    NewRepAnim.bLoop = NewbLoop;
    NewRepAnim.bOverride = NewbOverride;
    NewRepAnim.StartTime = NewStartTime;
    NewRepAnim.BerryImportant = Incrementer;
    
    RepAnimTP_Upper = NewRepAnim;
    
    if(Role < ROLE_Authority)
    {
        ServerPlayAnimTP_Upper(NewAnimSlot, NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop, NewbOverride, NewStartTime);
    }
}

reliable server function ServerPlayAnimTP_Upper(Name NewAnimSlot, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, bool NewbOverride, optional float NewStartTime = 0.0f)
{
    PlayAnimTP_Upper(NewAnimSlot, NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop, NewbOverride, NewStartTime);
}

reliable client function ClientPlayAnimTP_Upper(Name NewAnimSlot, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, bool NewbOverride, optional float NewStartTime = 0.0f)
{
    if(NewStartTime != 0.0f)
    {
        CustomAnimTP_Upper.SetCustomAnim(NewAnimName);
        CustomAnimTP_Upper.PlayAnim(NewbLoop, NewRate, NewStartTime);
    }
    else
    {
        CustomAnimTP_Upper.PlayCustomAnim(NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop, NewbOverride);
    }
}

function PlayAnimTP_Lower(Name NewAnimSlot, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, bool NewbOverride, optional float NewStartTime = 0.0f)
{
    local ReplicatedAnimation NewRepAnim;
    
    Incrementer++;
    
    NewRepAnim.Toggle = !RepAnimTP_Lower.Toggle;
    NewRepAnim.AnimName = NewAnimName;
    NewRepAnim.Rate = NewRate;
    NewRepAnim.BlendInTime = NewBlendInTime;
    NewRepAnim.BlendOutTime = NewBlendOutTime;
    NewRepAnim.bLoop = NewbLoop;
    NewRepAnim.bOverride = NewbOverride;
    NewRepAnim.StartTime = NewStartTime;
    NewRepAnim.BerryImportant = Incrementer;
    
    RepAnimTP_Lower = NewRepAnim;
    
    if(Role < ROLE_Authority)
    {
        ServerPlayAnimTP_Lower(NewAnimSlot, NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop, NewbOverride, NewStartTime);
    }
}

reliable server function ServerPlayAnimTP_Lower(Name NewAnimSlot, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, bool NewbOverride, optional float NewStartTime = 0.0f)
{
    PlayAnimTP_Lower(NewAnimSlot, NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop, NewbOverride, NewStartTime);
}

reliable client function ClientPlayAnimTP_Lower(Name NewAnimSlot, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, bool NewbOverride, optional float NewStartTime = 0.0f)
{
    if(NewStartTime != 0.0f)
    {
        CustomAnimTP_Lower.SetCustomAnim(NewAnimName);
        CustomAnimTP_Lower.PlayAnim(NewbLoop, NewRate, NewStartTime);
    }
    else
    {
        CustomAnimTP_Lower.PlayCustomAnim(NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop, NewbOverride);
    }
}

//****************************
//****************************
//****************************

function PlayAnimDynamic(AnimNodePlayCustomAnim AnimNode, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, bool NewbOverride, optional float NewStartTime = 0.0f)
{
    local ReplicatedAnimation NewRepAnim;
    
    Incrementer++;
    
    NewRepAnim.Toggle = !RepAnimTP_Lower.Toggle;
    NewRepAnim.AnimName = NewAnimName;
    NewRepAnim.Rate = NewRate;
    NewRepAnim.BlendInTime = NewBlendInTime;
    NewRepAnim.BlendOutTime = NewBlendOutTime;
    NewRepAnim.bLoop = NewbLoop;
    NewRepAnim.bOverride = NewbOverride;
    NewRepAnim.StartTime = NewStartTime;
    NewRepAnim.BerryImportant = Incrementer;
    NewRepAnim.CustomNode = AnimNode;
    
    RepAnimDynamic = NewRepAnim;
    
    if(Role < ROLE_Authority)
    {
        ServerPlayAnimDynamic(AnimNode, NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop, NewbOverride, NewStartTime);
    }
}

reliable server function ServerPlayAnimDynamic(AnimNodePlayCustomAnim AnimNode, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, bool NewbOverride, optional float NewStartTime = 0.0f)
{
	PlayAnimDynamic(AnimNode, NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop, NewbOverride, NewStartTime);
}

reliable client function ClientPlayAnimDynamic(AnimNodePlayCustomAnim AnimNode, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, bool NewbOverride, optional float NewStartTime = 0.0f)
{
    if(NewStartTime != 0.0f)
    {
        AnimNode.SetCustomAnim(NewAnimName);
        AnimNode.PlayAnim(NewbLoop, NewRate, NewStartTime);
    }
    else
    {
        AnimNode.PlayCustomAnim(NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop, NewbOverride);
    }
}

simulated function SpawnEmitter(ParticleSystem SpawnTemplate, Vector SpawnLocation, Rotator SpawnRotation, bool DistroyOnFinish = true, optional float Scale = 0)
{
    local ReplicatedEmitter TempRE;
    eIncrementer++;
    TempRE.ParticleSystemName = SpawnTemplate;
    TempRE.SpawnLocation = SpawnLocation;
    TempRE.SpawnRotation = SpawnRotation;
    TempRE.DistroyOnFinish = DistroyOnFinish;
    TempRE.Scale = Scale;
    TempRE.BerryImportant = eIncrementer;
    RepEmit = TempRE;
}

reliable client function ClientSpawnEmitter(ReplicatedEmitter Emitter)
{
	local ParticleSystemComponent temp;
    /*local HLW_Emitter TempEmitter;
    TempEmitter = Spawn(class'HLW_Emitter', self,, Emitter.SpawnLocation, Emitter.SpawnRotation);
    TempEmitter.SetTemplate(Emitter.ParticleSystemName, Emitter.DistroyOnFinish);
    if(Emitter.Scale != 0)
    {
        TempEmitter.SetDrawScale(Emitter.Scale);
    }*/
	//temp = new class'ParticleSystemComponent';
	//temp.SetTemplate(Emitter.ParticleSystemName);
	//temp.SetScale(Emitter.Scale);
	if(WorldInfo.MyEmitterPool != None)
	{
		temp = WorldInfo.MyEmitterPool.SpawnEmitter(Emitter.ParticleSystemName, Emitter.SpawnLocation, Emitter.SpawnRotation);
		//temp.SetTemplate(Emitter.ParticleSystemName);
		if(temp != None)
		{
			temp.SetScale(Emitter.Scale);
		}
	}
}

simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{	
    if(InstigatedBy != None)
    {
    	LastPlayerToHitMe = InstigatedBy;
    	ClearTimer('ResetLastPlayerToHitMe');
    	SetTimer(15.0f, false, 'ResetLastPlayerToHitMe');
        bCanDrawDamage = true;
        LastDamageTaken = Damage * DamageScaling;

		if(InstigatedBy.Pawn != none)
		{
			HLW_Pawn_Class(InstigatedBy.Pawn).GetPRI().SetDamageTaken(LastDamageTaken);
			HLW_Pawn_Class(InstigatedBy.Pawn).GetPRI().SetDraw(true);
		}

		if(Role == ROLE_Authority && InstigatedBy != Controller)
		{
			if(bCanHurtVO && !IsSameTeam(InstigatedBy.Pawn))
			{
				VoiceOver = VoiceCueHurt;
				PlayVoiceOver(VoiceOver);
				bCanHurtVO = false;
				SetTimer(2.0f, false, 'ResetHurtVO');
			}	
		}
		
		DeathMomentum = Momentum;
    }

    super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

simulated function ResetLastPlayerToHitMe()
{
	LastPlayerToHitMe = None;
	//`log("I CAN SUICIDE NOW!");
}

function bool IsLocationOnHead(Vector HitLocation, Vector HitDirection, float AdditionalScale)
{
	local vector HeadLocation;
	local float Distance;

	if (HeadBone == '')
	{
		return False;
	}

	ThirdPerson.ForceSkelUpdate();
	HeadLocation = ThirdPerson.GetBoneLocation(HeadBone) + vect(0,0,1) * HeadHeight;

	// Find distance from head location to bullet vector
	Distance = PointDistToLine(HeadLocation, HitDirection, HitLocation);

	return ( Distance < (HeadRadius * HeadScale * AdditionalScale) );
}

reliable server function ResetHurtVO()
{
	bCanHurtVO = true;	
}

function Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	if(HLW_Path_Blocking_Volume(Other) != none)
	{
		inPathBlockingVolume = true;
	}
}

function UnTouch(Actor Other)
{
	if(HLW_Path_Blocking_Volume(Other) != none)
	{
		inPathBlockingVolume = false;
	}
}

reliable server function ServerSpawn(int creepType)
{
    //`log("Creep being Spawned: " @ creepType);
	if(GetPRI().Gold >= (10 * creepType * creepLevel) && creepType != 7 && creepType != 8)
	{
	    GetPRI().SetGold( GetPRI().Gold - (10 * creepType * creepLevel) );
	    Factory.SpawnCreepTimer(creepType, creepLevel);
	    GetPRI().SetIncome( GetPRI().Income + 2 * creepType * creepLevel );
	}
	else if(creepType == 7 && GetPRI().Gold >= (100 * creepLevel))
	{
	    if(GetPRI().Income < (50 * creepLevel))
	    {
	        //`log("Need more income");
	    }

	    GetPRI().SetGold( GetPRI().Gold - (100 * creepLevel) );
	    GetPRI().SetIncome( GetPRI().Income - (10 * creepLevel) );
	    Factory.SpawnCreepTimer(creepType, creepLevel);
	}
	else if(creepType == 8 && GetPRI().Gold >= (150 * creepLevel))
	{
	    GetPRI().SetGold( GetPRI().Gold -= (150 * creepLevel) );
	    creepLevel++;
	    //`log("Current Creep Level: " @ creepLevel);
	}
	else
	{
	    //`log("Couldn't spawn - Player Controller - Not Enough Gold");
	}
}

exec function SpawnCreeps()
{
    HLW_PlayerController(Controller).getPCCreepNumber();
    creepToSpawn = GetPRI().SelectedCreep;  
    //`log("Current selected creep: " @ creepToSpawn);
    //`log("My factory's team: " @ Factory.teamIndex);
    //`log("My team: " @ Controller.PlayerReplicationInfo.Team.TeamIndex);
    
    if(!bSpawnCooldown)
        ServerSpawn(creepToSpawn);
    //else
        //`log("SPAWN COOLDOWN");
}

function bool Leap(eDoubleClickDir DoubleClickMove)
{
	local vector X,Y,Z, Dir, Cross;
	local rotator TurnRot;

	TurnRot.Yaw = Rotation.Yaw;
	GetAxes(TurnRot,X,Y,Z);
	
	switch(DoubleClickMove)
	{
		case DCLICK_Forward:
			Dir = X;
			Cross = Y;
			break;
		case DCLICK_Back:
			Dir = -1 * X;
			Cross = Y;
			break;
		case DCLICK_Left:
			Dir = -1 * Y;
			Cross = X;
			break;
		case DCLICK_Right:
			Dir = Y;
			Cross = X;
			break;	
	}
		
	return PerformLeap(DoubleClickMove, Dir, Cross);
}

function bool PerformLeap(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross)
{
	//local float VelocityZ;

	//if ( Physics == PHYS_Falling )
	//{
		TakeFallingDamage();
	//}

	bDodging = true;
	//VelocityZ = Velocity.Z;
	Velocity = DodgeSpeed*Dir + (Velocity Dot Cross)*Cross;

	Velocity.Z = DodgeSpeedZ;
	
	CurrentDir = DoubleClickMove;
	SetPhysics(PHYS_Falling);

	return true;
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	local vector X,Y,Z, TraceStart, TraceEnd, Dir, Cross, HitLocation, HitNormal;
	local Actor HitActor;
	local rotator TurnRot;

	//Put Stuff That Won't Allow Dodge In This Check
	if((Physics != PHYS_Walking && Physics != PHYS_Falling))
	{
		return false;
	}

	TurnRot.Yaw = Rotation.Yaw;
	GetAxes(TurnRot,X,Y,Z);

	if(Physics == PHYS_Falling)
	{
		switch(DoubleClickMove)
		{
			case DCLICK_Forward:
				TraceEnd = -X;
				break;
			case DCLICK_Back:
				TraceEnd = X;
				break;
			case DCLICK_Left:
				TraceEnd = Y;
				break;
			case DCLICK_Right:
				TraceEnd = -Y;
				break;	
		}
			
		TraceStart = Location - (CylinderComponent.CollisionHeight - 16)*Vect(0,0,1) + TraceEnd*(CylinderComponent.CollisionRadius-16);
		TraceEnd = TraceStart + TraceEnd*40.0;
		HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, false, vect(16,16,16));

		if((HitActor == None) || (HitNormal.Z < -0.1))
		{
			 return false;
		}
			 
		if (!HitActor.bWorldGeometry)
		{
			if (!HitActor.bBlockActors)
			{
				return false;
			}
				
			if ((Pawn(HitActor) != None))
			{
				return false;
			}
		}
	}
	
	switch(DoubleClickMove)
	{
		case DCLICK_Forward:
			Dir = X;
			Cross = Y;
			break;
		case DCLICK_Back:
			Dir = -1 * X;
			Cross = Y;
			break;
		case DCLICK_Left:
			Dir = -1 * Y;
			Cross = X;
			break;
		case DCLICK_Right:
			Dir = Y;
			Cross = X;
			break;	
	}
		
	return PerformDodge(DoubleClickMove, Dir, Cross);
}

function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross)
{
	//local float VelocityZ;

	//if ( Physics == PHYS_Falling )
	//{
		TakeFallingDamage();
	//}

	bDodging = true;
	//VelocityZ = Velocity.Z;
	Velocity = DodgeSpeed*Dir + (Velocity Dot Cross)*Cross;

	Velocity.Z = DodgeSpeedZ;
	
	CurrentDir = DoubleClickMove;
	SetPhysics(PHYS_Falling);

	return true;
}

function startSpawnCooldown()
{
    bSpawnCooldown = true;
    SetTimer(2, false, 'endSpawnCooldown');
}

function endSpawnCooldown()
{
    bSpawnCooldown = false;
}

exec function ChangePauseCreeps()
{
    pauseCreeps = !pauseCreeps;
}

event Bump(Actor Other, PrimitiveComponent OtherComp, vector HitNormal)
{
    if(HLW_Pawn_Creep(Other) != none)
    {
        TakeDamage(HLW_Pawn_Creep(Other).BumpDamage, none, Location, vect(0,0,0), class'UTDmgType_LinkPlasma');
    }
    else
    {
        super.Bump(Other, OtherComp, HitNormal);    
    }
}

simulated function AbilityBeingAimed(HLW_Ability Ability)
{
    if(AnimNodeBlend != None)
    {
        AnimNodeBlend.SetBlendTarget(1.0f, 0.35f);
		SwitchToCast = true;
		PlayCustomAnim("TPU", 'Mage_Cast_Start', 1, 1);
    }
}

simulated function AbilityEndingAim(HLW_Ability Ability)
{
    if(AnimNodeBlend != None)
    {
        AnimNodeBlend.SetBlendTarget(0.0f, 0.35f);
    }
	ServerStopCasting();
}

simulated function AbilityBeingCast(HLW_Ability Ability)
{
    if(AnimNodeBlend != None)
    {
        AnimNodeBlend.SetBlendTarget(0.0f, 0.35f);
        CustomAnimation.PlayCustomAnim('Mage_Casting_Cast', 1.0f, 0.05f, 0.01f,,true);
	}

	ServerStopCasting();
}

reliable client function ClientAnimNodeBlend(AnimNodeBlend BlendThis, float Target, float Time)
{
	if (BlendThis != none)
	{
		BlendThis.SetBlendTarget(Target, Time);
	}
}

reliable server function ServerStopCasting()
{
	SwitchToCast = false;
}

simulated function SetWeapon(Weapon NewWeapon);

simulated function Vector GetSocketLocation(Name SocketName)
{
   local Vector SocketLocation;
   local Rotator SocketRotation;

   if (Mesh != none && Mesh.GetSocketByName(SocketName) != none)
   {
      Mesh.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SocketRotation);
   }

   return SocketLocation;
}

simulated function Rotator GetSocketRotation(Name SocketName)
{
   local Vector SocketLocation;
   local Rotator SocketRotation;

   if (Mesh != none && Mesh.GetSocketByName(SocketName) != none)
   {
      Mesh.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SocketRotation);
   }

   return SocketRotation;
}

simulated function HLW_PlayerReplicationInfo GetPRI()
{
    return HLW_PlayerReplicationInfo(PlayerReplicationInfo);
}



// currently only used by archer
reliable client function ClientSetMaterialScalar(MeshComponent ChangeMesh, int MatIndex, Name ParamName, float Value)
{
	if(ChangeMesh != none)
	{
		if(MaterialInstanceConstant(ChangeMesh.Materials[MatIndex]) != None)
		{
				MaterialInstanceConstant(ChangeMesh.Materials[MatIndex]).SetScalarParameterValue(ParamName, Value);
		}
	}
}

reliable client function ClientSetMaterialVector(MeshComponent ChangeMesh, int MatIndex, Name ParamName, LinearColor ColorValue)
{
	if(ChangeMesh != none)
	{
		if(MaterialInstanceConstant(ChangeMesh.Materials[MatIndex]) != None)
		{
			MaterialInstanceConstant(ChangeMesh.Materials[MatIndex]).SetVectorParameterValue(ParamName, ColorValue);
		}
	}
}

/*
 * @Parameter AnimType - "FP" (First Person), "TPU" (3rd Person Upper), "TPL" (3rd Person Lower), or "TPB" (3rd Person Both)
 * @Parameter AnimName - Animation Name
 * @Parameter OPTIONAL AnimLength - Animation Length (Defaults To 0.0f) ONLY USE IF BlendPercent IS NOT 0
 * @Parameter OPTIONAL Rate - Animation Rate (Defaults To 1.0f)
 * @Parameter OPTIONAL BlendPercent - Percentage Of Animation To Blend In and Out (Defaults To 0.125f)
 * @Parameter OPTIONAL BlendIn - Length To Blend In To Animation (Defaults To 0.0f) ONLY USE IF BlendPercent IS 0
 * @Parameter OPTIONAL BlendOut - Length To Blend Out Of Animation (Defaults To 0.0f) ONLY USE IF BlendPercent IS 0
 * @Parameter OPTIONAL Loop - Loop Animation (Defaults To False)
 * @Parameter OPTIONAL Override - Override Allows Animations To Play The Same Animation Twice (Defaults To True)
 */
simulated function PlayCustomAnim(string AnimType, Name AnimName, optional float AnimLength = 0.0f, optional float Rate = 1.0f, optional float BlendPercent = 0.125f, optional float BlendIn = 0.0f, optional float BlendOut = 0.0f, optional bool Loop = false, optional bool Override = true)
{
	switch(Caps(AnimType))
	{
		case "FP":
			if(BlendPercent != 0)
			{
				PlayAnim('Who', AnimName, Rate, AnimLength * BlendPercent * Rate, AnimLength * BlendPercent * Rate, Loop, Override);
			}
			else
			{
				PlayAnim('Who', AnimName, Rate, BlendIn, BlendOut, Loop, Override);
			}
			break;
		case "TPU":
			if(BlendPercent != 0)
			{
				PlayAnimTP_Upper('Who', AnimName, Rate, AnimLength * BlendPercent * Rate, AnimLength * BlendPercent * Rate, Loop, Override);
			}
			else
			{
				PlayAnimTP_Upper('Who', AnimName, Rate, BlendIn, BlendOut, Loop, Override);
			}
			break;
		case "TPL":
			if(BlendPercent != 0)
			{
				PlayAnimTP_Lower('Who', AnimName, Rate, AnimLength * BlendPercent * Rate, AnimLength * BlendPercent * Rate, Loop, Override);
			}
			else
			{
				PlayAnimTP_Lower('Who', AnimName, Rate, BlendIn, BlendOut, Loop, Override);
			}
			break;
		case "TPB":
			if(BlendPercent != 0)
			{
				PlayAnimTP_Upper('Who', AnimName, Rate, AnimLength * BlendPercent * Rate, AnimLength * BlendPercent * Rate, Loop, Override);
				PlayAnimTP_Lower('Who', AnimName, Rate, AnimLength * BlendPercent * Rate, AnimLength * BlendPercent * Rate, Loop, Override);
			}
			else
			{
				PlayAnimTP_Upper('Who', AnimName, Rate, BlendIn, BlendOut, Loop, Override);
				PlayAnimTP_Lower('Who', AnimName, Rate, BlendIn, BlendOut, Loop, Override);
			}
			break;
	}
}

simulated function PlayVoiceOver(SoundCue NewSound)
{
	VoiceOver = NewSound;
	VoiceComponent.Stop();
	VoiceComponent.SoundCue = VoiceOver;
	
	if(NewSound != None)
	{
		VoiceComponent.Play();
		SetTimer(VoiceComponent.SoundCue.Duration, false, 'ResetVoiceOver');
	}	
}

simulated function ResetVoiceOver()
{
	VoiceOver=None;
	PlayVoiceOver(VoiceOver);	
}

simulated state Stunned
{
	simulated function BeginState(Name PreviousStateName)
	{
		local byte i;
		
		super.BeginState(PreviousStateName);
		
		CachedPreviousState = PreviousStateName;
		
		//`log("STUN STATE");
		
		for(i = 0; i < ArrayCount(GetPRI().Abilities); i++)
		{
			//`log("Stun State: Telling Ability["$i$"] To Get Stunned");
			GetPRI().Abilities[i].GotStunned();	
		}

		HLW_PlayerController(Controller).bCanAttackPrimary = false;
		HLW_PlayerController(Controller).bCanAttackSecondary = false;
		HLW_PlayerController(Controller).bCanUseAbilities = false;
		HLW_PlayerController(Controller).bCanAcceptLookInput = false;
		HLW_PlayerController(Controller).IgnoreMoveInput(true);
		
		//Play Stun Animation
		SetTimer(10.0, false, 'GoToLastState');//Set Timer To End Stun
	}
	
	simulated function GoToLastState()
	{
		GoToState(CachedPreviousState);	
	}
	
	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		
		//`log("END STUN STATE");
		
		HLW_PlayerController(Controller).bCanAttackPrimary = true;
		HLW_PlayerController(Controller).bCanAttackSecondary = true;
		HLW_PlayerController(Controller).bCanUseAbilities = true;
		HLW_PlayerController(Controller).bCanAcceptLookInput = true;
		HLW_PlayerController(Controller).IgnoreMoveInput(false);
	}	
}

state Dying
{
	function BeginState(Name PreviousStateName)
	{
		local Actor A;

		// Loop through all the actors this pawn was touching
		foreach TouchingActors(class'Actor', A)
		{
			// Check to see if the pawn was touching a team only trigger
			if(A.IsA('HLW_Trigger_TeamOnly'))
			{
				// Notify the trigger that the pawn died so the trigger can remove it from it's touching list
				HLW_Trigger_TeamOnly(A).NotifyTouchingPawnDied(self);
			}
		}

		super.BeginState(PreviousStateName);
	}
}

//Only useful to warrior, but gets rid of warnings for other clients
simulated function StartAttackStatus(){}
simulated function EndAttackStatus(){}
simulated function UpdateTraceStatus(){}

DefaultProperties
{
    Begin Object class=SkeletalMeshComponent Name=ArmsMesh
        CastShadow = false
        bOwnerNoSee=false
        bOnlyOwnerSee=true
        BlockRigidBody=true
        CollideActors=true
        BlockZeroExtent=true
        bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicLights=false
		bAcceptsDynamicDecals=true
        AnimSets(0)=AnimSet'HLW_Package.Animations.1p_arm_animset'
        AnimTreeTemplate=AnimTree'HLW_Package.Animations.1p_arms_animtree'
        SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.FP_Arms_Temp'//SkeletalMesh'HLW_Package.Models.1p_arms_default'
    End Object
    Mesh=ArmsMesh
    Components.Add(ArmsMesh)
    
    Begin Object Class=SkeletalMeshComponent Name=ThirdPersonMesh
    	RBChannel=RBCC_Pawn
        CastShadow = true
        bOwnerNoSee=true
        BlockRigidBody=true
        CollideActors=true
        BlockZeroExtent=true
        bCastHiddenShadow=true
        bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=true
    End Object
    ThirdPerson=ThirdPersonMesh
    Components.Add(ThirdPersonMesh)

	Begin Object Name=CollisionCylinder
		bAcceptsDynamicDecals=true
	End Object
	
	Begin Object Class=AudioComponent Name=VoiceComponentObject
		bUseOwnerLocation=true
	End Object
	VoiceComponent=VoiceComponentObject
	Components.Add(VoiceComponentObject)
	
    
    InventoryManagerClass=class'HLW_InventoryManager'
    
    Opacity=1
    CanRagdoll=0
    creepToSpawn=1
    creepLevel=1

	bInitiliazedHUD=false
	bDodging=false
	bDrawNamePlate=true
	bHasDied=false
	
    MoveSprintPercentage=1.5
    MoveBackwardPercentage=0.75
    MoveStrafePercentage=0.95
    DodgeSpeed=600.0
    DodgeSpeedZ=295.0
    BaseExpReward=256
    ExpReward=256
	AmbientExpPerTick=20
    MaxStepHeight=45

	AbilityClasses(0)=class'HLW_Ability'
	AbilityClasses(1)=class'HLW_Ability'
	AbilityClasses(2)=class'HLW_Ability'
	AbilityClasses(3)=class'HLW_Ability'
	AbilityClasses(4)=class'HLW_Ability'
	
	BlueTeamColor=(R=0,G=0.556553,B=0.915730,A=1)
	YellowTeamColor=(R=0.894117,G=0.752941,B=0.10196,A=1)

	bCanHurtVO=true
	
	BaseUpgradePoints=1
	
}
