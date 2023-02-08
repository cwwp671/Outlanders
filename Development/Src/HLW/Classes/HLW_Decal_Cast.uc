/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Decal_Cast extends HLW_AimingDecal;

var bool bCanDraw;
var bool bPulseOutwards;
var float TimeCounter;
var float TotalTime;

simulated function Activate(float Length)
{
	if(Length <= 0)
	{
		//`warn("Couldn't spawn Cast Decal, invalid length passed in");
		Destroy();
		return;	
	}
	
	SetHidden(false);
	bCanDraw = true;
	TotalTime = Length;
	SetTimer(TotalTime, false, 'Deactivate');
	
	MatInst.SetScalarParameterValue('AbleToCast', 1);
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
	if(bCanDraw && MatInst != None)
	{
		TimeCounter += DeltaTime;
		
		if(bPulseOutwards)
		{
			MatInst.SetScalarParameterValue('CastingTime', FMin(TimeCounter / TotalTime, 1.0));
			
			if(FMin(TimeCounter / TotalTime, 1.0) >= 1.0)
			{
				TimeCounter = 0;	
			}
			
		}
		else
		{
			MatInst.SetScalarParameterValue('CastingTime', 1 - FMin(TimeCounter / TotalTime, 1.0));
			
			if(1- FMin(TimeCounter / TotalTime, 1.0) <= 0.0)
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
	TotalTime=0
}