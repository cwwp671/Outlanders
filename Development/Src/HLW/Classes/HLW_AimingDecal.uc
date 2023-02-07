class HLW_AimingDecal extends DecalActorMovable
	placeable;

var MaterialInstanceConstant MatInst;
var Material AimMaterial;
var float Radius;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(AimMaterial);
	Decal.SetDecalMaterial(MatInst);
}

simulated function SetRadius(float NewRadius)
{
	if(Decal.Width == NewRadius * 2)
	{
		return;
	}
	
	Radius = NewRadius;
	Decal.Width = NewRadius * 2;
	Decal.Height = NewRadius * 2;	
}

defaultproperties
{
	AimMaterial=Material'HLW_mapProps.guimaterials.SpellCast_Circle_Master'
	
	Begin Object Name=NewDecalComponent
		bMovableDecal=true
		bStaticDecal=false
		DecalMaterial=Material'HLW_mapProps.guimaterials.SpellCast_Circle_Master'
		bNoClip=false
		bProjectOnBSP=true
		bProjectOnTerrain=true
		bProjectOnSkeletalMeshes=false
		NearPlane=-256
		FarPlane=256
		FieldOfView=120
	End Object
	Decal = NewDecalComponent

	bMovable=true
	bStatic=false
	bNoDelete=false
	bAllowFluidSurfaceInteraction=true
}