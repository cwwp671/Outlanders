class HLW_PickUp extends Actor
placeable;

var StaticMeshComponent Mesh;
var(Pickup) SoundCue PickupSound;
var(Pickup) ParticleSystem PickupParticle;
var MaterialInstanceConstant MatInst;
var(Pickup) Material LiquidMaterial;
var HLW_Pawn_Class HitPawn;
var(Pickup) float PickupRadius;
var(Pickup) float RespawnTime;
var bool bSpawned;
var bool bWaitingForRespawn;
var repnotify byte RespawnRep;
var(Pickup) LinearColor LiquidColor;

replication
{
	if(bNetDirty)
		RespawnRep;	
}

simulated function ReplicatedEvent(Name VarName)
{
	if(VarName == 'RespawnRep')
	{
		if(RespawnRep == 0)
		{
			Mesh.SetHidden(false);	
		}
		else
		{
			Mesh.SetHidden(true);
			SpawnParticle();	
		}
		
		return;	
	}
	
	super.ReplicatedEvent(VarName);	
}

simulated function PostBeginPlay()
{
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(LiquidMaterial);
	MatInst.SetVectorParameterValue('VialColor', LiquidColor);
	Mesh.SetMaterial(1, MatInst);
}

simulated function Tick(float DeltaTime)
{
	if(Role == ROLE_Authority)
	{
		if(bSpawned)
		{
			CheckForPickup();
		}
		else if(!bWaitingForRespawn)
		{
			bWaitingForRespawn = true;
			RespawnRep = 1;
			SetTimer(RespawnTime, false, 'Respawn');
		}
	}	
}

reliable server function Respawn()
{
	ClearTimer('Respawn');
	RespawnRep = 0;
	bWaitingForRespawn = false;
	bSpawned = true;
}

reliable server function CheckForPickup()
{
	foreach VisibleCollidingActors(class'HLW_Pawn_Class', HitPawn, PickupRadius, Location)
	{
		PickupEffect();
		return;
	}
}

//Super This
reliable server function PickupEffect()
{
	bSpawned = false;
}
//DecalMaterial'HLW_Package_Randolph.Materials.Blood_Decal'
unreliable client function SpawnParticle()
{
	WorldInfo.MyEmitterPool.SpawnEmitter(PickupParticle, Location, Rotation);
}

defaultproperties
{
	LiquidMaterial=Material'HLW_mapProps.Materials.VialJuice'
	
	RespawnRep=255
	bWaitingForRespawn=false
	bSpawned=true
	
	//Network
	bOnlyDirtyReplication=true
	NetUpdateFrequency=1
	Role=ROLE_Authority
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=+1.4

	bMovable=false
	bReplicateMovement=false
	bUpdateSimulatedPosition=false
	
	Begin Object Class=StaticMeshComponent Name=PickupMesh
		bOwnerNoSee=false
		bOnlyOwnerSee=false
		CollideActors=true
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		MaxDrawDistance=4000 
		bAcceptsDynamicDecals=false
		CastShadow=true
		bCastDynamicShadow=true
		Scale=2
		StaticMesh=StaticMesh'HLW_mapProps.models.Trap_Poison_alt_static'
	End Object
	Mesh=PickupMesh
	Components.Add(PickupMesh)
	
}