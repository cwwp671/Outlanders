/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Pawn_Creep_Fast extends HLW_Pawn_Creep
	ClassGroup(HeroLineWars)
    placeable;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	CylinderComponent.SetCylinderSize(35.0 * Mesh.Scale3D.X, 40.0 * Mesh.Scale3D.Y);
}

function Attack(Pawn target)
{
	target.TakeDamage(bumpDamage, self.Controller, vect(0,0,0), vect(0,0,0), class'HLW_DamageType_Physical',,self);
}


defaultproperties
{
	GroundSpeed=500.0
	attackRange=200
	attackSpeed=1.f
	Health=400
	HealthMax=400
	minGold=7
	maxGold=15
	bumpDamage=5
	
    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
            ModShadowFadeoutTime=0.25
            MinTimeBetweenFullUpdates=0.2
            AmbientGlow=(R=.01,G=.01,B=.01,A=1)
            AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
            bSynthesizeSHLight=TRUE
    End Object
    Components.Add(MyLightEnvironment)
	
	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
        CastShadow=true
        bCastDynamicShadow=true
        bOwnerNoSee=false
        LightEnvironment=MyLightEnvironment
        BlockRigidBody=true
        CollideActors=true
        BlockZeroExtent=true
        bHasPhysicsAssetInstance=true
        //PhysicsAsset=PhysicsAsset'HLW_Package_Creeps.PhysicsAsset.Creep_Raptor_Physics'
		//AnimSets(0)=AnimSet'HLW_Package_Creeps.AnimSet.Creep_Raptor_AnimSet'
        //AnimTreeTemplate=AnimTree'HLW_Package_Creeps.AnimTree.Creep_Raptor_AnimTree'
        //SkeletalMesh=SkeletalMesh'HLW_Package_Creeps.SkeletalMesh.Creep_Raptor'
        //AnimSets(0)=AnimSet'HLW_Package.Animations.raptor_animset'
        //AnimTreeTemplate=AnimTree'HLW_Package.Animations.raptor_animtree'
        AnimSets(0)=AnimSet'HLW_Package_Creeps.AnimSet.Creep_Wolf_AnimSet'
		AnimTreeTemplate=AnimTree'HLW_Package_Creeps.AnimTree.Creep_Wolf_AnimTree'
		PhysicsAsset=PhysicsAsset'HLW_Package_Creeps.PhysicsAsset.Creep_Wolf_Physics'
		SkeletalMesh=SkeletalMesh'HLW_Package_Creeps.SkeletalMesh.Creep_Wolf'
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
    End Object 
    Mesh=InitialSkeletalMesh
    Components.Add(InitialSkeletalMesh)
    
	Begin Object Name=CollisionCylinder
	CollisionRadius=+0035.000000
	CollisionHeight=+0040.000000
	End Object
	CylinderComponent=CollisionCylinder
 
    bJumpCapable=false
    bCanJump=false
}