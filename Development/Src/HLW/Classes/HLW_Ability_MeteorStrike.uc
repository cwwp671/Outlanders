class HLW_Ability_MeteorStrike extends HLW_Ability;

var StaticMeshComponent MeteorComponent;
var Vector MeteorSpawnLocation, DecalHitLocation;

var(Ability) HLW_UpgradableParameter BaseDamage;
var(Ability) HLW_UpgradableParameter MagPowPercentageAsDamage;
var(Ability) array<HLW_StatusEffect> StatusEffectsToApplyOnHit;

var SoundCue ActivationSound;

simulated function StartCasting(optional HLW_Pawn_Class UserIn, optional bool bIsFreeAbility)
{
	local Vector SpawnLocation, DecalToMageDir;
	local Rotator CurrentEyeRotation;

	super.StartCasting(UserIn, bIsFreeAbility);

	OwnerPC.GetPlayerViewPoint(SpawnLocation, CurrentEyeRotation);
	DecalToMageDir = Vector(Normalize(Rotator(HitLocation - SpawnLocation)));

	SpawnLocation += DecalToMageDir * -(500);
	SpawnLocation.Z = Max(SpawnLocation.Z, HitLocation.Z) + 1000;

	MeteorSpawnLocation = SpawnLocation;
	DecalHitLocation = HitLocation;
}

simulated function ActivateAbility()
{
	local HLW_Projectile_Meteor TheMeteor;

	super.ActivateAbility();

	if(Role == ROLE_Authority)
	{
		TheMeteor = Spawn(class'HLW_Projectile_Meteor', Self,, MeteorSpawnLocation);
		TheMeteor.InstigatorController = OwnerPC;
		
		if(TheMeteor != none && !TheMeteor.bDeleteMe)
		{
			TheMeteor.StatusEffectsToApplyOnHit = StatusEffectsToApplyOnHit;
			TheMeteor.Init( Vector(Normalize(Rotator(DecalHitLocation - MeteorSpawnLocation))) );

			// Damage for this projectile is Base Damage + (X% of Magical Power)
			TheMeteor.Damage = BaseDamage.CurrentValue + (OwnerPC.GetPRI().MagicalPower * MagPowPercentageAsDamage.CurrentValue);
			TheMeteor.OnExplode = MeteorExploded;
			TheMeteor.HitLoc = HitLocation;
		}
		
		if(OwnerPC != none && OwnerPC.Pawn != none)
		{
			HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = ActivationSound;
			HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
		}
	}
	
	ConsumeResources();
	StartCooldown();
	AbilityComplete();
}

reliable server function MeteorExploded()
{
	HLW_Pawn_Class(OwnerPC.Pawn).SpawnEmitter(ParticleSystem'HLW_Package_Randolph.Farticles.Particle_MeteorImpact', HitLocation, Rot(0,0,0),, class'HLW_Projectile_Meteor'.default.DamageRadius / 750);	
}

simulated state Aiming
{
	simulated function BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
	
		if(HLW_Pawn(OwnerPC.Pawn) != None)
		{	
			if(HLW_Pawn(OwnerPC.Pawn).Mesh.GetSocketByName('Mage_Right_Palm') != None)
			{
				HLW_Pawn(OwnerPC.Pawn).Mesh.AttachComponentToSocket(MeteorComponent, 'Mage_Right_Palm');
				//`log("SHOULD HAVE METEOR");
			}
		}
		
		AimingDecal.SetRadius(class'HLW_Projectile_Meteor'.default.DamageRadius /** (class'HLW_Projectile_Meteor'.default.DamageRadius / 750)*/);
	}

	simulated function EndState(Name NextState)
	{
		super.EndState(NextState);

		if(OwnerPC != none && OwnerPC.Pawn != none)
		{
			HLW_Pawn(OwnerPC.Pawn).Mesh.DetachComponent(MeteorComponent);
		}
	}
}

simulated function AbilityComplete(bool IsPremature = false)
{
	super.AbilityComplete(IsPremature);
	if(HLW_Pawn_Class_Mage(OwnerPC.Pawn) != None)
	{
		HLW_Pawn_Class_Mage(OwnerPC.Pawn).PlayCustomAnim("TPU", 'Mage_Cast_End', 1, 1, 0.15);
	}
}

simulated function LevelUp()
{
	super.LevelUp();
	
	BaseDamage.Upgrade(AbilityLevel);
	MagPowPercentageAsDamage.Upgrade(AbilityLevel);
}

DefaultProperties
{
	ActivationSound=SoundCue'HLW_Package_Voices.Mage.Ability_Meteor'
	
	Begin Object Class=StaticMeshComponent Name=MeteorMesh
        StaticMesh=StaticMesh'HLW_worldProps.FirstPersonMeteorite'
        Scale=0.016f
    End Object
	MeteorComponent=MeteorMesh

	AimType=HLW_AAT_Free

	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=40
		Factor=0.3
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=15.0
		//Factor=0.05
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=RangeParameter
		BaseValue=1250.0
		UpgradeType=HLW_UT_None
	End Object
	Range=RangeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CastTimeParameter
		BaseValue=.75
		UpgradeType=HLW_UT_None
	End Object
	CastTime=CastTimeParameter

	Begin Object Class=HLW_UpgradableParameter Name=BaseDamageParameter
		BaseValue=65
		Factor=0.6
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	BaseDamage=BaseDamageParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=MagPowPercentageAsDamage
		BaseValue=0.35
		Factor=0.2
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	MagPowPercentageAsDamage=MagPowPercentageAsDamage

	DecalImage=Texture2D'HLW_mapProps.guimaterials.SpellSymbol_Meteorite'
}
