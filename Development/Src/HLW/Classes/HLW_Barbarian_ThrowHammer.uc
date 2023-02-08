/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Barbarian_ThrowHammer extends KActorSpawnable;

var const SkeletalMeshComponent HammerSM;
var const SkeletalMeshComponent GroundedHammerSM;
var Vector EndLocation;

simulated function RigidBodyCollision (	PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex) 
{
	if(Owner != None)
	{
		HLW_Ability_HammerToss(Owner).GotoState('HammerLanded');
	}
	
	HammerSM.SetRBPosition(EndLocation);
	HammerSM.SetHidden(true);
	HammerSM.SetNotifyRigidBodyCollision(false);
	HammerSM.PutRigidBodyToSleep();
	SetPhysics(PHYS_None);
	CollisionComponent.SetActorCollision(true, false, false);
	SetTimer(10.0, false, 'DestroyObject');
	SetLocation(EndLocation);
	GroundedHammerSM.SetHidden(false);
}

simulated function DestroyObject()
{
	Destroy();	
}

defaultproperties
{
	Begin Object Class=SkeletalMeshComponent Name=Hammer_SM
		CollideActors=true
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        BlockRigidBody=true
        CanBlockCamera=false
        bNotifyRigidBodyCollision = true
		ScriptRigidBodyCollisionThreshold=1
        bUpdateKinematicBonesFromAnimation=false
        PhysicsWeight=1.0
        RBChannel=RBCC_Default
        RBCollideWithChannels=(Default=true,BlockingVolume=false,GameplayPhysics=false,EffectPhysics=false, Pawn=false, DeadPawn=false)
        bSkipAllUpdateWhenPhysicsAsleep=TRUE
        bHasPhysicsAssetInstance=true
        PhysicsAsset=PhysicsAsset'HLW_Package_Randolph.Physics.Hammer_Physics'
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Hammer'
		Materials(0)=Material'HLW_mapProps.Materials.HammerMat'
	End Object
	HammerSM=Hammer_SM
	CollisionComponent=Hammer_SM
	Components.Add(Hammer_SM)
	
	Begin Object Class=SkeletalMeshComponent Name=GroundedHammer_SM
		HiddenGame=true
		Translation=(X=-25,Y=0,Z=90)
		Rotation=(Roll=29127, Pitch=0, Yaw=-16384)
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Hammer'
		Materials(0)=Material'HLW_mapProps.Materials.HammerMat'
	End Object
	GroundedHammerSM=GroundedHammer_SM
	Components.Add(GroundedHammer_SM)
	//ParticleSystem'HLW_AndrewParticles.Particles.FX_LightSpell_Base'
	//ParticleSystem'HLW_AndrewParticles.Particles.FX_LightSpell_Burst'
	//ParticleSystem'HLW_AndrewParticles.Particles.FX_LightSpell_Hammer'
	//ParticleSystem'HLW_AndrewParticles.Particles.FX_LightSpell_Loop'
}