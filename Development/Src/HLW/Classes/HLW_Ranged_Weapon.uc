class HLW_Ranged_Weapon extends Weapon;

var class<HLW_WeaponAttachment>	AttachmentClass;

var() class<DamageType> MyDamageType;

var bool bIsAttacking; 

simulated function AttachWeaponTo(SkeletalMeshComponent MeshComponent, optional Name SocketName)
{
	local HLW_Pawn_Class P;

	P = HLW_Pawn_Class(Instigator);
	
	//Spawn Attachment
	if (Role == ROLE_Authority && P != None)
	{
		P.CurrentWeaponAttachmentClass = AttachmentClass;

		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_Client && Instigator.IsLocallyControlled()))
		{
			P.WeaponAttachmentChanged();
		}
	}
}

simulated function TimeWeaponEquipping()
{
	AttachWeaponTo(Instigator.Mesh);

	Super.TimeWeaponEquipping();
}

reliable server function ServerScaleMovement(float Rate)
{
	HLW_Pawn_Class_Archer(Owner).ScaleMovement(Rate);
}

defaultproperties
{
    bIsAttacking = false
}