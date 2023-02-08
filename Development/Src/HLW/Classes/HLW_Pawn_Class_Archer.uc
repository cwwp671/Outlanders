/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Pawn_Class_Archer extends HLW_Pawn_Class
placeable;

var name BowSocket;
var name BowSocketTP;
var Name StringSocket;
var Name BowStringSocket;
var Name FartSocket;

var bool bCanHitReaction;
var bool bIsAttacking;
var bool bAttackHeld; 
var bool bIsAiming; 
var bool initBowStringControl;
var SkelControlSingleBone BowStringControl;

var UDKAnimBlendBase ShootList;
var UDKAnimBlendBase BarrageList;
var UDKAnimBlendBase UpperShootList;
var UDKAnimBlendBase LowerShootList;
var UDKAnimBlendBase UpperBarrageList;
var UDKAnimBlendBase LowerBarrageList;
var repnotify byte UpperShootIndex;
var repnotify byte LowerShootIndex;
var repnotify byte UpperBarrageIndex;
var repnotify byte LowerBarrageIndex;

var AudioComponent BowAudioComponent;

var repnotify SoundCue BowSound;

enum TrapType
{
	HLW_POISON,
	HLW_BEAR,
	HLW_EXPLOSIVE
};

enum AnimShootList
{
	_NOTCH,
	_DRAW,
	_HOLD,
	_RELEASE
};

enum AnimLowerBarrageList
{
	BARRAGEPRE,
	BARRAGEIDLE,
	BARRAGEEND
};

enum AnimStateList
{
	_NORMAL,
	_SHOOT,
	_VOLLEY,
	_CLOAK,
	_TRAP,
	_BARRAGE	
};

enum ArcherAnimNodesTP
{
	UPPERSTATE,
	LOWERSTATE,
	UPPERSHOOT,
	LOWERSHOOT,
	UPPERVOLLEY,
	LOWERVOLLEY,
	UPPERCLOAK,
	LOWERCLOAK,
	UPPERTRAPS,
	LOWERTRAPS,
	UPPERBARRAGE,
	LOWERBARRAGE
};

var TrapType TrapIndex;

replication 
{
	if(bNetDirty)
		BowSound;
		
    if(bNetDirty && !bNetOwner)
		UpperShootIndex, LowerShootIndex, UpperBarrageIndex, LowerBarrageIndex;
}
simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'UpperStateIndex')
	{
		switch(UpperStateIndex)
		{
			case _NORMAL:
				ClientSetAnimState(UPPERSTATE, _NORMAL);
				break;
			case _SHOOT:
				ClientSetAnimState(UPPERSTATE, _SHOOT);
				break;
			case _VOLLEY:
				ClientSetAnimState(UPPERSTATE, _VOLLEY);
				break;
			case _CLOAK:
				ClientSetAnimState(UPPERSTATE, _CLOAK);
				break;
			case _TRAP:
				ClientSetAnimState(UPPERSTATE, _TRAP);
				break;
			case _BARRAGE:
				ClientSetAnimState(UPPERSTATE, _BARRAGE);
				break;
		}	
		return;
	}
	else if(VarName == 'LowerStateIndex')
	{
		switch(LowerStateIndex)
		{
			case _NORMAL:
				ClientSetAnimState(LOWERSTATE, _NORMAL);
				break;
			case _SHOOT:
				ClientSetAnimState(LOWERSTATE, _SHOOT);
				break;
			case _VOLLEY:
				ClientSetAnimState(LOWERSTATE, _VOLLEY);
				break;
			case _CLOAK:
				ClientSetAnimState(LOWERSTATE, _CLOAK);
				break;
			case _TRAP:
				ClientSetAnimState(LOWERSTATE, _TRAP);
				break;
			case _BARRAGE:
				ClientSetAnimState(LOWERSTATE, _BARRAGE);
				break;
		}	
		return;
	}
    else if(VarName == 'UpperShootIndex')
    {
		switch(UpperShootIndex)
		{
			case _NOTCH:
				ClientNotchArrow();
				break;
			case _DRAW:
				ClientDrawArrow();
				break;
			case _HOLD:
				ClientDrawIdle();
				break;
			case _RELEASE:
				ClientReleaseArrow();
				break;		
		}
		
		return;
    }
    else if(VarName == 'LowerShootIndex')
    {
    	
    }
    else if(VarName == 'UpperBarrageIndex')
    {
    	switch(UpperBarrageIndex)
    	{
    		case _NOTCH:
				ClientSetAnimState(UPPERBARRAGE, _NOTCH);
				break;
			case _DRAW:
				ClientSetAnimState(UPPERBARRAGE, _DRAW);
				break;
			case _HOLD:
				ClientSetAnimState(UPPERBARRAGE, _HOLD);
				break;
			case _RELEASE:
				ClientSetAnimState(UPPERBARRAGE, _RELEASE);
				break;
		}
    }
    else if(VarName == 'LowerBarrageIndex')
    {
    	switch(LowerBarrageIndex)
    	{
    		case BARRAGEPRE:
    			ClientSetAnimState(LOWERBARRAGE, BARRAGEPRE);
    			break;
    		case BARRAGEIDLE:
    			ClientSetAnimState(LOWERBARRAGE, BARRAGEIDLE);
    			break;
    		case BARRAGEEND:
    			ClientSetAnimState(LOWERBARRAGE, BARRAGEEND);
    			break;
    	}
		
		return;
    }
    else if(VarName == 'BowSound')
	{
		PlayBowSound(BowSound);
		
		return;
	}
	
    super.ReplicatedEvent(VarName);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	AttachComponent(ThirdPerson);
	
	initBowStringControl = true;
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_Package_Lukas.Material.Archer_Invisible'); 
	Mesh.SetMaterial(0, MatInst); 
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_Package_Randolph.Materials.WoodRingMat'); 
	ThirdPerson.SetMaterial(0, MatInst);
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_mapProps.Materials.TempHair'); 
	ThirdPerson.SetMaterial(1, MatInst);
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_mapProps.Materials.skinColor_Mat'); 
	ThirdPerson.SetMaterial(2, MatInst);
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_Package_Randolph.Materials.ArchArmorMat'); 
	ThirdPerson.SetMaterial(3, MatInst);
}

reliable client function ClientSetTeamColor(LinearColor NewTeamColor)
{
	super.ClientSetTeamColor(NewTeamColor);
	
	ClientSetMaterialVector(ThirdPerson, 3, 'TeamColor', NewTeamColor);
    ClientSetMaterialVector(Mesh, 0, 'TeamColor', NewTeamColor);	
}

reliable client function ClientSetOpacity(float NewOpacity)
{
	local MaterialInstanceConstant BowMatInst;
	
	super.ClientSetOpacity(NewOpacity);
	
	ClientSetMaterialScalar(Mesh, 0, 'Opacity', Opacity);
    ClientSetMaterialScalar(ThirdPerson, 0, 'Opacity', Opacity);
	
    if(Opacity < 1 && (CurrentWeaponAttachment.Mesh.GetMaterial(0) != Material'HLW_Package_Lukas.Material.Archer_Invisible'))
    {
    	BowMatInst = new(None) Class'MaterialInstanceConstant';
		BowMatInst.SetParent(Material'HLW_Package_Lukas.Material.Archer_Invisible');
		BowMatInst.SetVectorParameterValue('TeamColor', CurrentTeamColor);
		
		ThirdPerson.SetMaterial(0, BowMatInst);
		ThirdPerson.SetMaterial(1, BowMatInst);
		ThirdPerson.SetMaterial(2, BowMatInst);
		ThirdPerson.SetMaterial(3, BowMatInst);
		
		if(Weapon != none)
		{
			Weapon.Mesh.SetMaterial(0, BowMatInst);
		}
		CurrentWeaponAttachment.Mesh.SetMaterial(0, BowMatInst);
    }
    else
    {
    	BowMatInst = new(None) Class'MaterialInstanceConstant';
		BowMatInst.SetParent(Material'HLW_mapProps.Materials.BowMat');
		BowMatInst.SetVectorParameterValue('TeamColor', CurrentTeamColor);

		MatInst = new(None) Class'MaterialInstanceConstant';
		MatInst.SetParent(Material'HLW_Package_Randolph.Materials.WoodRingMat'); 
		ThirdPerson.SetMaterial(0, MatInst);
	
		MatInst = new(None) Class'MaterialInstanceConstant';
		MatInst.SetParent(Material'HLW_mapProps.Materials.TempHair'); 
		ThirdPerson.SetMaterial(1, MatInst);
	
		MatInst = new(None) Class'MaterialInstanceConstant';
		MatInst.SetParent(Material'HLW_mapProps.Materials.skinColor_Mat'); 
		ThirdPerson.SetMaterial(2, MatInst);
	
		MatInst = new(None) Class'MaterialInstanceConstant';
		MatInst.SetParent(Material'HLW_Package_Randolph.Materials.ArchArmorMat'); 
		MatInst.SetVectorParameterValue('TeamColor', CurrentTeamColor);
		ThirdPerson.SetMaterial(3, MatInst);
		
		if(Weapon != none)
		{
			Weapon.Mesh.SetMaterial(0, BowMatInst);
		}
		CurrentWeaponAttachment.Mesh.SetMaterial(0, BowMatInst);
    }
    
    ClientSetMaterialScalar(CurrentWeaponAttachment.Mesh, 0, 'Opacity', Opacity);
	if(Weapon != none)
	{
		ClientSetMaterialScalar(Weapon.Mesh, 0, 'Opacity', Opacity);
	}
}

simulated function StopFire(byte FireModeNum)
{
	super.StopFire(FireModeNum);
}


simulated event Destroyed()
{
	Super.Destroyed();
  
	BowStringControl = None;
	ShootList = None;
	BarrageList = None;
	UpperShootList = None;
	LowerShootList = None;
	UpperBarrageList = None;
	LowerBarrageList = None;
}

simulated function AddDefaultInventory()
{
	super.AddDefaultInventory();
	
    InvManager.CreateInventory(class'HLW_Ranged_Bow'); //InvManager is the pawn's InventoryManager
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        CustomAnim = AnimNodePlayCustomAnim(Mesh.FindAnimNode('CustomAnimNode'));
		StateList = UDKAnimBlendBase(Mesh.FindAnimNode('StateList'));
		ShootList = UDKAnimBlendBase(Mesh.FindAnimNode('ShootList'));
		BarrageList = UDKAnimBlendBase(Mesh.FindAnimNode('BarrageList'));
    }
    
    if (SkelComp == ThirdPerson)
    {
    	CustomAnimTP_Upper = AnimNodePlayCustomAnim(ThirdPerson.FindAnimNode('CustomUpperAnimation'));
    	CustomAnimTP_Lower = AnimNodePlayCustomAnim(ThirdPerson.FindAnimNode('CustomLowerAnimation'));
		UpperShootList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('UpperShootList'));
		UpperStateList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('UpperStateList'));
		LowerShootList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('LowerShootList'));
		LowerStateList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('LowerStateList'));
		UpperBarrageList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('UpperBarrageList'));
		LowerBarrageList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('LowerBarrageList'));
    }
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	return super.Died(Killer, damageType, HitLocation);	
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
}

simulated function bool SwitchTrap(int TrapInd)
{
	switch(TrapInd)
	{
		Case HLW_POISON:
			HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(3, "Poison" , 3);
			return true;
			break;
		Case HLW_BEAR:
			HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(3, "Bear" , 3);
			return true;
			break;
		Case HLW_EXPLOSIVE:
			HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(3, "Explosive", 3);
			return true;
			break;
	}
	
	return false;
}

simulated function PlayerInitialized()
{
	super.PlayerInitialized();

	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(1, "Volley", 3);
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(2, "Cloak", 3);
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(3, "Poison", 3);
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(4, "Blast", 3);
	switch(HLW_Ability_Trap(GetPRI().Abilities[3]).TrapIndex)
	{
		case 0:
			HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(3, "Poison", 3);
			break;
		case 1:
			HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(3, "Bear", 3);
			break;
		case 2:
			HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(3, "Explosive", 3);
			break;
		default:
			HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(3, "What?", 3);
			break;	
		
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

simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(Role < ROLE_Authority)
	{
		if(bCanHitReaction && !bIsAttacking)
		{
			HitReaction();
		}
	}
	
	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

simulated function HitReaction()
{
	bCanHitReaction = false;
	SetTimer(1.5f, false, 'ResetHitReaction');	
}

simulated function ResetHitReaction()
{
	bCanHitReaction = true;	
}

simulated function SetAnimState(byte AnimNode, byte AnimState, float BlendIn = 0.0f)
{
	switch(AnimNode)
	{
		case UPPERSTATE:
			super.SetAnimState(AnimNode, AnimState, BlendIn);
			return;
		case LOWERSTATE:
			super.SetAnimState(AnimNode, AnimState, BlendIn);
			return;
		case UPPERSHOOT:
			UpperShootList.SetActiveChild(AnimState, BlendIn);
			ShootList.SetActiveChild(AnimState, BlendIn);
			break;
		case LOWERSHOOT:
			LowerShootList.SetActiveChild(AnimState, BlendIn);
			break;
		case UPPERVOLLEY:
			break;
		case LOWERVOLLEY:
			break;
		case UPPERCLOAK:
			break;
		case LOWERCLOAK:
			break;
		case UPPERTRAPS:
			break;
		case LOWERTRAPS:
			break;
		case UPPERBARRAGE:
			UpperBarrageList.SetActiveChild(AnimState, BlendIn);
			BarrageList.SetActiveChild(AnimState, BlendIn);
			break;
		case LOWERBARRAGE:
			LowerBarrageList.SetActiveChild(AnimState, BlendIn);
			break;	
	}

	if(Role < ROLE_Authority)
	{
		ServerSetAnimState(AnimNode, AnimState);
	}
}

reliable server function ServerSetAnimState(byte AnimNode, byte AnimState)
{
	switch(AnimNode)
	{
		case UPPERSHOOT:
			UpperShootIndex = AnimState;
			return;
		case LOWERSHOOT:
			LowerShootIndex = AnimState;
			return;
		case UPPERVOLLEY:
			return;
		case LOWERVOLLEY:
			return;
		case UPPERCLOAK:
			return;
		case LOWERCLOAK:
			return;
		case UPPERTRAPS:
			return;
		case LOWERTRAPS:
			return;
		case UPPERBARRAGE:
			UpperBarrageIndex = AnimState;
			return;
		case LOWERBARRAGE:
			LowerBarrageIndex = AnimState;
			return;	
	}
	
	super.ServerSetAnimState(AnimNode, AnimState);
}

reliable client function ClientSetAnimState(byte AnimNode, byte AnimState)
{
	switch(AnimNode)
	{
		case UPPERSHOOT:
			UpperShootList.SetActiveChild(AnimState, 0.0f);
			ShootList.SetActiveChild(AnimState, 0.0f);
			return;
		case LOWERSHOOT:
			LowerShootList.SetActiveChild(AnimState, 0.0f);
			return;
		case UPPERVOLLEY:
			return;
		case LOWERVOLLEY:
			return;
		case UPPERCLOAK:
			return;
		case LOWERCLOAK:
			return;
		case UPPERTRAPS:
			return;
		case LOWERTRAPS:
			return;
		case UPPERBARRAGE:
			UpperBarrageList.SetActiveChild(AnimState, 0.0f);
			BarrageList.SetActiveChild(AnimState, 0.0f);
			return;
		case LOWERBARRAGE:
			LowerBarrageList.SetActiveChild(AnimState, 0.0f);
			return;	
	}
	
	super.ClientSetAnimState(AnimNode, AnimState);
}

simulated function ArcherSetAnimState(UDKAnimBlendBase Node, byte AnimState, float BlendIn = 0.0f)
{
	Node.SetActiveChild(AnimState, BlendIn);

	if(Role < ROLE_Authority)
	{
		ArcherServerSetAnimState(Node, AnimState);
	}
}

reliable server function ArcherServerSetAnimState(UDKAnimBlendBase Node, byte AnimState)
{
	UpperShootIndex = AnimState;
}

simulated function ArcherNotchArrow()
{
	//PlayAnim('CustomAnim', 'Archer_Hands_Notch', 0.7917f, 0.0989625f, 0.0f, false, true);
	//PlayAnimTP_Upper('CustomAnimTP', 'Archer_Upper_Notch', 0.7917f, 0.0989625f, 0.0f, false, true);
	StateList.SetActiveChild(_SHOOT, 0.0f);
	ShootList.SetActiveChild(_NOTCH, 0.0989625f);
	UpperStateList.SetActiveChild(_SHOOT, 0.0f);
	UpperShootList.SetActiveChild(_NOTCH, 0.0989625f);
	ServerNotchArrow();
	//PlayAnimDynamic(HLW_Ranged_Bow(Weapon).BowAnimation, 'Bow_Notch', 1.0f, 0.125f, 0.0f, false, true);
}

reliable server function ServerNotchArrow()
{
	//StateList.SetActiveChild(_SHOOT, 0.0f);
	//ShootList.SetActiveChild(_NOTCH, 0.0989625f);
	//UpperStateList.SetActiveChild(_SHOOT, 0.0f);
	//UpperShootList.SetActiveChild(_NOTCH, 0.0989625f);
	UpperShootIndex = _NOTCH;
}

reliable client function ClientNotchArrow()
{
	//StateList.SetActiveChild(_SHOOT, 0.0f);
	//ShootList.SetActiveChild(_NOTCH, 0.0989625f);
	UpperStateList.SetActiveChild(_SHOOT, 0.0f);
	UpperShootList.SetActiveChild(_NOTCH, 0.0989625f);
}

simulated function ArcherDrawArrow()
{
	//PlayAnim('CustomAnim', 'Archer_Hands_Draw', 1.0f, 0.0f, 0.0f, false, true);
	//PlayAnimTP_Upper('CustomAnimTP', 'Archer_Upper_Draw', 1.0f, 0.0f, 0.0f, false, true);
	//StateList.SetActiveChild(_SHOOT, 0.0f);
	ShootList.SetActiveChild(_DRAW, 0.0f);
	//UpperStateList.SetActiveChild(_SHOOT, 0.0f);
	UpperShootList.SetActiveChild(_DRAW, 0.0f);	
	ServerDrawArrow();
	//PlayAnimDynamic(HLW_Ranged_Bow(Weapon).BowAnimation, 'Bow_Draw', 1.0f, 0.0f, 0.0f, false, true);
}

reliable server function ServerDrawArrow()
{
	//StateList.SetActiveChild(_SHOOT, 0.0f);
	//ShootList.SetActiveChild(_DRAW, 0.0f);
	//UpperStateList.SetActiveChild(_SHOOT, 0.0f);
	//UpperShootList.SetActiveChild(_DRAW, 0.0f);	
	UpperShootIndex = _DRAW;
}

reliable client function ClientDrawArrow()
{
	//StateList.SetActiveChild(_SHOOT, 0.0f);
	//ShootList.SetActiveChild(_DRAW, 0.0f);
	//UpperStateList.SetActiveChild(_SHOOT, 0.0f);
	UpperShootList.SetActiveChild(_DRAW, 0.0f);	
}

simulated function ArcherDrawIdle()
{
	//PlayAnim('CustomAnim', 'Archer_Hands_Idle_Drawn', 1.0f, 0.0f, 0.0f, true, true);
	//PlayAnimTP_Upper('CustomAnimTP', 'Archer_Upper_Draw_Idle', 1.0f, 0.0f, 0.0f, true, true);
	//StateList.SetActiveChild(_SHOOT, 0.0f);
	ShootList.SetActiveChild(_HOLD, 0.0f);
	//UpperStateList.SetActiveChild(_SHOOT, 0.0f);
	UpperShootList.SetActiveChild(_HOLD, 0.0f);
	
	ServerDrawIdle();
}

reliable server function ServerDrawIdle()
{
	//StateList.SetActiveChild(_SHOOT, 0.0f);
	//ShootList.SetActiveChild(_HOLD, 0.0f);
	//UpperStateList.SetActiveChild(_SHOOT, 0.0f);
	//UpperShootList.SetActiveChild(_HOLD, 0.0f);
	UpperShootIndex = _HOLD;
}

reliable client function ClientDrawIdle()
{
	//StateList.SetActiveChild(_SHOOT, 0.0f);
	//ShootList.SetActiveChild(_HOLD, 0.0f);
	//UpperStateList.SetActiveChild(_SHOOT, 0.0f);
	UpperShootList.SetActiveChild(_HOLD, 0.0f);
}

simulated function ArcherReleaseArrow()
{
	//No Release Animations Yet
	//CustomAnimTP_Upper.StopCustomAnim(0.0f);
	//CustomAnimTP_Lower.StopCustomAnim(0.0f);
	//PlayCustomAnim("FP", 'Archer_Hands_Fire', 0.3750f);
	//StateList.SetActiveChild(_SHOOT, 0.0f);
	ShootList.SetActiveChild(_RELEASE, 0.0f);
	StateList.SetActiveChild(_NORMAL, 0.25f);
	//UpperStateList.SetActiveChild(_SHOOT, 0.0f);
	UpperShootList.SetActiveChild(_RELEASE, 0.0f);	
	UpperStateList.SetActiveChild(_NORMAL, 0.25f);

	if(Role < ROLE_Authority)
	{
		ServerReleaseArrow();
	}
}

reliable server function ServerReleaseArrow()
{
	//ArcherReleaseArrow();
	UpperShootIndex = _RELEASE;
}

reliable client function ClientReleaseArrow()
{
	//StateList.SetActiveChild(_SHOOT, 0.0f);
	//ShootList.SetActiveChild(_RELEASE, 0.0f);
	//StateList.SetActiveChild(_NORMAL, 0.25f);
	//UpperStateList.SetActiveChild(_SHOOT, 0.0f);
	UpperShootList.SetActiveChild(_RELEASE, 0.0f);	
	UpperStateList.SetActiveChild(_NORMAL, 0.25f);
}


/**********Animation Script Notifies**********/

//Call At End Of Notch Animation
simulated function SetNotchEnd()
{
	//`log("who?2");
	if(HLW_Ranged_Bow(Weapon) != None)
	{
		HLW_Ranged_Bow(Weapon).SetNotchEnd();
	}
	
	if(Role < ROLE_Authority)
	{
		ServerSetNotchEnd();	
	}
}
reliable server function ServerSetNotchEnd()
{
	//SetNotchEnd();
}

//Call At End Of Draw Animation
simulated function SetDrawEnd()
{
	if(HLW_Ranged_Bow(Weapon) != None)
	{
		HLW_Ranged_Bow(Weapon).SetDrawEnd();
	}
}

simulated function PlayBowSound(SoundCue NewSound)
{
	BowSound = NewSound;
	BowAudioComponent.Stop();
	BowAudioComponent.SoundCue = BowSound;
	
	if(NewSound != None)
	{
		BowAudioComponent.Play();
		SetTimer(BowAudioComponent.SoundCue.Duration, false, 'ResetBowSound');
	}	
}

simulated function ResetBowSound()
{
	BowSound=None;
	PlayBowSound(BowSound);	
}

defaultproperties
{
	VoiceCueHurt=SoundCue'HLW_Package_Voices.Archer.Hurt'
	VoiceCueLevelUp=SoundCue'HLW_Package_Voices.Archer.LevelUp'
	VoiceCueDied=SoundCue'HLW_Package_Voices.Archer.Died'
	VoiceCueKill=SoundCue'HLW_Package_Voices.Archer.KilledPlayer'
	
	Begin Object Name=ArmsMesh
		SkeletalMesh=SkeletalMesh'HLW_Package_Dan.models.Archer1stPerson'
		AnimSets(0)=AnimSet'HLW_Package_Randolph.Animations.1p_archer_animset'
		AnimTreeTemplate=AnimTree'HLW_Package_Randolph.Animations.Archer_AnimTree_1P'//AnimTree'HLW_Package_Randolph.Animations.1p_arms_archer_animtree'
		Translation=(X=-5.0, Y=0.0, Z=-30.0)
	End Object
	
	Begin Object Name=ThirdPersonMesh
		bHasPhysicsAssetInstance=true
		AnimSets(0)=AnimSet'HLW_CONNOR_PAKAGE.Animations.3p_Archer_Animset'//AnimSet'HLW_Package_Randolph.Animations.3p_Archer_Animset'
		AnimTreeTemplate=AnimTree'HLW_Package_Randolph.Animations.Archer_AnimTree_3P'//AnimTree'HLW_Package_Randolph.Animations.3p_Archer_Animtree'
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.NewArcher'//SkeletalMesh'HLW_Package_Dan.models.3p_Archer_Temp_buck'
		PhysicsAsset=PhysicsAsset'HLW_CONNOR_PAKAGE.Physics.3p_Archer_Temp_Skele_Physics'
	End Object
	
	Begin Object Class=AudioComponent Name=BowComponent
		bUseOwnerLocation=true
	End Object
	BowAudioComponent=BowComponent
	Components.Add(BowComponent)
	
	BowSocket=Archer_Bow_socket; 
	BowSocketTP=Archer_Bow_Socket_TP; 
	StringSocket=Archer_String_Socket
	BowStringSocket=Bow_String_Socket
	FartSocket=Fart_Socket
	
	TrapIndex=HLW_POISON
	
	UpperStateIndex=255
	LowerStateIndex=255
	UpperShootIndex=255
	LowerShootIndex=255
	
	GroundSpeed=410
	
	BasePhysicalPower=50.0
	BaseMagicalPower=0.0
	BasePhysicalDefense=0.0
	BaseMagicalDefense=0.0
	BaseCooldownReduction=0.0
	BaseMovementSpeed=350
	BaseAttackSpeed=1.0
	BaseHealth=250
	BaseHealthMax=250
	BaseMana=225
	BaseManaMax=225
	BaseHP5=6.50
	BaseMP5=11.75
	BaseResistance=0.0

	ManaIncreaseOnLevelPercentage=0.24
	HealthIncreaseOnLevelPercentage=0.25
	PhysicalPowerIncreaseOnLevelPercentage=0.35
	MagicalPowerIncreaseOnLevelPercentage=0.0
	HP5IncreaseOnLevelPercentage=0.24
	MP5IncreaseOnLevelPercentage=0.23
	
	HeadBone=Character1_Head
	
	AbilityClasses(0)=class'HLW_Ability_HeadShot' // PASSIVE
	AbilityClasses(1)=class'HLW_Ability_Volley' // 1
	AbilityClasses(2)=class'HLW_Ability_Cloak' // 2
	AbilityClasses(3)=class'HLW_Ability_Trap' // 3
	AbilityClasses(4)=class'HLW_Ability_Barrage' // 4 (Ultimate)
	
	CurrentTeamColor=(R=0,G=0,B=0,A=0)
}
