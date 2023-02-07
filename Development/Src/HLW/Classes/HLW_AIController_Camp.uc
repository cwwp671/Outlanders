class HLW_AIController_Camp extends AIController;

var Actor target;
var HLW_Pawn_Creep creep;

var int groupID;
var int groupSize;
var Array<HLW_AIController_Camp> Group;

var bool bAggravated;
var float leashRange;
var float closeEnoughToSpawn;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	Pawn.SetMovementPhysics();
}

function Initialize()
{
	while(creep == none)
	{
		creep = HLW_Pawn_Creep(Pawn);
	}
}

function CreateCampGroup()
{
	local HLW_AIController_Camp AIC;
	
	foreach DynamicActors(class'HLW_AIController_Camp', AIC)
    {
        if(AIC.Pawn != none)
        {
			if(AIC.groupID == groupID)
			{
				Group.AddItem(AIC);
			}
        }
    }
}

function bool FindNavMeshPath()
{
    // Clear cache and constraints (ignore recycling for the moment)
    //NavigationHandle.PathConstraintList = none;
    //NavigationHandle.PathGoalList = none;
 
    // Create constraints
    class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,target );
    class'NavMeshGoal_At'.static.AtActor( NavigationHandle, target,32 );
 
    // Find path
    return NavigationHandle.FindPath();
}

simulated function Tick(float DeltaTime)
{
	
	
	if (creep.IsStunned())
	{
		GotoState('Idle');
	}
	else if (creep != none)
	{
		if(HLW_Pawn_Creep_Healer(creep) != none)
		{
			HLW_Pawn_Creep_Healer(creep).FindHealTarget();
		}
		
		if(HLW_Pawn_Creep_Mage(creep) != none)
		{
			if(!HLW_Pawn_Creep_Mage(creep).hasteCooldown)
			{
				HLW_Pawn_Creep_Mage(creep).FindHasteTarget();
			}
		}
	
		if(bAggravated && IsInState('ChaseEnemy'))
		{
			if(VSize(creep.Location - target.Location) <= creep.attackRange)
			{
				GotoState('Attacking');
			}
		}
	}
}

function BecomeAggravated(Pawn targetIN)
{
	local int i;
	if( Group.Length != 0 )
	{
		for(i = 0; i < Group.Length; i++)
		{
			if(Group[i] != none)
			{
				Group[i].target = targetIN;
				Group[i].bAggravated = true;
			}
		}
	}
	else
	{
		`log("Trying to become aggravated, but have no group");
	}
}

function CreepDied()
{
	Group.Remove(0, Group.Length);
}

function Attack()
{
	if(VSize(creep.Location - target.Location) > creep.attackRange)
	{
		//`log("ToFarToHit");
		ClearTimer('Attack');
		GotoState('ChaseEnemy'); //Lukas;
	}
	
	if (!creep.IsStunned())
	{
		creep.Attack(Pawn(target));
		GotoState('ChaseEnemy');
	}
}

auto state Idle
{	 
	simulated function Tick(float DeltaTime)
	{
		if(Group.Length < groupSize)
		{
			CreateCampGroup();
		}
		
		if(bAggravated && creep != none)
		{	
			GotoState('ChaseEnemy');
		}
	}
	
	Begin:
}

state ChaseEnemy
{
	local Vector TempDest;
	
	simulated function Tick(float DeltaTime)
	{
		if(VSize(creep.Location - creep.startLocation) > leashRange)
		{
			//`log("Target went to far, return to base");
			stopLatentExecution();
			creep.Acceleration = vect(0,0,0);
			bAggravated = false;
			target = creep.newFactory;
			GotoState('ReturnToCamp');
		}
		
		if(VSize(creep.Location - target.Location) <= creep.attackRange)
		{
			GotoState('Attacking');
		}
	}
	
	Begin:
		if(target.Physics == PHYS_Falling)
		{
			GotoState('Idle');
		}
	
		if (creep.IsStunned())
		{
			GotoState('Idle');
		}
		
		if( FindNavMeshPath() )
		{
			NavigationHandle.SetFinalDestination(target.Location);

			if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
			{
				MoveTo( TempDest, target );
			}
		}
		else if( NavigationHandle.ActorReachable( target) )
		{
			MoveToward( target,target );
		}
		else
		{
			//`log("Actor not reachable");
			GotoState('ReturnToCamp'); //Lukas;
		}

		goto 'Begin';
}

state Attacking
{
Begin:
	if (creep.IsStunned())
	{
		GotoState('Idle');
	}

	stopLatentExecution();
	creep.Acceleration = vect(0,0,0);
	if(bAggravated)
	{
		SetTimer(creep.AttackSpeed, false, 'Attack');
	}
}

state ReturnToCamp
{
	local Vector TempDest;
	
	simulated function BeginState(Name PreviousState)
	{
		stopLatentExecution();
		creep.Acceleration = vect(0,0,0);
		bAggravated = false;
		target = creep.newFactory;
	}
	
	simulated function tick(float DeltaTime)
	{
		if(VSize(creep.Location - creep.newFactory.Location) < closeEnoughToSpawn)
		{
			stopLatentExecution();
			creep.Acceleration = vect(0,0,0);
			creep.SetRotation(creep.newFactory.Rotation);
			creep.Health = creep.HealthMax;
			GotoState('Idle');
		}
	}
	
Begin:
	//`log("Returning to camp");
	
		if (creep.IsStunned())
		{
			GotoState('Idle');
		}
		
		if( FindNavMeshPath() )
		{
			NavigationHandle.SetFinalDestination(target.Location);

			if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
			{
				MoveTo( TempDest, target );
			}
		}
		else if( NavigationHandle.ActorReachable( target) )
		{
			MoveToward( target,target );
		}
		else
		{
			GotoState('Idle');
		}

		goto 'Begin';
}


state EnemyInAir
{
Begin:
	GotoState('Idle');
}

defaultproperties
{
	bAggravated=false
	leashRange=1024f
	closeEnoughToSpawn=256f
}