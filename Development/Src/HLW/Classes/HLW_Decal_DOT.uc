class HLW_Decal_DOT extends HLW_AimingDecal;

var Actor ActorToFollow;
var bool bCanDraw;
var bool bPulseOutwards;
var float TimeCounter;
var float TickTime;
var float TotalTime;
var int NumTicks;

simulated function Activate(Actor FollowActor, int NumberOfTicks, float TickLength)
{
	local HLW_Pawn_Class PawnActor;
	
	if(NumberOfTicks <= 0)
	{
		//`warn("Couldn't spawn DOT Decal, 0 ticks passed in");
		Destroy();
		return;	
	}
	
	SetHidden(false);
	bCanDraw = true;
	NumTicks = NumberOfTicks;
	TickTime = TickLength;
	TotalTime = TickTime * NumTicks;
	ActorToFollow = FollowActor;
	SetTimer(TotalTime, false, 'Deactivate');
	
	if(HLW_Pawn_Class(FollowActor) != None)
	{
		PawnActor = HLW_Pawn_Class(FollowActor);
	}
	
	if(PawnActor.GetPRI() != None && PawnActor.GetPRI().Team != None)
	{
		if(PawnActor.GetPRI().Team.TeamIndex == HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).GetPRI().Team.TeamIndex)
		{
			MatInst.SetScalarParameterValue('AbleToCast', 1);
		}
		else
		{
			MatInst.SetScalarParameterValue('AbleToCast', 0);
		}
	}
	else if(PawnActor == HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn))
	{
		MatInst.SetScalarParameterValue('AbleToCast', 1);
	}
	else
	{
		MatInst.SetScalarParameterValue('AbleToCast', 0);
	}
	
}

simulated function Deactivate()
{
	SetHidden(true);
	bCanDraw = false;
	TimeCounter = 0;
	Destroy();
}

simulated function Tick(float DeltaTime)
{
    local Rotator DecalRotation;

	if(bCanDraw && MatInst != None && ActorToFollow != None)	
	{
		TimeCounter += DeltaTime;
		SetLocation(ActorToFollow.Location);
		DecalRotation = ActorToFollow.Rotation;
		DecalRotation.Pitch = -16384;
		DecalRotation.Roll = 0;
		SetRotation(DecalRotation);
		
		if(bPulseOutwards)
		{
			MatInst.SetScalarParameterValue('CastingTime', FMin(TimeCounter / TickTime, 1.0));
			
			if(FMin(TimeCounter / TickTime, 1.0) >= 1.0)
			{
				TimeCounter = 0;	
			}
			
		}
		else
		{
			MatInst.SetScalarParameterValue('CastingTime', 1 - FMin(TimeCounter / TickTime, 1.0));
			
			if(1- FMin(TimeCounter / TickTime, 1.0) <= 0.0)
			{
				TimeCounter = 0;	
			}
		}
			
	}	
}

defaultproperties
{
	bCanDraw=false
	bPulseOutwards=true
	TimeCounter=0
	TickTime=0
	TotalTime=0
}