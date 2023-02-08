/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */

class HLW_Ability_Aura extends HLW_Ability_Passive;

var float DamageToAuraPercentage;
var float PhysPowToHealPercentage;

var float MaxAuraSize;
var repnotify float CurrentAuraAmount;

var float AuraDecreasePerSecond;

var float HealAmountPerTick;

var LinearColor DecalColor;

replication 
{
    if(bNetDirty)
        CurrentAuraAmount;
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'CurrentAuraAmount')
    {
    	ClientSetAuraAmount(CurrentAuraAmount);
    	return;
    }
    
    super.ReplicatedEvent(VarName);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	if(Role == ROLE_Authority)
	{
		SetTimer(1, true, 'HealPulse');
		//`log("FUCKING IAHUF:KSGA:S");
	}	
}

reliable server function IncreaseAura(float DamageDone, Actor HitActor)
{
	if(OwnerPC != none && OwnerPC.Pawn != None)
	{
		CurrentAuraAmount += DamageDone * DamageToAuraPercentage;
		CurrentAuraAmount = fMin(CurrentAuraAmount, 100);
		//`log("CURRENT AURA SIZE:"@CurrentAuraSize);
	}
}

reliable client function ClientSetAuraAmount(float NewAuraAmount)
{
	CurrentAuraAmount = NewAuraAmount;
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	if(Role == ROLE_Authority)
	{
		if(OwnerPC != none && OwnerPC.Pawn != None)
		{
			CurrentAuraAmount -= (AuraDecreasePerSecond * DeltaTime);
			CurrentAuraAmount = fMax(CurrentAuraAmount, 0);
		}
	}
	else if(Role < ROLE_Authority)
	{
		if(OwnerPC != none && OwnerPC.Pawn != None)
		{
			if(AimingDecal == None)
			{
				AimingDecal = Spawn(class'HLW_AimingDecal',,,OwnerPC.Pawn.Location, Rot(-16384,0,0));  
				AimingDecal.MatInst.SetScalarParameterValue('CastingTime', 0);
				AimingDecal.MatInst.SetTextureParameterValue('SpellSymbol', DecalImage);
				AimingDecal.MatInst.SetVectorParameterValue('SpellColorUnable', DecalColor);
			}
			else if(AimingDecal.bHidden)
			{
				AimingDecal.SetHidden(false);	
			}
			
			AimingDecal.SetLocation(OwnerPC.Pawn.Location);
			AimingDecal.SetRadius((CurrentAuraAmount / 100) * MaxAuraSize);
		}	
	}
}

simulated function HealPulse()
{
	local HLW_Pawn_Class HitPawn;
	
	if(Role == ROLE_Authority)
	{
		//`log("I AM SERVER");
		if(OwnerPC != none && OwnerPC.Pawn != None)
		{
			//`log("SERVER KNOWS YOU I AM");
			
			foreach DynamicActors(class'HLW_Pawn_Class', HitPawn)
			{
				//`log("FOUND A PAWN AND HES THIS FAR AWAY:"@VSize(OwnerPC.Pawn.Location - HitPawn.Location));
				if(VSize(OwnerPC.Pawn.Location - HitPawn.Location) < (CurrentAuraAmount / 100) * MaxAuraSize)
				{
					//`log("FOUND A PAWN");
					if(HitPawn != None)
					{
						//`log("THE PAWNS A PAWN");
						if(HitPawn == HLW_Pawn_Class(OwnerPC.Pawn)) //HEAL SELF
						{
							//`log("HEAL SELF");
							HitPawn.HealDamage(HealAmountPerTick, OwnerPC, class'HLW_DamageType_Magical');
						}
						else if(OwnerPC.Pawn.IsSameTeam(HitPawn)) //HEAL TEAMATES;
						{
							//`log("HEAL OTHER");
							HitPawn.HealDamage(HealAmountPerTick + (OwnerPC.GetPRI().PhysicalPower * PhysPowToHealPercentage), OwnerPC, class'HLW_DamageType_Magical');
						}
					}		
				}
			}
		}
	}	
}

simulated function float UseAura(float PercentageToUse)
{
	local float ReturnAmount;
	if(Role == ROLE_Authority)
	{	
		ReturnAmount = CurrentAuraAmount * PercentageToUse;
		CurrentAuraAmount -= ReturnAmount;
		return (ReturnAmount / 100);
	}
	return 0;
}

simulated function float GetAuraPercentage(float PercentageToGet)
{
	return (CurrentAuraAmount * PercentageToGet / 100);
}

simulated function AbilityComplete(bool bIsPremature = false)
{
	if(bIsPremature)
	{
		if(AimingDecal != None)
		{
			AimingDecal.SetHidden(true);
		}
		
		CurrentAuraAmount = 0;
	}	
}

defaultproperties
{
	NetUpdateFrequency=3
	
	DamageToAuraPercentage=0.3f
	MaxAuraSize=300
	CurrentAuraAmount=0.0f
	AuraDecreasePerSecond=1.0f
	
	PhysPowToHealPercentage=0.01
	
	HealAmountPerTick=1
	
	DecalColor=(R=0.941,G=0.9,B=0.55)
	
	AimType=HLW_AAT_Fixed
}