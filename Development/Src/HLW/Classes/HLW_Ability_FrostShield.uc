/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Ability_FrostShield extends HLW_Ability;

var(Ability) float MagPowPercentageAsDamage;
var(Ability) HLW_UpgradableParameter BaseDamagePerTick;
var(Ability) float PhysDefBuff;
var(Ability) float TickTime;
var(Ability) float ShieldDuration;
var(Ability) float ShieldRadius;
var(Ability) array<HLW_StatusEffect> StatusEffectsToApplyOnHit;
var(Sound) SoundCue AuraSound;

var(Ability) float ShieldDurationCounter;
var(Ability) bool bCanShieldDecal;
var HLW_AimingDecal ShieldDecal;

var float radiusThisUse;
var HLW_Projectile_FrostShield TheShield;

var SoundCue ActivationSound;

replication
{
	if (bNetDirty)
		TheShield;
}


state Aiming
{
	simulated function BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		AimingDecal.SetRadius(ShieldRadius); 
	}
}

simulated function ActivateAbility()
{
	local int i;
	local HLW_StatusEffect_Buff PhysicalDefBuff;
	local HLW_Pawn Victim;
	local Vector V;

	super.ActivateAbility();

	if(Role == ROLE_Authority)
	{
		V.X = 0;
		V.Y = 0;
		V.Z = 0;

		// Store the radius the shield should have in class scope.
		//      We need to do this so that, if the ability levels up while the shield is active, the
		//      shield will maintain the radius that it had when it was activated.
		radiusThisUse = ShieldRadius;

		// Apply the defense buff
		PhysicalDefBuff = Spawn(class 'HLW_StatusEffect_Buff');
		PhysicalDefBuff.StatToAffect = HLW_Stat_PhysicalDefense;
		PhysicalDefBuff.BuffAmount = PhysDefBuff;
		PhysicalDefBuff.Duration = ShieldDuration;
		HLW_Pawn(OwnerPC.Pawn).ApplyStatusEffect(PhysicalDefBuff, HLW_Pawn(OwnerPC.Pawn).Controller);

		// Spawn the shield
		TheShield = Spawn(class'HLW_Projectile_FrostShield', Self,, OwnerPC.Pawn.Location);
		if(TheShield != none && !TheShield.bDeleteMe)
		{
			// Set the radius of the shield so it can scale it's mesh and collision
			TheShield.MyRadius = radiusThisUse;

			TheShield.LifeSpan = ShieldDuration;

			// Start up the projectile
			TheShield.Init( V );
			TheShield.MyCaster = HLW_Pawn_Class(OwnerPC.Pawn);
			TheShield.SetHidden(false);

			// Start the timer for damage
			SetTimer(TickTime, true, 'TickRadiusDamage');
		}
		
		HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = ActivationSound;
		HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
		
		PlaySound(AuraSound,,,, OwnerPC.Pawn.Location);
	}

	foreach VisibleCollidingActors(class'HLW_Pawn', Victim, radiusThisUse, OwnerPC.Pawn.Location)
	{
		if (Victim != none && Victim != OwnerPC.Pawn)
		{
			for (i = 0; i < StatusEffectsToApplyOnHit.Length; i++)
			{
				if (StatusEffectsToApplyOnHit[i] != none)
				{
					//`log("Applying status effect " @ StatusEffectsToApplyOnHit[i] @ StatusEffectsToApplyOnHit[i].Duration);
					Victim.ApplyStatusEffect(StatusEffectsToApplyOnHit[i], OwnerPC, TheShield);
				}
			}
		}
	}
	
	if(ShieldDecal == None)
	{
		ShieldDecal = Spawn(class'HLW_AimingDecal',,, OwnerPC.Pawn.Location, Rot(-16384, 0, 0));	
		ShieldDecal.SetRadius(ShieldRadius);
		ShieldDecal.MatInst.SetScalarParameterValue('AbleToCast', 1);
	}
	
	ShieldDecal.MatInst.SetScalarParameterValue('CastingTime', 0.0);
	ShieldDurationCounter = 0;
	ShieldDecal.SetLocation(OwnerPC.Pawn.Location);
	ShieldDecal.SetHidden(false);
	bCanShieldDecal = true;
	
	// Start the timer for the shield duration
	SetTimer(ShieldDuration, false, 'OnFrostShieldExpire');
	
	if(HLW_Pawn_Class_Mage(OwnerPC.Pawn) != None)
	{
		HLW_Pawn_Class_Mage(OwnerPC.Pawn).PlayCustomAnim("TPU", 'Mage_Cast_End', 1, 1, 0.15);
	}

	ConsumeResources();
	StartCooldown();
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	
	if(bCanShieldDecal)
	{
		ShieldDurationCounter += DeltaTime;
		ShieldDecal.MatInst.SetScalarParameterValue('CastingTime', FMin(ShieldDurationCounter / ShieldDuration, 1.0f));

		if(OwnerPC.Pawn != None)
		{
			ShieldDecal.SetLocation(OwnerPC.Pawn.Location);
		}
	}
}

simulated function LevelUp()
{
	super.LevelUp();
	
	BaseDamagePerTick.Upgrade(AbilityLevel);
}


function TickRadiusDamage()
{
	local int DamageAmount;

	// Damage to deal = Base Damage + (Magical Power * X%)
	DamageAmount =  BaseDamagePerTick.CurrentValue + (OwnerPC.GetPRI().MagicalPower * MagPowPercentageAsDamage);

	if(OwnerPC != none && OwnerPC.Pawn != none)
	{
		HurtRadius(
			DamageAmount,                   // Damage
			radiusThisUse,                  // Radius
			class'HLW_DamageType_Magical',  // Damage Type
			0,                              // Momentum
			OwnerPC.Pawn.Location,          // Radius Origin
			OwnerPC.Pawn,                   // Ignored Actor
			OwnerPC,                        // Instigator
			true); 
	}
}

simulated function OnFrostShieldExpire()
{
	ClearTimer('TickRadiusDamage');
	ClearTimer('OnFrostShieldExpire');

	if (TheShield != none)
	{
		TheShield.ProjEffects.KillParticlesForced();
		TheShield.Destroy();
	}
	
	if(ShieldDecal != None)
	{
		ShieldDecal.SetHidden(true);
	}
	
	bCanShieldDecal = false;
	ShieldDurationCounter = 0;

	AbilityComplete();
}

simulated function AbilityComplete(bool bIsPremature = false)
{
	if(bIsPremature)
	{
		if(ShieldDecal != None)
		{
			ShieldDecal.SetHidden(true);	
		}
	}
	
	super.AbilityComplete(bIsPremature);	
}

DefaultProperties
{
	ActivationSound=SoundCue'HLW_Package_Voices.Mage.Ability_FrostShield'
	
	AimType=HLW_AAT_Fixed

	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=35
		Factor=0.4
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=12.0
		//Factor=0.05
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CastTimeParameter
		BaseValue=0.0
		//Factor=1.05
		UpgradeType=HLW_UT_None
	End Object
	CastTime=CastTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=DamageParameter
		BaseValue=1.0
		Factor=0.4
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	BaseDamagePerTick=DamageParameter
	
	MagPowPercentageAsDamage=0.15

	PhysDefBuff=0.4
	ShieldDuration=6.0
	ShieldRadius=350.0
	TickTime=1.0f

	AuraSound=SoundCue'HLW_Package_Chris.SFX.Mage_FrostShield_Aura'
	DecalImage=Texture2D'HLW_Package_Lukas.Textures.SpellSymbol_FrostShield'
}
