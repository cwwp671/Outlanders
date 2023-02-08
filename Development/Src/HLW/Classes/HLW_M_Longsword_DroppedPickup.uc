/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_M_Longsword_DroppedPickup extends HLW_Melee_DroppedPickup;

var SkeletalMeshComponent ShieldMesh;

function AttachShield()
{
	
}

defaultproperties
{
	bOrientOnSlope=false
	
	Begin Object Name=CollisionCylinder
		CollisionRadius=+00002.000000
		CollisionHeight=+00010.000000
		CollideActors=false
	End Object
	
	Begin Object Name=WeaponSkeletalMesh
		bHasPhysicsAssetInstance=true
		Scale=1.25
		SkeletalMesh=SkeletalMesh'HLW_CONNOR_PAKAGE.Physics.Longsword_Deco_Skele'
		PhysicsAsset=PhysicsAsset'HLW_CONNOR_PAKAGE.Physics.Longsword_Deco_Skele_Physics'
	End Object
	
	//Shield SkeletalMesh
	Begin Object Class=SkeletalMeshComponent Name=ShieldSkeletalMesh
		bHasPhysicsAssetInstance=true
		bOwnerNoSee=false
		bOnlyOwnerSee=false
		CollideActors=true
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		MaxDrawDistance=4000
		bForceRefPose=1
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=false
		CastShadow=true
		bCastDynamicShadow=true
		bPerBoneMotionBlur=true
		Scale=1.25
		SkeletalMesh=SkeletalMesh'HLW_CONNOR_PAKAGE.Physics.Warrior_Shield_Skele'
		PhysicsAsset=PhysicsAsset'HLW_CONNOR_PAKAGE.Physics.Warrior_Shield_Skele_Physics'
	End Object
	ShieldMesh=ShieldSkeletalMesh
}