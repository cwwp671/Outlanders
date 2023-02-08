/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Ability_Cloak extends HLW_Ability;

var(Ability) HLW_UpgradableParameter Duration;
var(Ability) float SpeedBuffAmount;

var SoundCue ActivationSound;
var SoundCue CloakInSound;
var SoundCue CloakOutSound;

simulated function ActivateAbility()
{
	local Vector SpawnLocation;
	local Rotator SpawnRotation;
	super.ActivateAbility();

	ConsumeResources();
	
	SpawnLocation = OwnerPC.Pawn.Location;
	SpawnLocation.Z -= 60;
	HLW_Pawn_Class_Archer(OwnerPC.Pawn).ThirdPerson.GetSocketWorldLocationAndRotation(HLW_Pawn_Class_Archer(OwnerPC.Pawn).FartSocket, SpawnLocation, SpawnRotation);
	HLW_Pawn_Class(OwnerPC.Pawn).SpawnEmitter(ParticleSystem'HLW_Package_Randolph.Farticles.Farticle', SpawnLocation,/*OwnerPC.Pawn.Rotation*/SpawnRotation,true,1.0f);
	
	if (Role == ROLE_Authority)
	{
		HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = ActivationSound;
		HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);

		PlaySound(CloakInSound,,,,OwnerPC.Pawn.Location);
	}

	GoToState('Cloaking');
}

state Cloaking
{
	simulated function BeginState(Name PreviousStateName)
	{
		local HLW_Decal_DOT CloakDecal;
		
		if(Role < ROLE_Authority)
		{
			CloakDecal = Spawn(class'HLW_Decal_DOT', OwnerPC,, OwnerPC.Pawn.Location, Rot(-16384, 0, 0));
			CloakDecal.SetRadius(100);
			CloakDecal.Activate(OwnerPC.Pawn, 1, Duration.CurrentValue + 2);
			CloakDecal.MatInst.SetTextureParameterValue('SpellSymbol', DecalImage);
		}
		
		HLW_Pawn_Class(OwnerPC.Pawn).DrawNamePlate(false);//TODO: If someone can get this working that'd be cool
		
		SetTimer(0.1, true, 'cloaking');
	}
	
	simulated function cloaking()
	{
		
		if(OwnerPC.Pawn != None && HLW_Pawn_Class(OwnerPC.Pawn).Opacity > 0)
		{
			HLW_Pawn_Class(OwnerPC.Pawn).Opacity -= 0.1;
		}
		else
		{
			if(OwnerPC.Pawn != None)
			{
				HLW_Pawn_Class(OwnerPC.Pawn).Opacity = 0.0;
			}
			
			GoToState('Cloaked');
		}
	}
	simulated function EndState(Name NextStateName)
	{
		ClearTimer('cloaking'); 
	}
}

state Cloaked
{
	simulated function BeginState(Name PreviousStateName)
	{
		local HLW_StatusEffect_Buff MoveBuff;
		local HLW_Pawn Caster;
		local int i;
		
		MoveBuff = Spawn(class'HLW_StatusEffect_Buff', OwnerPC.Pawn);
					MoveBuff.StatToAffect = HLW_Stat_MovementSpeed;
					MoveBuff.BuffAmount = SpeedBuffAmount;
					MoveBuff.Duration = Duration.CurrentValue;
					
		SetTimer(Duration.CurrentValue, false, 'endCloak');
		
		if(Role == ROLE_Authority)
		{
			Caster = HLW_Pawn(OwnerPC.Pawn);
			Caster.ApplyStatusEffect(MoveBuff, OwnerPC);
			`log("ACTIVE STATUS EFFECTS"@Caster.ActiveStatusEffects.Length);
			for(i = Caster.ActiveStatusEffects.Length - 1; i >= 0; i--)
			{
				if(Caster.ActiveStatusEffects[i].EffectName == "Slow")
				{
					Caster.RemoveStatusEffect(Caster.ActiveStatusEffects[i]);
					`log("REMOVING SLOW");
					continue;
				}
				if(Caster.ActiveStatusEffects[i].EffectName == "Stun")
				{
					Caster.RemoveStatusEffect(Caster.ActiveStatusEffects[i]);
					`log("REMOVING STUN");
					continue;
				}
			}
		}
	}
	
	simulated function endCloak()
	{
		GoToState('UnCloak');
	}
	simulated function EndState(Name NextStateName)
	{
		ClearTimer('endCloak'); 
	}
}

state UnCloak
{
	simulated function BeginState(Name PreviousStateName)
	{
		StartCooldown();
		SetTimer(0.2, true, 'unCloaking');
		
		if (Role == ROLE_Authority)
		{
			if(OwnerPC != none && OwnerPC.Pawn != none)
			{
				PlaySound(CloakOutSound,,,,OwnerPC.Pawn.Location);
			}
		}
	}
	
	simulated function unCloaking()
	{
		if(OwnerPC != none && OwnerPC.Pawn != none)
		{
			if(HLW_Pawn_Class(OwnerPC.Pawn).Opacity < 1.0)
			{
				HLW_Pawn_Class(OwnerPC.Pawn).Opacity += 0.1;
			}
			else
			{
				HLW_Pawn_Class(OwnerPC.Pawn).Opacity = 1.0; 
				GoToState('Inactive');
			}
		}
	}
	simulated function EndState(Name NextStateName)
	{
		if(OwnerPC != none && OwnerPC.Pawn != none)
		{
			HLW_Pawn_Class(OwnerPC.Pawn).DrawNamePlate(true);//TODO: If someone can get this working that'd be cool
		}

		ClearTimer('unCloaking');
		AbilityComplete();
	}
}

simulated function OnCooldownComplete()
{
	super.OnCooldownComplete();
}

simulated function StartCooldown()
{
	super.StartCooldown();
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);	
}

simulated function LevelUp()
{
	super.LevelUp();
	
	Duration.Upgrade(AbilityLevel);
}

defaultproperties
{
	ActivationSound=SoundCue'HLW_Package_Voices.Archer.Ability_Cloak'
	CloakInSound=SoundCue'HLW_Package_Chris.SFX.Archer_Ability_Cloak_In'
	CloakOutSound=SoundCue'HLW_Package_Chris.SFX.Archer_Ability_Cloak_Out'
	
	AimType=HLW_AAT_Instant

	SpeedBuffAmount=60.0

	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=30
		Factor=0.2
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter

	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=15.0
		//Factor=0.1
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter

	Begin Object Class=HLW_UpgradableParameter Name=DurationParameter
		BaseValue=5.0
		Factor=0.07
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	Duration=DurationParameter
	
	DecalImage=Texture2D'HLW_Package_Lukas.Textures.SpellSymbol_Cloak'
}