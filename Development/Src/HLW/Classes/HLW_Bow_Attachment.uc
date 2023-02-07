class HLW_Bow_Attachment extends HLW_WeaponAttachment;

var AnimNodePlayCustomAnim BowAnimation;


//Client Called - Attach Weapon to Player Mesh
simulated function AttachTo(HLW_Pawn_Class OwnerPawn)
{
	local rotator BowRotation;
	local vector BowPosition;
	local MaterialInstanceConstant BowMatInst;
	
	if(OwnerPawn != None)
	{
		SetOwner(OwnerPawn);	
	}
	
	if (OwnerPawn.Mesh != None)
	{
		if (Mesh != None)
		{
			
			
			//Set Bow Shadow Parent to Pawn
			Mesh.SetShadowParent(OwnerPawn.ThirdPerson);
			
			//Rotate Bow Correctly
			//BowRotation.Roll = -726;
			//BowRotation.Pitch = 8332;
			//BowRotation.Yaw = -25461; 

			BowRotation.Roll = -12.82*DegToUnrRot;
			BowRotation.Pitch = 54.25*DegToUnrRot;
			BowRotation.Yaw = -137.02*DegToUnrRot; 
			
			Mesh.SetRotation(BowRotation);
			
			//Translate Bow Correctly
			BowPosition = Mesh.Translation;

			BowPosition.X += 0.92284;
			BowPosition.Y += 2.380053;
			BowPosition.Z += 1.392819;
			Mesh.SetTranslation(BowPosition);
			Mesh.SetScale(0.35);
			
			//BowPosition.X += -3.050587;
			//BowPosition.Y += 4.855840;
			//BowPosition.Z += -1.210058;
			//Mesh.SetTranslation(BowPosition);
			//Mesh.SetScale(0.5f);
			
			BowMatInst = new(None) Class'MaterialInstanceConstant';
		
			BowMatInst.SetParent(Material'HLW_mapProps.Materials.BowMat');
		
			if(HLW_Pawn_Class_Archer(Owner) != None)
			{
				BowMatInst.SetVectorParameterValue('TeamColor', HLW_Pawn_Class_Archer(OwnerPawn).CurrentTeamColor); //TODO:Switch back to PawnClass when fixed
			}
			
			Mesh.SetMaterial(0, BowMatInst);
			
			OwnerPawn.ThirdPerson.AttachComponentToSocket(Mesh, HLW_Pawn_Class_Archer(OwnerPawn).BowSocketTP);
		}
	}
}

simulated function DetachFrom(SkeletalMeshComponent MeshComponent)
{
	if (Mesh != None)
	{
		Mesh.SetShadowParent(None);
	}
	
	if (MeshComponent != None)
	{
		if (Mesh != None)
		{
			MeshComponent.DetachComponent(Mesh);
		}
	}
}

//Bow_Notch 1.0
//Bow_Draw 0.7917

simulated function PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        BowAnimation = AnimNodePlayCustomAnim(Mesh.FindAnimNode('CustomAnim'));
        //`log("****************************HERE*****************************");
    }
}

defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Dat_Bow'
		AnimTreeTemplate=AnimTree'HLW_Package_Randolph.Animations.Bow_AnimTree'
		AnimSets(0)=AnimSet'HLW_Package_Randolph.Animations.Bow_AnimSet'
	EndObject
}