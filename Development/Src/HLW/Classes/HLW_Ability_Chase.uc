class HLW_Ability_Chase extends HLW_Ability_Passive;

var(Ability) float MaxDistance;
var(Ability) float MarginOfError;
var(Ability) float SpeedIncrease;
var bool bIsChasing;

simulated function Tick(float DeltaTime)
{
	local HLW_Pawn HitPawn;
	local Vector CasterEyeLoc, TraceHitLocation, TraceHitNormal;
	local Rotator CasterEyeRot;
	
	if(OwnerPC != None && OwnerPC.Pawn != None)
	{
		
		OwnerPC.GetPlayerViewPoint(CasterEyeLoc, CasterEyeRot);

		HitPawn = HLW_Pawn( OwnerPC.Pawn.Trace(TraceHitLocation, TraceHitNormal, OwnerPC.Pawn.Location + Vector(CasterEyeRot) * MaxDistance,,, vect(50, 50, 1)) );

		if(HitPawn != None && HitPawn != OwnerPC.Pawn && !HLW_Pawn_Class(OwnerPC.Pawn).bIsStrafing && !HLW_Pawn_Class(OwnerPC.Pawn).bIsMovingBackwards)
		{
			if(!bIsChasing)
			{
				HLW_Pawn_Class_Warrior(OwnerPC.Pawn).bIsChasing = true;
				OwnerPC.Pawn.GroundSpeed = HLW_Pawn_Class(OwnerPC.Pawn).default.BaseMovementSpeed + SpeedIncrease;
			}
			
		}
		else
		{
			HLW_Pawn_Class_Warrior(OwnerPC.Pawn).bIsChasing = false;	
		}
	}
}

simulated function AbilityComplete(bool bIsPremature = false);


defaultproperties
{
	MaxDistance=10000
	MarginOfError=50
	SpeedIncrease=40
}