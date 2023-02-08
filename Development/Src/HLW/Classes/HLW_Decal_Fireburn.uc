/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Decal_Fireburn extends HLW_Decal_Blood;

simulated function PostBeginPlay()
{
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(DecalMaterial'HLW_mapProps.Materials.BurnMat');
	Decal.SetDecalMaterial(MatInst);
}

defaultproperties
{
	Begin Object Name=NewDecalComponent
		DecalMaterial=DecalMaterial'HLW_mapProps.Materials.BurnMat'
	End Object
	Decal=NewDecalComponent
}