/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_RB_Item extends KActorSpawnable;

var() /*const editconst*/ SkeletalMeshComponent    SkeletalMeshComponent;
var repnotify transient Inventory Item;

/** Used to replicate mesh to clients */
var repnotify transient SkeletalMesh ReplicatedSkeletalMesh;

/** Used to replicate physics asset to clients */
var repnotify transient PhysicsAsset ReplicatedPhysAsset;

replication
{
    // Server->Client properties
    if (Role == ROLE_Authority)
        Item, ReplicatedSkeletalMesh, ReplicatedPhysAsset;
}

simulated event ReplicatedEvent( name VarName )
{
    if (VarName == 'ReplicatedSkeletalMesh')
        SkeletalMeshComponent.SetSkeletalMesh(ReplicatedSkeletalMesh);
    else if(VarName == 'ReplicatedPhysAsset')
        SkeletalMeshComponent.SetPhysicsAsset(ReplicatedPhysAsset);

    // wait until both the mesh and physasset have replicated, then setup the physasset instance
    if ((SkeletalMeshComponent != None) && (SkeletalMeshComponent.SkeletalMesh != None) && (SkeletalMeshComponent.PhysicsAsset != None))
    {
        SkeletalMeshComponent.SetHasPhysicsAssetInstance(true);
    }
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    if (bWakeOnLevelStart)
    {
        if (SkeletalMeshComponent != None)
            SkeletalMeshComponent.WakeRigidBody();
    }

    if (SkeletalMeshComponent != None)
    {
        ReplicatedSkeletalMesh = SkeletalMeshComponent.SkeletalMesh;
        ReplicatedPhysAsset = SkeletalMeshComponent.PhysicsAsset;
    }
}

simulated function String GetHumanReadableName()
{
    if (Item != None)
        return Item.GetHumanReadableName();

    return Super.GetHumanReadableName();
}

function GiveTo(Pawn P)
{
}

function PickedUpBy(Pawn P)
{
}

function SetItem(Inventory NewItem, SkeletalMeshComponent SM, vector StartLocation, rotator StartRotation)
{
    local SkeletalMeshComponent SMC;

    Item = NewItem;

    SMC = SM;
    //SkeletalMeshComponent = SMC;
    //`log("SMC.Scale:"@SMC.Scale);
    SkeletalMeshComponent.SetScale(SMC.Scale);
    SkeletalMeshComponent.SetSkeletalMesh(SMC.SkeletalMesh);
    ReplicatedSkeletalMesh = SMC.SkeletalMesh;
    SkeletalMeshComponent.SetPhysicsAsset(SMC.PhysicsAsset);
    ReplicatedPhysAsset = SMC.PhysicsAsset;
    SkeletalMeshComponent.SetHasPhysicsAssetInstance(true);

    SetLocation(StartLocation);
    SetRotation(StartRotation);
	SetDrawScale(SMC.Scale);
    
    SkeletalMeshComponent.SetRBPosition(StartLocation);
    SkeletalMeshComponent.SetRBRotation(StartRotation);
    SkeletalMeshComponent.WakeRigidBody();
    Instigator = Item.Instigator;
    
    SetTimer(10, false, 'DeleteItem');
}

simulated function DeleteItem()
{
	Destroy();	
}

defaultproperties
{
    Components.Remove(StaticMeshComponent0);

    Begin Object Class=SkeletalMeshComponent Name=RBItemSkelMeshComponent
        CollideActors=true
        BlockActors=false
        BlockZeroExtent=true
        BlockNonZeroExtent=false
        BlockRigidBody=true
        bHasPhysicsAssetInstance=false
        bUpdateKinematicBonesFromAnimation=false
        PhysicsWeight=1.0
        RBChannel=RBCC_Default
        RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=false,EffectPhysics=false, Pawn=false, DeadPawn=false)
        LightEnvironment=MyLightEnvironment
        bSkipAllUpdateWhenPhysicsAsleep=TRUE
    End Object
    CollisionComponent=RBItemSkelMeshComponent
    SkeletalMeshComponent=RBItemSkelMeshComponent
    Components.Add(RBItemSkelMeshComponent)

	//Physics=PHYS_RigidBody
	bCollideWorld=true
    bBlockActors=false
    bWakeOnLevelStart=true
    //bNetInitialRotation=false
}