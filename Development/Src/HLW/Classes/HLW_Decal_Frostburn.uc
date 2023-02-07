class HLW_Decal_Frostburn extends HLW_Decal_Blood;

simulated function PostBeginPlay()
{
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(DecalMaterial'HLW_mapProps.Materials.FrostMat');
	Decal.SetDecalMaterial(MatInst);
}

defaultproperties
{
	Begin Object Name=NewDecalComponent
		DecalMaterial=DecalMaterial'HLW_mapProps.Materials.FrostMat'
	End Object
	Decal=NewDecalComponent
}