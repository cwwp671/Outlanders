class HLW_Pawn_Creep extends HLW_Pawn
	ClassGroup(HeroLineWars);

var int teamIndex;

var Pawn Enemy;
var HLW_Base_Structure EnemyNexus;
var int minGold;
var int maxGold;
var int bumpDamage;
var int attackRange;
var float baseAttackSpeed;
var float AttackSpeed;
var float baseGroundSpeed;

var int creepLevel;

var bool isHasted;

var repnotify bool bIsDead;

var RepNotify HLW_Creep_Camp_Factory newFactory;
var RepNotify HLW_Factory_Creep Factory;
var Vector startLocation;


replication
{
	if (bNetInitial)
		Factory, newFactory;
	
	if(bNetDirty)
		bIsDead;
}

simulated function ReplicatedEvent(Name VarName)
{
	if(VarName == 'bIsDead')
	{
		SetDead(bIsDead);
	}	
}

reliable client function SetDead(bool bAmIDead)
{
	bIsDead = bAmIDead;	
}
 
simulated event PostBeginPlay()
{
	newFactory = HLW_Creep_Camp_Factory(Owner);
	Factory = HLW_Factory_Creep(Owner);
	SpawnDefaultController();
	
	startLocation = Location;
	
	CylinderComponent.SetCylinderSize(35.0 * Mesh.Scale3D.X, 40.0 * Mesh.Scale3D.Y);
	
    super.PostBeginPlay();
}

function Initialize()
{
	local float fCreepLevel;
	local float fbumpDamage;
	
	fCreepLevel = creepLevel;
	fbumpDamage = bumpDamage;
	
	minGold *= creepLevel;
	maxGold *= creepLevel;
	Health *= creepLevel;
	bumpDamage += fbumpDamage * ((fCreepLevel - 1) / 2);
	
	baseAttackSpeed = AttackSpeed;
	baseGroundSpeed = GroundSpeed;
}

simulated event TakeDamage (int Damage, Controller EventInstigator, Vector HitLocation, Vector Momentum, class<DamageType> DamageType,
				  optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(Controller != None)
	{
		HLW_AIController_Camp(self.Controller).BecomeAggravated( EventInstigator.Pawn );
	}
	
	super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local HLW_Pawn_Class ClassPawn;
	
	bIsDead = true;
	
	ClassPawn = HLW_Pawn_Class(Killer.Pawn);

	ClassPawn.GetPRI().SetGold( ClassPawn.GetPRI().Gold + DetermineGold() );
	
	if(newFactory != None)
	{
		newFactory.CreepDied();
	}
	
	if(Controller != None)
	{
		HLW_AIController_Camp(Controller).CreepDied();
	}
	
	if (Super.Died(Killer, DamageType, HitLocation))
	{
		Mesh.MinDistFactorForKinematicUpdate = 0.f;
		Mesh.SetRBChannel(RBCC_Pawn);
		Mesh.SetRBCollidesWithChannel(RBCC_Default, true);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn, false);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle, false);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, false);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume, true);
		Mesh.ForceSkelUpdate();
		Mesh.SetTickGroup(TG_PostAsyncWork);
		CollisionComponent = Mesh;
		CylinderComponent.SetActorCollision(false, false);
		Mesh.SetActorCollision(true, false);
		Mesh.SetTraceBlocking(true, true);
		SetPhysics(PHYS_SoftBody);
		Mesh.PhysicsWeight = 1.0;
	
		if (Mesh.bNotUpdatingKinematicDueToDistance)
		{
			Mesh.UpdateRBBonesFromSpaceBases(true, true);
		}
		
		Mesh.PhysicsAssetInstance.SetAllBodiesFixed(false);
		Mesh.bUpdateKinematicBonesFromAnimation = false;
		Mesh.SetRBLinearVelocity(Velocity, false);
		Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
		Mesh.SetNotifyRigidBodyCollision(true);
		Mesh.WakeRigidBody();
		
		return true;
	}
	
	return false;
}

function GetEnemy()
{
    local HLW_PlayerController PC;
    local HLW_Base_Structure BS;
    foreach DynamicActors(class'HLW_PlayerController', PC)
    {
    	if(Enemy != none)
        {
        	if(PC.Pawn != none)
        	{
				//NEED TO ADD CODE FOR RECOGNIZING TEAM ID OF PLAYER
        		if(PC.Pawn != none && VSize(Location - Enemy.Location) > VSize(Location - PC.Pawn.Location))
        		{
        			Enemy = PC.Pawn;
        		}
        	}
        }
        else
        {
        	if(PC.Pawn != none)
        	{
				Enemy = PC.Pawn;
			}
        }     
    }

	foreach DynamicActors(class'HLW_Base_Structure', BS)
	{
		if(BS != none && HLW_Base_Center(BS) != none)
		{
			EnemyNexus = BS;
		}
	}
}

function int DetermineGold()
{
	local int gold;
	
	gold = rand(maxGold + 1);
	
	return clamp(gold, minGold, maxGold);
}

function Attack(Pawn target)
{
	if (!IsStunned())
	{
		WorldInfo.Game.Broadcast(self, "ATTACKING!");
	}
}


simulated function DistributeExperience(HLW_Pawn Killer, Vector KillLocation)
{
	local int EligiblePlayers;
	local HLW_Pawn_Class CurPawn;

	// Get the number of players eligible for the EXP
	EligiblePlayers = 0;
	foreach WorldInfo.AllPawns(class'HLW_Pawn_Class', CurPawn, KillLocation, 2000)
	{
		if (!IsSameTeam(CurPawn))
		{
			EligiblePlayers++;
		}
	}

	// For each enemy within a radius of my death...
	foreach WorldInfo.AllPawns(class'HLW_Pawn_Class', CurPawn, KillLocation, 2000)
	{
		if (CurPawn.GetPRI() != none)
		{
			if (!IsSameTeam(CurPawn))
			{
				// Evenly divide my experience among each eligible player
				CurPawn.GetPRI().SetExperience(CurPawn.GetPRI().Experience + (ExpReward / EligiblePlayers));
			}

			if (CurPawn == Killer)
			{
				// Award last hit bonus to the actual killer
				CurPawn.GetPRI().SetExperience(CurPawn.GetPRI().Experience + (ExpReward * LastHitBonusPercentage));
			}
		}
	}
}

DefaultProperties
{
	//HealthRegenAmount=0
    ControllerClass=class'HLW.HLW_AIController_Camp'
	bReplicateHealthToAll=true
	
    bJumpCapable=false
    bCanJump=false
    bIsDead=false
}