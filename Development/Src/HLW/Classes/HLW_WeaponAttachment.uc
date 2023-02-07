class HLW_WeaponAttachment extends Actor
abstract;

//Weapon SkeletalMesh
var SkeletalMeshComponent Mesh;

//var HLW_Pawn Owner;
var MaterialInstanceConstant MatInst;

//Abstract
//Client Called - Attach Weapon to Player Mesh
simulated function AttachTo(HLW_Pawn_Class OwnerPawn)
{
}

//Abstract
//Detach Weapon (When Not Using Weapon/Weapon Destroyed)
simulated function DetachFrom(SkeletalMeshComponent MeshComponent)
{
}

defaultproperties
{
	//Weapon SkeletalMesh
	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
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
	End Object
	Mesh=SkeletalMeshComponent0
}