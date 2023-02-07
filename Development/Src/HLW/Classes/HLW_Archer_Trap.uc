class HLW_Archer_Trap extends Actor;

var StaticMeshComponent Trap;
var SoundCue ActivationSound;
var ParticleSystem TrapParticle;
var MaterialInstanceConstant MatInst;
var float ActivationRadius, EffectRadius;
var bool Activated;
var float Duration;
var bool OwnerDied;
var repnotify LinearColor TeamColor;

replication 
{
    if(bNetDirty)
        TeamColor;
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'TeamColor')
    {
    	SetColor(TeamColor);
    	return;
    }
    
    super.ReplicatedEvent(VarName);
}

/*reliable client function ClientStartParticle()
{
	WorldInfo.MyEmitterPool.SpawnEmitter(TrapParticle, Location, Rotation);
}*/

simulated function Tick(float DeltaTime)
{
	if(Role == ROLE_Authority)
	{
		if(!Activated)
		{
			CheckForActivation();	
		}
		
		Duration -= DeltaTime;
	
		if(Duration <= 0)
		{
			TrapEffect();
		}
		
		
		if(Role == ROLE_Authority)
		{
			if(Controller(Owner) != None)
			{
				if(Controller(Owner).Pawn != None)
				{
					//`log("I Have a pawn");
					if(OwnerDied)
					{
						TrapEffect();	
					}
				}
				else
				{
					//`log("I dont have a pawn");
					OwnerDied = true;
				}
			}
		}
	}
}

reliable server function bool CheckForActivation()
{
	local Actor HitActor;
	
	foreach VisibleCollidingActors(class'Actor', HitActor, ActivationRadius, Location)
	{
		if(HLW_PlayerController(Owner).Pawn != none && HitActor != HLW_PlayerController(Owner).Pawn)
		{
			if(HLW_Pawn(HitActor) != None)
			{
				Activated = true;
				HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).VoiceOver = ActivationSound;
				HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).PlayVoiceOver(HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).VoiceOver);

				TrapEffect();
				
				return true;
			}
			else if(HLW_Projectile(HitActor) != None)
			{
				if(HLW_Projectile(HitActor).Owner.Owner == HLW_PlayerController(Owner).Pawn)
				{	
					Activated = true;
					HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).VoiceOver = ActivationSound;
					HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).PlayVoiceOver(HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).VoiceOver);
					
					TrapEffect();
					
					return true;
				}
			}
		}
	}	
	
	return false;	
}

reliable server function TrapEffect();

//simulated function SetOwner(Actor NewOwner)
//{
	//super.SetOwner(NewOwner);
	//
	//OwnerChange++;
//}

simulated function SetColor(LinearColor tColor)
{
	TeamColor = ColorToLinearColor(HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).GetPRI().Team.TeamColor);
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_mapProps.Materials.TrapMat_MASTER');
	MatInst.SetVectorParameterValue('TeamColor', TeamColor);	
	Trap.SetMaterial(0, MatInst);
}

reliable server function ServerDestroy()
{
	Destroy();	
}

defaultproperties
{
	//Network
	bOnlyDirtyReplication=true
	NetUpdateFrequency=1
	Role=ROLE_Authority
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=+1.4

	OwnerDied=0
	bMovable=false
	bReplicateMovement=false
	bUpdateSimulatedPosition=false
	Duration=90;
	
	Activated = false;
	ActivationRadius=100
	EffectRadius=1000
	
	Begin Object Class=StaticMeshComponent Name=TrapMesh
		bOwnerNoSee=false
		bOnlyOwnerSee=false
		CollideActors=true
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		MaxDrawDistance=4000 
		bAcceptsDynamicDecals=false
		CastShadow=true
		bCastDynamicShadow=true
		Scale=3
		StaticMesh=StaticMesh'HLW_Package_Randolph.models.Traps_Bear'
	End Object
	Trap=TrapMesh
	Components.Add(TrapMesh)
}