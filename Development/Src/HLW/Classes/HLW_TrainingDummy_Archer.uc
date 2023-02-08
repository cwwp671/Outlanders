/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_TrainingDummy_Archer extends HLW_TrainingDummy
ClassGroup(HeroLineWars)
placeable;

var SkeletalMeshComponent Bow;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Mesh.AttachComponentToSocket(Bow, 'Archer_Bow_Socket_TP');
}

defaultproperties
{
	Health=250
	HealthMax=250
	
	VoiceCueHurt=SoundCue'HLW_Package_Voices.Archer.Hurt'
	VoiceCueDied=SoundCue'HLW_Package_Voices.Archer.Died'
	
	Begin Object Name=DummyMesh
        bHasPhysicsAssetInstance=true
        PhysicsAsset=PhysicsAsset'HLW_CONNOR_PAKAGE.Physics.3p_Archer_Temp_Skele_Physics' 
		AnimSets(0)=AnimSet'HLW_CONNOR_PAKAGE.Animations.3p_Archer_Animset'
		AnimTreeTemplate=AnimTree'HLW_Package_Randolph.Animations.Archer_AnimTree_3P'
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.NewArcher'
    End Object
    
    Begin Object Class=SkeletalMeshComponent Name=BowMesh
		bOwnerNoSee=true
		bOnlyOwnerSee=false
		CollideActors=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		MaxDrawDistance=4000
		bForceRefPose=1
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		CastShadow=true
		bCastDynamicShadow=true
		bPerBoneMotionBlur=true
		bCastHiddenShadow=true
		Translation=(X=0.92284, Y=2.380053, Z=1.392819)
		Rotation=(Roll=-2334, Pitch=9830, Yaw=-24944)
		Scale=0.35
		Materials(0)=Material'HLW_mapProps.Materials.BowMat'
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Dat_Bow'
	End Object
	Bow=BowMesh
}