/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Pawn_Class_Barbarian extends HLW_Pawn_Class;

enum AnimStateList
{
	NORMAL,
	MELEE,
	BLOCKING,
	HAMMERTOSS,
	GROUNDSLAM,
	BASEBALLSWING,
	RALLY	
};

enum BarbarianAnimNodesTP
{
	UPPERSTATE,
	LOWERSTATE,
	UPPERMELEE,
	LOWERMELEE,
	UPPERBLOCKING,
	LOWERBLOCKING,
	UPPERHAMMERTOSS,
	LOWERHAMMERTOSS,
	UPPERGROUNDSLAM,
	LOWERGROUNDSLAM,
	UPPERBASEBALLSWING,
	LOWERBASEBALLSWING,
	UPPERRALLY,
	LOWERRALLY
};

enum AnimMeleeList
{
	ATTACK1,
	ATTACK1IDLE,
	ATTACK2,
	ATTACK2IDLE,
	ATTACK3,
	ATTACK3IDLE,
	ATTACK4
};

enum AnimBlockList
{
	PREBLOCK,
	BLOCKIDLE,
	BLOCKEND
};

enum AnimHammerTossList
{
	PRETOSS,
	TOSSIDLE,
	TOSSEND
};

enum AnimBaseballSwingList
{
	PRESWING,
	SWING
};



var Name HammerSocketFP;
var Name HammerSocketTP;

var SkeletalMeshComponent WeaponTP;

var UDKAnimBlendBase MeleeList;
var UDKAnimBlendBase BlockingList;
var UDKAnimBlendBase HammerTossList;
var UDKAnimBlendBase BaseballSwingList;

var UDKAnimBlendBase UpperMeleeList;
var UDKAnimBlendBase LowerMeleeList;
var UDKAnimBlendBase UpperHammerTossList;
var UDKAnimBlendBase UpperBaseballSwingList;

var repnotify byte UpperMeleeIndex;
var repnotify byte LowerMeleeIndex;
var repnotify byte UpperBlockingIndex;
var repnotify byte LowerBlockingIndex;
var repnotify byte UpperHammerTossIndex;
var repnotify byte UpperBaseballSwingIndex;

replication
{
	if(bNetDirty && !bNetOwner)
		UpperMeleeIndex,
		LowerMeleeIndex,
		UpperBlockingIndex,
		LowerBlockingIndex,
		UpperHammerTossIndex,
		UpperBaseballSwingIndex;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_Package_Lukas.Materials.Lambert_Param'); 
	
	Mesh.SetMaterial(0, MatInst);
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_mapProps.Materials.HammerMat'); 
	
	WeaponTP.SetMaterial(0, MatInst);
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(MaterialInstanceConstant'HLW_mapProps.Materials.Polished_Silver'); 
	
	ThirdPerson.SetMaterial(0, MatInst);
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_mapProps.Materials.TempHair'); 
	
	ThirdPerson.SetMaterial(1, MatInst);
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_mapProps.Materials.skinColor_Mat'); 
	
	ThirdPerson.SetMaterial(2, MatInst);
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_mapProps.Materials.SkullMat'); 
	
	ThirdPerson.SetMaterial(3, MatInst);
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_mapProps.Materials.BodyArmorMat'); 
	
	ThirdPerson.SetMaterial(4, MatInst);
	AttachWeapons();
	AttachComponent(ThirdPerson);
}

simulated function Destroyed()
{
	super.Destroyed();
	
	MeleeList = None;
	BlockingList = None;
	HammerTossList = None;
	BaseballSwingList = None;	
	UpperMeleeList = None;
	LowerMeleeList = None;
	UpperHammerTossList = None;
	UpperBaseballSwingList = None;
}

simulated function ReplicatedEvent(Name VarName)
{
	if(VarName == 'UpperStateIndex')
	{
		switch(UpperStateIndex)
		{
			case NORMAL:
				ClientSetAnimState(UPPERSTATE, NORMAL);
				break;
			case MELEE:
				ClientSetAnimState(UPPERSTATE, MELEE);
				break;
			case BLOCKING:
				ClientSetAnimState(UPPERSTATE, BLOCKING);
				break;
			case HAMMERTOSS:
				ClientSetAnimState(UPPERSTATE, HAMMERTOSS);
				break;
			case GROUNDSLAM:
				ClientSetAnimState(UPPERSTATE, GROUNDSLAM);
				break;
			case BASEBALLSWING:
				ClientSetAnimState(UPPERSTATE, BASEBALLSWING);
				break;
			case RALLY:
				ClientSetAnimState(UPPERSTATE, RALLY);
				break;
		}
		
		return;
	}
	else if(VarName == 'LowerStateIndex')
	{
		switch(LowerStateIndex)
		{
			case NORMAL:
				ClientSetAnimState(LOWERSTATE, NORMAL);
				break;
			case MELEE:
				ClientSetAnimState(LOWERSTATE, MELEE);
				break;
			case BLOCKING:
				ClientSetAnimState(LOWERSTATE, BLOCKING);
				break;
			case HAMMERTOSS:
				ClientSetAnimState(LOWERSTATE, HAMMERTOSS);
				break;
			case GROUNDSLAM:
				ClientSetAnimState(LOWERSTATE, GROUNDSLAM);
				break;
			case BASEBALLSWING:
				ClientSetAnimState(LOWERSTATE, BASEBALLSWING);
				break;
			case RALLY:
				ClientSetAnimState(LOWERSTATE, RALLY);
				break;
		}
		
		return;
	}
	else if(VarName == 'UpperMeleeIndex')
	{
		switch(UpperMeleeIndex)
		{
			case ATTACK1:
				ClientSetAnimState(UPPERMELEE, ATTACK1);
				break;
			case ATTACK1IDLE:
				ClientSetAnimState(UPPERMELEE, ATTACK1IDLE);
				break;
			case ATTACK2:
				ClientSetAnimState(UPPERMELEE, ATTACK2);
				break;
			case ATTACK2IDLE:
				ClientSetAnimState(UPPERMELEE, ATTACK2IDLE);
				break;
			case ATTACK3:
				ClientSetAnimState(UPPERMELEE, ATTACK3);
				break;
			case ATTACK3IDLE:
				ClientSetAnimState(UPPERMELEE, ATTACK3IDLE);
				break;
			case ATTACK4:
				ClientSetAnimState(UPPERMELEE, ATTACK4);
				break;
		}
		
		return;
	}
	else if(VarName == 'LowerMeleeIndex')
	{
		switch(LowerMeleeIndex)
		{
			case ATTACK1:
				ClientSetAnimState(LOWERMELEE, ATTACK1);
				break;
			case ATTACK1IDLE:
				ClientSetAnimState(LOWERMELEE, ATTACK1IDLE);
				break;
			case ATTACK2:
				ClientSetAnimState(LOWERMELEE, ATTACK2);
				break;
			case ATTACK2IDLE:
				ClientSetAnimState(LOWERMELEE, ATTACK2IDLE);
				break;
			case ATTACK3:
				ClientSetAnimState(LOWERMELEE, ATTACK3);
				break;
			case ATTACK3IDLE:
				ClientSetAnimState(LOWERMELEE, ATTACK3IDLE);
				break;
			case ATTACK4:
				ClientSetAnimState(LOWERMELEE, ATTACK4);
				break;
		}
		
		return;
	}
	else if(VarName == 'UpperBlockingIndex')
	{
		switch(UpperBlockingIndex)
		{
			case PREBLOCK:
				ClientSetAnimState(UPPERBLOCKING, PREBLOCK);
				break;
			case BLOCKIDLE:
				ClientSetAnimState(UPPERBLOCKING, BLOCKIDLE);
				break;
			case BLOCKEND:
				ClientSetAnimState(UPPERBLOCKING, BLOCKEND);
				break;
		}
		
		return;
	}
	else if(VarName == 'LowerBlockingIndex')
	{
		switch(LowerBlockingIndex)
		{
			case PREBLOCK:
				ClientSetAnimState(LOWERBLOCKING, PREBLOCK);
				break;
			case BLOCKIDLE:
				ClientSetAnimState(LOWERBLOCKING, BLOCKIDLE);
				break;
			case BLOCKEND:
				ClientSetAnimState(LOWERBLOCKING, BLOCKEND);
				break;
		}
		
		return;
	}
	else if(VarName == 'UpperHammerTossIndex')
	{
		switch(UpperHammerTossIndex)
		{
			case PRETOSS:
				ClientSetAnimState(UPPERHAMMERTOSS, PRETOSS);
				break;
			case TOSSIDLE:
				ClientSetAnimState(UPPERHAMMERTOSS, TOSSIDLE);
				break;
			case TOSSEND:
				ClientSetAnimState(UPPERHAMMERTOSS, TOSSEND);
				break;
		}
		
		return;
	}
	else if(VarName == 'UpperBaseballSwingIndex')
	{
		switch(UpperBaseballSwingIndex)
		{
			case PRESWING:
				ClientSetAnimState(UPPERBASEBALLSWING, PRESWING);
				break;
			case SWING:
				ClientSetAnimState(UPPERBASEBALLSWING, SWING);
				break;
		}
		
		return;
	}
	
	super.ReplicatedEvent(VarName);
}

simulated function PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	
	if(SkelComp == Mesh)
	{
		StateList = UDKAnimBlendBase(Mesh.FindAnimNode('StateList'));
		MeleeList = UDKAnimBlendBase(Mesh.FindAnimNode('MeleeList'));
		BlockingList = UDKAnimBlendBase(Mesh.FindAnimNode('BlockingList'));
		HammerTossList = UDKAnimBlendBase(Mesh.FindAnimNode('HammerTossList'));
		BaseballSwingList = UDKAnimBlendBase(Mesh.FindAnimNode('BaseballSwingList'));
	}
	
	if(SkelComp == ThirdPerson)
	{
		UpperStateList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('UpperStateList'));
		LowerStateList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('LowerStateList'));
		UpperMeleeList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('UpperMeleeList'));
		LowerMeleeList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('LowerMeleeList'));
		UpperHammerTossList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('UpperHammerTossList'));
		UpperBaseballSwingList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('UpperBaseballSwingList'));
	}	
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
		case UPPERMELEE:
			UpperMeleeList.SetActiveChild(AnimState, BlendIn);
			MeleeList.SetActiveChild(AnimState, BlendIn);
			break;
		case LOWERMELEE:
			LowerMeleeList.SetActiveChild(AnimState, BlendIn);
			break;
		case UPPERBLOCKING:
			break;
		case LOWERBLOCKING:
			break;
		case UPPERHAMMERTOSS:
			UpperHammerTossList.SetActiveChild(AnimState, BlendIn);
			HammerTossList.SetActiveChild(AnimState, BlendIn);
			break;
		case UPPERBASEBALLSWING:
			UpperBaseballSwingList.SetActiveChild(AnimState, BlendIn);
			BaseballSwingList.SetActiveChild(AnimState, BlendIn);
			break;
	}	
	
	if(Role < ROLE_Authority)
	{
		ServerSetAnimState(AnimNode, AnimState);
	}
}

reliable client function ClientSetAnimState(byte AnimNode, byte AnimState)
{
	switch(AnimNode)
	{
		case UPPERMELEE:
			UpperMeleeList.SetActiveChild(AnimState, 0.0f);
			MeleeList.SetActiveChild(AnimState, 0.0f);
			return;
		case LOWERMELEE:
			LowerMeleeList.SetActiveChild(AnimState, 0.0f);
			return;
		case UPPERBLOCKING:
			//UpperBlockingList.SetActiveChild(AnimState, 0.0f);
			//BlockingList.SetActiveChild(AnimState, 0.0f);
			return;
		case LOWERBLOCKING:
			//LowerBlockingList.SetActiveChild(AnimState, 0.0f);
			return;
		case UPPERHAMMERTOSS:
			UpperHammerTossList.SetActiveChild(AnimState, 0.0f);
			HammerTossList.SetActiveChild(AnimState, 0.0f);
			return;
		case UPPERBASEBALLSWING:
			UpperBaseballSwingList.SetActiveChild(AnimState, 0.0f);
			BaseballSwingList.SetActiveChild(AnimState, 0.0f);
			return;
	}
	
	super.ClientSetAnimState(AnimNode, AnimState);
}

reliable server function ServerSetAnimState(byte AnimNode, byte AnimState)
{
	switch(AnimNode)
	{
		case UPPERMELEE:
			UpperMeleeIndex = AnimState;
			return;
		case LOWERMELEE:
			LowerMeleeIndex = AnimState;
			return;
		case UPPERBLOCKING:
			UpperBlockingIndex = AnimState;
			return;
		case LOWERBLOCKING:
			LowerBlockingIndex = AnimState;
			return;
		case UPPERHAMMERTOSS:
			UpperHammerTossIndex = AnimState;
			return;
		case UPPERBASEBALLSWING:
			UpperBaseballSwingIndex = AnimState;
			return;
	}
	
	super.ServerSetAnimState(AnimNode, AnimState);
}

simulated function PlayerInitialized()
{
	super.PlayerInitialized();
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(1, "Hmr Toss", 4);
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(2, "Grnd Slm", 4);
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(3, "Hd Smsh", 4);
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(4, "Rally", 4);
}

simulated function AttachWeapons()
{
	//MatInst = new(None) Class'MaterialInstanceConstant';
	//MatInst.SetParent(Material'HLW_mapProps.Materials.SwordMatMaster');
	//WeaponTP.SetMaterial(0, MatInst);

	ThirdPerson.AttachComponentToSocket(WeaponTP, HammerSocketTP);
}

simulated function StartBlock();

reliable client function ClientSetTeamColor(LinearColor NewTeamColor)
{
	super.ClientSetTeamColor(NewTeamColor);
	
	//ClientSetMaterialVector(ThirdPerson, 0, 'TeamColor', NewTeamColor);
	//ClientSetMaterialVector(ThirdPerson, 1, 'TeamColor', NewTeamColor);
	//ClientSetMaterialVector(ThirdPerson, 2, 'TeamColor', NewTeamColor);
	ClientSetMaterialVector(ThirdPerson, 3, 'TeamColor', NewTeamColor);
	ClientSetMaterialVector(ThirdPerson, 4, 'TeamColor', NewTeamColor);
    ClientSetMaterialVector(Mesh, 0, 'TeamColor', NewTeamColor);
    ClientSetMaterialVector(WeaponTP, 0, 'TeamColor', NewTeamColor);
}

simulated function AddDefaultInventory()
{
	super.AddDefaultInventory();
	
	InvManager.CreateInventory(class'HLW_Melee_Hammer');
}

defaultproperties
{	
	BasePhysicalPower=45.0
	BaseMagicalPower=0.0
	
	BasePhysicalDefense=0.0
	BaseMagicalDefense=0.0
	
	BaseCooldownReduction=0.0
	BaseMovementSpeed=350
	BaseAttackSpeed=1.0
	BaseHealth=350
	BaseHealthMax=350
	
	BaseMana=200
	BaseManaMax=200
	
	BaseHP5=6.0
	BaseMP5=10.75
	BaseResistance=0.0

	ManaIncreaseOnLevelPercentage=0.22
	HealthIncreaseOnLevelPercentage=0.22
	PhysicalPowerIncreaseOnLevelPercentage=0.37
	MagicalPowerIncreaseOnLevelPercentage=0.0
	HP5IncreaseOnLevelPercentage=0.21
	MP5IncreaseOnLevelPercentage=0.21

	AbilityClasses(0)=class'HLW_Ability_Aura' // PASSIVE
	AbilityClasses(1)=class'HLW_Ability_HammerToss' // 1
	AbilityClasses(2)=class'HLW_Ability_GroundSlam' // 2
	AbilityClasses(3)=class'HLW_Ability_BaseballSwing' // 3
	AbilityClasses(4)=class'HLW_Ability_Rally' // 4 (Ultimate)
	
	HammerSocketFP=Barbarian_Hammer_Socket
	HammerSocketTP=Barbarian_Hammer_Socket
	HeadBone=Character1_Head
	CurrentTeamColor=(R=0,G=0,B=0,A=0)
	
	Begin Object Name=ArmsMesh
		SkeletalMesh=SkeletalMesh'HLW_Package_Dan.models.barbarian1stPersonArmsRigged'
		AnimSets(0)=AnimSet'HLW_Package_Randolph.Animations.Barbarian_AnimSet_1P'
		AnimTreeTemplate=AnimTree'HLW_Package_Randolph.Animations.Barbarian_AnimTree_1P'
		Translation=(X=-5.0,Y=0.0,Z=-30.0)
	End Object
	
	Begin Object Name=ThirdPersonMesh
		bHasPhysicsAssetInstance=true
		AnimSets(0)=AnimSet'HLW_Package_Randolph.Animations.Barbarian_AnimSet_3P'
		AnimTreeTemplate=AnimTree'HLW_Package_Randolph.Animations.Barbarian_AnimTree_3P'
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Barbarian_3P'
		PhysicsAsset=PhysicsAsset'HLW_CONNOR_PAKAGE.Physics.Barbarian_Physics'//PhysicsAsset'HLW_Package_Randolph.Physics.Barbarian_Physics_3P'
	End Object
	
	Begin Object Class=SkeletalMeshComponent Name=SM_TP
		bAcceptsDynamicDecals=true //Future Blood Decals?
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bCacheAnimSequenceNodes=false
		bCastDynamicShadow=true
		bCastHiddenShadow=true
		CastShadow=true
		bChartDistanceFactor=true
		bIgnoreControllersWhenNotRendered=false
		bOnlyOwnerSee=false
		bOverrideAttachmentOwnerVisibility=true
		bPerBoneMotionBlur=true
		bUseOnePassLightingOnTranslucency=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		RBDominanceGroup=20
		MinDistFactorForKinematicUpdate=0.2f
		//Rotation=(Roll=401, Pitch=-2176, Yaw=-28)
		//Translation=(X=-0.307869, Y=0.991734, Z=-25.315689)
		//Scale=1.25
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Hammer'
	End Object
	WeaponTP=SM_TP

	VoiceCueDied=SoundCue'HLW_Package_Voices.Barbarian.Died'
	VoiceCueLevelUp=SoundCue'HLW_Package_Voices.Barbarian.LevelUp'
	VoiceCueHurt=SoundCue'HLW_Package_Voices.Barbarian.Hurt'
	VoiceCueKill=SoundCue'HLW_Package_Voices.Barbarian.KilledPlayer'
}