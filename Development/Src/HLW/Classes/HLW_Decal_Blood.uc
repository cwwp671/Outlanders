/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Decal_Blood extends DecalActorBase;

var MaterialInstanceConstant MatInst;
var float LifeTime;
var float LifeTimeCounter;
var float FadeTime;
var float FadeCounter;

simulated function PostBeginPlay()
{
	local LinearColor BloodType;
	
	//TexCoordOffset
	//0,0
	//0.5,0
	//0.5,0.5
	//0,0.5
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(DecalMaterial'HLW_Package_Randolph.Materials.Blood_Decal');
	
	switch(rand(4))
	{
		case 0:
			BloodType.R = 0;
			BloodType.G = 0;
			BloodType.B = 0;
			break;
		case 1:
			BloodType.R = 0.5;
			BloodType.G = 0;
			BloodType.B = 0;
			break;
		case 2:
			BloodType.R = 0.5;
			BloodType.G = 0.5;
			BloodType.B = 0;
			break;
		case 3:
			BloodType.R = 0;
			BloodType.G = 0.5;
			BloodType.B = 0;
			break;	
	}
	
	MatInst.SetVectorParameterValue('TexCoordOffset', BloodType);
	Decal.SetDecalMaterial(MatInst);
}

simulated function Tick(float DeltaTime)
{
	LifeTimeCounter += DeltaTime;
	
	if(LifeTimeCounter >= (LifeTime - FadeTime))
	{
		FadeCounter += DeltaTime;
		MatInst.SetScalarParameterValue('Opacity', 1 - FMin(FadeCounter / FadeTime, 1.0));
		
		if(LifeTimeCounter >= LifeTime)
		{
			Destroy();	
		}	
	}
}

defaultproperties
{
	LifeTime=10
	FadeTime=3
	LifeTimeCounter=0
	FadeCounter=0
	
	Begin Object Name=NewDecalComponent
		bAcceptsLights=true
		bAcceptsDynamicLights=true
		bStaticDecal=false
		DecalMaterial=DecalMaterial'HLW_Package_Randolph.Materials.Blood_Decal'//MaterialInstanceTimeVarying'HLW_Package_Randolph.Decals.TestImpactDecal'
		bNoClip=false
		bProjectOnBSP=true
		bProjectOnTerrain=true
		bProjectOnSkeletalMeshes=true
		Width=100
		Height=100
		NearPlane=0
		FarPlane=10
		bCastDynamicShadow=true
		bCastStaticShadow=true
		CastShadow=true
	End Object
	Decal=NewDecalComponent

	bStatic=false
	bNoDelete=false
}