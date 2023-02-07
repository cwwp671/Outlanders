class HLW_TrainingDummy_Warrior extends HLW_TrainingDummy
ClassGroup(HeroLineWars)
placeable;

var SkeletalMeshComponent Sword;
var SkeletalMeshComponent Shield;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Mesh.AttachComponentToSocket(Sword, 'Warrior_Hand_Right_TP');
	Mesh.AttachComponentToSocket(Shield, 'Warrior_Shield_Socket');	
}

defaultproperties
{
	Health=400
	HealthMax=400
	
	VoiceCueDied=SoundCue'HLW_Package_Voices.Warrior.Died'
	VoiceCueHurt=SoundCue'HLW_Package_Randolph.Sounds.Warrior_Hurt'
	
	Begin Object Name=DummyMesh
        bHasPhysicsAssetInstance=true
        PhysicsAsset=PhysicsAsset'HLW_Package.Physics.3p_Warrior_Physics'
		AnimSets(0)=AnimSet'HLW_Package_Randolph.Animations.3p_Warrior_Animset_HatchIsJerk'
		AnimTreeTemplate=AnimTree'HLW_Package_Randolph.Animations.Warrior_AnimTree_3P'
        SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Warrior_New_3' 
    End Object
    
    Begin Object Class=SkeletalMeshComponent Name=SwordMesh
		bAcceptsDynamicDecals=true
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
		Rotation=(Roll=50973, Pitch=16384, Yaw=16384)
		Translation=(X=-3.0, Y=2.5, Z=-1.0)
		Scale=1.25
		Materials(0)=Material'HLW_mapProps.Materials.SwordMatMaster'
		SkeletalMesh=SkeletalMesh'HLW_Package.Models.Longsword'
	End Object
	Sword=SwordMesh
	
	Begin Object Class=SkeletalMeshComponent Name=ShieldMesh
		bAcceptsDynamicDecals=true
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
		Scale=1.25
		Materials(0)=Material'HLW_mapProps.Materials.SheildMainMaster'
		Materials(1)=Material'HLW_mapProps.Materials.SheildMainMaster'
		SkeletalMesh=SkeletalMesh'HLW_Package.Models.Warrior_Shield'
	End Object
	Shield=ShieldMesh
}