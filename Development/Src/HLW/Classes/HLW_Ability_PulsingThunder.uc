/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Ability_PulsingThunder extends HLW_Ability;

var(Ability) float Radius;
var(Ability) float PulsePeriod;
var(Ability) float MagPowPercentageAsDamage;
var(Ability) int PulseMomentum;
var(Ability) HLW_UpgradableParameter BaseDamagePerPulse;
var(Ability) HLW_UpgradableParameter NumberOfPulses;
var(Sound) SoundCue InitiateSound;
var(Sound) SoundCue PulseSound;
var(Ability) HLW_Decal_DOT PulseDecal;

var ParticleSystem PulseParticle;
var HLW_Projectile_PulsingThunder ThunderProjectile;
var int PulsesShot;
var(Ability) array<HLW_StatusEffect> StatusEffectsToApplyOnHit;

var SoundCue ActivationSound;
var float ConsecutivePulsePercentage;
var int ConescutivePulseKnockback;

replication
{
	if (bNetDirty)
		ThunderProjectile;
}

state Aiming
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		AimingDecal.SetRadius(Radius);
	}
}

simulated function ActivateAbility()
{
	local int i;
	local HLW_Pawn Victim;
	local Vector SpawnLocation;
	local Vector V;
	local Pawn PawnToFollow;

	V.X = 0;
	V.Y = 0;
	V.Z = 0;

	super.ActivateAbility();
	
	PawnToFollow = TraceHitPawn == none ? OwnerPC.Pawn : TraceHitPawn;
	
	if(Role == ROLE_Authority)
	{
		SpawnLocation = PawnToFollow.Location;

		ThunderProjectile = Spawn(class'HLW_Projectile_PulsingThunder', Self,, SpawnLocation,,,true);
				
		if(ThunderProjectile != none && !ThunderProjectile.bDeleteMe)
		{
			ThunderProjectile.PawnToFollow = PawnToFollow;
			ThunderProjectile.Init( V );//Vector(Normalize(Rotator(TraceHitPawn.Location - SpawnLocation))) );
			ThunderProjectile.SetHidden(false);
			ThunderProjectile.Damage = 0;
		}
		
		HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = ActivationSound;
		HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
		
		PlaySound(InitiateSound,,,, OwnerPC.Pawn.Location);
	}
	
	if(Role < ROLE_Authority)
	{
		PulseDecal = Spawn(class'HLW_Decal_DOT', OwnerPC,, PawnToFollow.Location, Rot(-16384, 0, 0));
		PulseDecal.SetRadius(Radius);
		PulseDecal.Activate(PawnToFollow, NumberOfPulses.CurrentValue - 1, PulsePeriod);
	}
	
	if(HLW_Pawn_Class_Mage(OwnerPC.Pawn) != None)
	{
		HLW_Pawn_Class_Mage(OwnerPC.Pawn).PlayCustomAnim("TPU", 'Mage_Cast_End', 1, 1, 0.15);
	}
	
	foreach VisibleCollidingActors(class'HLW_Pawn', Victim, Radius, OwnerPC.Pawn.Location)
	{
		if (Victim != none)
		{
			for (i = 0; i < StatusEffectsToApplyOnHit.Length; i++)
			{
				if (StatusEffectsToApplyOnHit[i] != none)
				{
					Victim.ApplyStatusEffect(StatusEffectsToApplyOnHit[i], OwnerPC, ThunderProjectile);
				}
			}
		}
	}

	ConsumeResources();
	//StartCooldown();
	//AbilityComplete();
	HandlePulsing();
	
}

simulated function HandlePulsing()
{
	local Pawn PawnToPulseFrom;
	local int DamageFromMagPower;
	
	// CJL need to implement when this abiltiy is compelte so we can remove the projectile
	// would want to call that function if the number of pulses is 0
	if (NumberOfPulses.CurrentValue > 0)
	{	
		if(Role == ROLE_Authority)
		{
			PawnToPulseFrom = ThunderProjectile.PawnToFollow == none ? TraceHitPawn : ThunderProjectile.PawnToFollow;

			if (PawnToPulseFrom != none)
			{
				DamageFromMagPower = OwnerPC.GetPRI().MagicalPower * MagPowPercentageAsDamage;
		
				if(PulsesShot == 0)
				{
					HurtRadius(
						BaseDamagePerPulse.CurrentValue + DamageFromMagPower,    // Damage
						Radius,	                                    // Radius
						class'HLW_DamageType_Magical',	            // Damage Type
						PulseMomentum,	                            // Momentum
						PawnToPulseFrom.Location,	                // Radius Origin
						,	                                        // Ignored Actor
						OwnerPC,	                                // Instigator
						true);										// Do Full Damage?
				}
				else
				{
					HurtRadius(
						(BaseDamagePerPulse.CurrentValue + DamageFromMagPower) * ConsecutivePulsePercentage,    // Damage
						Radius,	                                    // Radius
						class'HLW_DamageType_Magical',	            // Damage Type
						ConescutivePulseKnockback,	                // Momentum
						PawnToPulseFrom.Location,	                // Radius Origin
						,	                                        // Ignored Actor
						OwnerPC,	                                // Instigator
						true);
				}                                    
					
				if(HLW_Pawn_Class(PawnToPulseFrom) != None)
				{
					HLW_Pawn_Class(PawnToPulseFrom).SpawnEmitter(PulseParticle,
																 PawnToPulseFrom.Location,
																 PawnToPulseFrom.Rotation,
																 true,
																 Radius / 600);
				}

				PlaySound(PulseSound,,,, OwnerPC.Pawn.Location);
			}

			PulsesShot++;

			if (PulsesShot < NumberOfPulses.CurrentValue)
			{
				SetTimer(PulsePeriod, false, 'HandlePulsing');
			}
			else
			{
				// Need this dumb timer because replication is slow
				if (NumberOfPulses.CurrentValue == 1)
				{
					SetTimer(1.0f,false,'DonePulsing');
				}
				else
				{
					DonePulsing();
				}
			}
		}
	}
	else
	{
		DonePulsing();
	}
}

// Need this dumb timer because replication is slow
simulated function DonePulsing()
{
	ClearTimer('DonePulsing');
	PulsesShot = 0;

	if (ThunderProjectile != none)
	{
		ThunderProjectile.Destroy();
	}
	
	StartCooldown();
	AbilityComplete();
	
	ClientDonePulsing();
}

reliable client function ClientDonePulsing()
{
	ClearTimer('DonePulsing');
	PulsesShot = 0;

	if (ThunderProjectile != none)
	{
		ThunderProjectile.Destroy();
	}
	
	StartCooldown();
	AbilityComplete();
}

simulated function LevelUp()
{
	super.LevelUp();
	
	NumberOfPulses.Upgrade(AbilityLevel);
	BaseDamagePerPulse.Upgrade(AbilityLevel);
}

DefaultProperties
{
	ActivationSound=SoundCue'HLW_Package_Voices.Mage.Ability_PulsingThunder'
	
	AimType=HLW_AAT_ActorTarget
	ConsecutivePulsePercentage=0.25
	ConescutivePulseKnockback=0
	
	Radius=350.0
	PulsePeriod=.75
	MagPowPercentageAsDamage=0.25
	PulseMomentum=40000
	
	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=38
		Factor=0.4
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=9.0
		//Factor=0.05
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=RangeParameter
		BaseValue=850
		UpgradeType=HLW_UT_None
	End Object
	Range=RangeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CastTimeParameter
		BaseValue=0.0
		//Factor=1.5
		UpgradeType=HLW_UT_None
	End Object
	CastTime=CastTimeParameter

	Begin Object Class=HLW_UpgradableParameter Name=BaseDamagePerPulseParameter
		BaseValue=50
		Factor=1
		UpgradeType=HLW_UT_AddFixedValue
	End Object
	BaseDamagePerPulse=BaseDamagePerPulseParameter

	Begin Object Class=HLW_UpgradableParameter Name=NumberOfPulsesParameter
		BaseValue=1
		Factor=1
		LevelFrequency=0
		UpgradeType=HLW_UT_AddFixedValue
	End Object
	NumberOfPulses=NumberOfPulsesParameter

	PulsesShot=0

	InitiateSound=SoundCue'HLW_Package_Chris.SFX.Mage_PulsingThunder_Initial'
	PulseSound=SoundCue'HLW_Package_Chris.SFX.Mage_PulsingThunder_Pulse'
	DecalImage=Texture2D'HLW_Package_Lukas.Textures.SpellSymbol_PulsingThunder'
	PulseParticle=ParticleSystem'HLW_Package_Randolph.Farticles.Particle_PulsingThunder'
}
