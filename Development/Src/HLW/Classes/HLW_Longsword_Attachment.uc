/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Longsword_Attachment extends HLW_WeaponAttachment;

var SkeletalMeshComponent ShieldMesh;

//Client Called - Attach Weapon to Player Mesh
simulated function AttachTo(HLW_Pawn_Class OwnerPawn)
{
	local rotator SwordRotation;
	local vector SwordPosition;
	local MaterialInstanceConstant SwordMatInst, ShieldMatInst;
		
	//local rotator ShieldRotation;
	//local vector ShieldPosition;
	
	if (OwnerPawn.Mesh != None)
	{
		if (Mesh != None)
		{
			//Set Sword and Shield Shadow Parent to Pawn
			Mesh.SetShadowParent(OwnerPawn.ThirdPerson);
			ShieldMesh.SetShadowParent(OwnerPawn.ThirdPerson);
			
			//Rotate Sword Correctly
			//SwordRotation.Pitch = 0;
			//SwordRotation.Yaw = 16384 * 3;
			//SwordRotation.Roll = 16384;
			SwordRotation.Roll = 50973;
			SwordRotation.Pitch = 16384;
			SwordRotation.Yaw = 16384;
			
			Mesh.SetRotation(SwordRotation);
			
			//Translate Sword Correctly
			SwordPosition = Mesh.Translation;
			//SwordPosition.X -= 1.0;
			SwordPosition.X += -3.0f;
			SwordPosition.Y += 2.5f;
			SwordPosition.Z += -1.0f;
			Mesh.SetTranslation(SwordPosition);
			Mesh.SetScale(1.25f);
			
			//ShieldRotation.Roll = 0;
			//ShieldRotation.Pitch = 16384 * 3;
			//ShieldRotation.Yaw = 0;
			//ShieldMesh.SetRotation(ShieldRotation);
			//
			//ShieldPosition = ShieldMesh.Translation;
			////SwordPosition.X -= 1.0;
			//ShieldPosition.X += -5.0f;
			//ShieldPosition.Y += -8.0f;
			//ShieldPosition.Z += -2.0f;
			//ShieldMesh.SetTranslation(ShieldPosition);
			ShieldMesh.SetScale(1.25f);
			
			SwordMatInst = new(None) Class'MaterialInstanceConstant';
			ShieldMatInst = new(None) Class'MaterialInstanceConstant';
		
			SwordMatInst.SetParent(Material'HLW_mapProps.Materials.SwordMatMaster');
			ShieldMatInst.SetParent(Material'HLW_mapProps.Materials.SheildMainMaster');
		
			if(HLW_Pawn_Class_Warrior(Owner) != None)
			{
				SwordMatInst.SetVectorParameterValue('TeamColor', HLW_Pawn_Class_Warrior(OwnerPawn).CurrentTeamColor); //TODO:Switch back to PawnClass when fixed
				ShieldMatInst.SetVectorParameterValue('TeamColor', HLW_Pawn_Class_Warrior(OwnerPawn).CurrentTeamColor); //TODO:Switch back to PawnClass when fixed
			}
			
			Mesh.SetMaterial(0, SwordMatInst);
			ShieldMesh.SetMaterial(0, ShieldMatInst);
			
			OwnerPawn.ThirdPerson.AttachComponentToSocket(Mesh, HLW_Pawn_Class_Warrior(OwnerPawn).SwordSocketTP);
			OwnerPawn.ThirdPerson.AttachComponentToSocket(ShieldMesh, HLW_Pawn_Class_Warrior(OwnerPawn).ShieldSocketTP);
		}
	}
}

//Detach Weapon (When Not Using Weapon/Weapon Destroyed)
simulated function DetachFrom(SkeletalMeshComponent MeshComponent)
{
	if (Mesh != None)
	{
		Mesh.SetShadowParent(None);
	}
	
	if (ShieldMesh != None)
	{
		ShieldMesh.SetShadowParent(None);
	}
	
	if (MeshComponent != None)
	{
		if (Mesh != None)
		{
			MeshComponent.DetachComponent(Mesh);
		}
		
		if (ShieldMesh != None)
		{
			MeshComponent.DetachComponent(ShieldMesh);
		}
	}
}

defaultproperties
{
    //Weapon SkeletalMesh
    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'HLW_Package.Models.Longsword'
    End Object
    
    //Shield SkeletalMesh
	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent1
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
		bAcceptsDynamicDecals=false
		CastShadow=true
		bCastDynamicShadow=true
		bPerBoneMotionBlur=true
		bCastHiddenShadow=true
		SkeletalMesh=SkeletalMesh'HLW_Package.Models.Warrior_Shield'
	End Object
	ShieldMesh=SkeletalMeshComponent1
}