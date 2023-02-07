class HLW_Ability_AmplifyAbility extends HLW_Ability;

var (Ability) HLW_UpgradableParameter Duration;
var (Ability) HLW_UpgradableParameter MagPowerIncrease;
var (Sound) SoundCue InitiateSound;
var (Sound) SoundCue AuraSound;

var ParticleSystemComponent tempParticleComponent;
var ParticleSystem tempParticles;
var HLW_Projectile_AmplifyAbility proj;

var SoundCue ActivationSound;

replication
{
	if (bNetDirty)
		proj;
}

state Aiming
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		AimingDecal.SetRadius(50);
	}
}

simulated function ActivateAbility()
{
	local HLW_StatusEffect_Buff MagPowBuff;
	local Vector V;
	V.X = 0;
	V.Y = 0;
	V.Z = 0;

	super.ActivateAbility();

	if(Role == ROLE_Authority)
	{
		// this is not the final product. just doing it this way for the current cook
		MagPowBuff = Spawn(class'HLW_StatusEffect_Buff');
		MagPowBuff.Duration = Duration.CurrentValue;
		MagPowBuff.StatToAffect = HLW_Stat_MagicalPower;
		MagPowBuff.BuffAmount = OwnerPC.GetPRI().MagicalPower * MagPowerIncrease.CurrentValue;
		HLW_Pawn(OwnerPC.Pawn).ApplyStatusEffect(MagPowBuff, OwnerPC);
		
		if(HLW_Pawn_Class_Mage(OwnerPC.Pawn) != None) //ChangeSpellPowerOnMesh
		{
			HLW_Pawn_Class_Mage(OwnerPC.Pawn).CurrentSpellPower = 10;
		}
		
		proj = Spawn(class'HLW_Projectile_AmplifyAbility', Self,, OwnerPC.Pawn.Location);
		if(proj != none && !proj.bDeleteMe)
		{
			proj.LifeSpan = Duration.CurrentValue;

			// Start up the projectile
			proj.Init( V );
			proj.MyCaster = HLW_Pawn_Class(OwnerPC.Pawn);
			proj.SetHidden(false);
		}
		
		HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = ActivationSound;
		HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
		
		PlaySound(InitiateSound,,,, OwnerPC.Pawn.Location);
		PlaySound(AuraSound,,,, OwnerPC.Pawn.Location);
	}
	
	if(HLW_Pawn_Class_Mage(OwnerPC.Pawn) != None)
	{
		HLW_Pawn_Class_Mage(OwnerPC.Pawn).PlayCustomAnim("TPU", 'Mage_Cast_End', 1, 1, 0.15);
	}

	ConsumeResources();
	StartCooldown();

	SetTimer(Duration.CurrentValue, false, 'OnAmplifyAbilityExpire');
}


simulated function OnAmplifyAbilityExpire()
{
	AbilityComplete();

	if (proj != none)
	{
		proj.SetHidden(true);
		proj.Destroy();
		proj.ProjEffects.DeactivateSystem();
	}
	
	if(HLW_Pawn_Class_Mage(OwnerPC.Pawn) != None) //ChangeSpellPowerOnMesh
	{
		HLW_Pawn_Class_Mage(OwnerPC.Pawn).CurrentSpellPower = 0;
	}
}

simulated function LevelUp()
{
	super.LevelUp();

	Duration.Upgrade(AbilityLevel);
	MagPowerIncrease.Upgrade(AbilityLevel);
}

DefaultProperties
{
	ActivationSound=SoundCue'HLW_Package_Voices.Mage.Ability_Amplify'
	
	AimType=HLW_AAT_Fixed

	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=80
		Factor=0.4
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter

	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=45.0
		//Factor=0.075
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter

	Begin Object Class=HLW_UpgradableParameter Name=DurationParameter
		BaseValue=12.0
		UpgradeType=HLW_UT_None
	End Object
	Duration=DurationParameter

	Begin Object Class=HLW_UpgradableParameter Name=MagPowerIncreaseParameter
		BaseValue=1.0
		Factor=0.08
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	MagPowerIncrease=MagPowerIncreaseParameter

	InitiateSound=SoundCue'HLW_Package_Chris.SFX.Mage_Amplify_Initial'
	AuraSound=SoundCue'HLW_Package_Chris.SFX.Mage_Amplify_Aura'

	tempParticles=ParticleSystem'HLW_AndrewParticles.Particles.FX_Vortex_White'
	
	DecalImage=Texture2D'HLW_mapProps.guimaterials.SpellSymbol_AmplifyAlt'
}
