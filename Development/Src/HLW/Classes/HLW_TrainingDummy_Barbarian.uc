/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_TrainingDummy_Barbarian extends HLW_TrainingDummy
ClassGroup(HeroLineWars)
placeable;

var SkeletalMeshComponent Hammer;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Mesh.AttachComponentToSocket(Hammer, 'Barbarian_Hammer_Socket');	
}

defaultproperties
{
	Health=350
	HealthMax=350
	
	VoiceCueDied=SoundCue'HLW_Package_Voices.Barbarian.Died'
	VoiceCueHurt=SoundCue'HLW_Package_Voices.Barbarian.Hurt'
	
	Begin Object Name=DummyMesh
        bHasPhysicsAssetInstance=true
        PhysicsAsset=PhysicsAsset'HLW_CONNOR_PAKAGE.Physics.Barbarian_Physics'
		AnimSets(0)=AnimSet'HLW_Package_Randolph.Animations.Barbarian_AnimSet_3P'
		AnimTreeTemplate=AnimTree'HLW_Package_Randolph.Animations.Barbarian_AnimTree_3P'
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Barbarian_3P'	
    End Object
    
    Begin Object Class=SkeletalMeshComponent Name=HammerMesh
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
		//Rotation=(Roll=401, Pitch=-2176, Yaw=-28)
		//Translation=(X=-0.307869, Y=0.991734, Z=-25.315689)
		//Scale=1.25
		Materials(0)=Material'HLW_mapProps.Materials.HammerMat'
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Hammer'
	End Object
	Hammer=HammerMesh
}