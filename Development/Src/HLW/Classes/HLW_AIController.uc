class HLW_AIController extends AIController;

var Actor target;
var Pawn attackTarget;
var() Vector TempDest;
var HLW_Pawn_Creep creep;
var int RouteIndex;
var Route route;

var float EnemyAcquireDistance;
var bool isAttacking;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	Pawn.SetMovementPhysics();
}

function Initialize()
{
	creep = HLW_Pawn_Creep(Pawn);
	creep.GetEnemy();
	attackTarget = creep.Enemy;

	route = creep.Factory.routes[creep.Factory.routeNumber];
}

function bool FindNavMeshPath()
{
    // Clear cache and constraints (ignore recycling for the moment)
    NavigationHandle.PathConstraintList = none;
    NavigationHandle.PathGoalList = none;
 
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
	else
	{
		creep.GetEnemy();
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
		
		if(IsInState('WalkRoute') || IsInState('Idle') || IsInState('EndOfRoute'))
		{
			if(VSize(creep.Location - attackTarget.Location) < EnemyAcquireDistance)
			{
				
				target = attackTarget;

				GotoState('ChaseEnemy');
			}
		}
	
		if(!isAttacking && IsInState('ChaseEnemy'))
		{
			if(VSize(creep.Location - attackTarget.Location) <= creep.attackRange)
			{
				GotoState('Attacking');
			}
		}
	}

	//CheckStopCreeps();
}

function CheckStopCreeps()
{
	if(creep.Enemy != none)
	{
		if(HLW_Pawn_Class(creep.Enemy).pauseCreeps == true)
		{
			isAttacking = false;
			GotoState('EndOfRoute');
			ClearTimer('Attack');
		}
	}
}

function findNearestRoutePoint()
{
	local int i;
		
	target =  route.RouteList[0].Actor;
		
	for(i = 0; i < route.RouteList.Length; i++)
	{
		if(VSize(route.RouteList[i].Actor.Location - creep.Location) < VSize(target.Location - creep.Location))
		{
			target = route.RouteList[i].Actor;
			RouteIndex = i;
		}
	}
		
	GotoState('WalkRoute');
}

function Attack()
{
	isAttacking = true;
	if(VSize(creep.Location - attackTarget.Location) > creep.attackRange)
	{
		isAttacking = false;
		ClearTimer('Attack');
		GotoState('Idle');
	}
	
	if (!creep.IsStunned())
	{
		creep.Attack(attackTarget);
	}
}

auto state Idle
{	 
Begin:
	if(creep != none && route != none && !creep.IsStunned())
	{
		target = route.RouteList[RouteIndex].Actor;
		GotoState('WalkRoute');
	}
}

state WalkRoute
{
Begin:
	if (creep.IsStunned())
	{
		GotoState('Idle');
	}

    if( NavigationHandle.ActorReachable( target) )
    {
		//Direct move
		MoveToward( target,target );
    }
    else if( FindNavMeshPath() )
    {
        NavigationHandle.SetFinalDestination(target.Location);
 
        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
        {
			MoveTo( TempDest, target );
        }
    }
    else
    {
		GotoState('Idle');
    }

	if(VSize(Pawn.Location - target.Location) < 128)
	{
		RouteIndex++;
		if(RouteIndex > route.RouteList.length - 1)
		{
			GotoState('EndOfRoute');
		}
		target = route.RouteList[RouteIndex].Actor;
		
	}
	goto 'Begin';
}

state ChaseEnemy
{
Begin:
	if(attackTarget.Physics == PHYS_Falling)
	{
		GotoState('EnemyInAir');
	}
	
	if (creep.IsStunned())
	{
		GotoState('Idle');
	}
	
	if(!(VSize(creep.Location - attackTarget.Location) < EnemyAcquireDistance))
	{
		findNearestRoutePoint();
	}

	if( NavigationHandle.ActorReachable( target) )
	{
		//Direct move
		MoveToward( target,target );
	}
	else if( FindNavMeshPath() )
	{
		NavigationHandle.SetFinalDestination(target.Location);
 
		// move to the first node on the path
		if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
		{
			MoveTo( TempDest, target );
		}
	}
	else
	{
		GotoState('Idle');
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
	if(!isAttacking)
	{
		SetTimer(creep.AttackSpeed, true, 'Attack');
	}
}

state EnemyInAir
{
Begin:
	if(attackTarget.Physics != PHYS_Falling)
	{
		findNearestRoutePoint();
	}
	isAttacking = false;
	GotoState('Idle');
}

state EndOfRoute
{
Begin:
	//`log("creep.EnemyNexus: " @ creep.EnemyNexus);
	//`log("creep.Enemy: " @ creep.Enemy);
	attackTarget = creep.EnemyNexus;
	//`log("attackTarget: " @ attackTarget);
	if(creep.Enemy == none)
	{
		stopLatentExecution();
		creep.Acceleration = vect(0,0,0);
		Sleep(0.5);
	}


}


defaultproperties
{
	EnemyAcquireDistance=2048.f
}