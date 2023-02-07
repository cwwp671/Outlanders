class HLW_Melee_DroppedPickup extends HLW_DroppedPickup;

var SkeletalMeshComponent WeaponMesh;

auto state Pickup
{
       event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
       {
              // We ignore the Touch event to prevent anything from picking us up
       }
}

defaultproperties
{
	//Weapon SkeletalMesh
	Begin Object Class=SkeletalMeshComponent Name=WeaponSkeletalMesh
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
		bAcceptsDynamicDecals=FALSE
		CastShadow=true
		bCastDynamicShadow=true
		bPerBoneMotionBlur=true
	End Object
	WeaponMesh=WeaponSkeletalMesh
}