class HLW_Ability_BaseballSwing extends HLW_Ability;

var(Ability) HLW_UpgradableParameter Damage;
var(Ability) SoundCue VoiceClip;
var(Ability) float PhysPowPercentageAsDamage;
var(Ability) float KnockbackStrength;
var(Ability) float KnockupStrength;

var float AuraAmount;
var float AuraPercentUsage;

simulated state Aiming
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		if(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).UpperStateList.ActiveChildIndex != BASEBALLSWING)
		{
			HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERSTATE, BASEBALLSWING);
		}
		
		HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERBASEBALLSWING, PRESWING, 0.01945); //0.3750
		
		AimingDecal.SetRadius(50);
	}
	
	
	
	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
	}
	
}

simulated function StopAimAnimation()
{
	if(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).UpperStateList.ActiveChildIndex == BASEBALLSWING)
	{
		HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERSTATE, NORMAL, 0.25);
	}
}

simulated function ActivateAbility()
{	
	super.ActivateAbility();
		
	OwnerPC.Pawn.Weapon.GotoState('Active');
	
	ConsumeResources();
	StartCooldown();

	if (Role == ROLE_Authority)
	{
		if(HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]) != None)
		{
			AuraAmount = HLW_Ability_Aura(OwnerPC.GetPRI().Abilities[0]).UseAura(AuraPercentUsage);
			//`log("AURA AMOUNT"@AuraAmount);
		}
		
		HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = VoiceClip;
		HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
	}

	GoToState('Swinging');
}

simulated state Swinging
{
	simulated function BeginState(Name PreviousStateName)
	{
		HLW_Melee_Hammer(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).Weapon).BaseballMomentum.X = KnockbackStrength * (AuraAmount + 1);
		HLW_Melee_Hammer(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).Weapon).BaseballMomentum.Y = KnockbackStrength * (AuraAmount + 1);
		HLW_Melee_Hammer(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).Weapon).BaseballMomentum.Z = KnockupStrength * (AuraAmount + 1);
		HLW_Melee_Hammer(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).Weapon).BaseballDamage = (Damage.CurrentValue + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamage)) * (AuraAmount + 1);
		//HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERSTATE, BASEBALLSWING);
		HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERBASEBALLSWING, SWING); //0.3750
		//HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERSTATE, BASEBALLSWING, 0.129425);
		SetTimer(0.4278, false, 'EndSwing');
	}
	
	simulated function EndSwing()
	{
		GoToState('Inactive');	
	}
	
	simulated function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);
		
		HLW_Melee_Hammer(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).Weapon).UpdateTracers(HLW_Melee_Hammer(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).Weapon).TracersTP);
		HLW_Melee_Hammer(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).Weapon).TraceBaseball();
	}
	
	simulated function EndState(Name NextStateName)
	{
		HLW_Melee_Wep(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).Weapon).AttackHitActors.Remove(0, HLW_Melee_Wep(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).Weapon).AttackHitActors.Length);
		HLW_Melee_Hammer(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).Weapon).BaseballMomentum = vect(0, 0, 0);
		HLW_Melee_Hammer(HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).Weapon).BaseballDamage = 0;
		HLW_Pawn_Class_Barbarian(OwnerPC.Pawn).SetAnimState(UPPERSTATE, NORMAL, 0.25);
		
		AbilityComplete();
	}
}

simulated function LevelUp()
{
	super.LevelUp();
	
	Damage.Upgrade(AbilityLevel);
}

DefaultProperties
{
	AimType=HLW_AAT_Fixed
	
	//bPreventsMoveInputWhileActive=true
	bPreventsOtherAbilitiesWhileActive=true
	bPreventsPrimaryAttacksWhileActive=true
	bPreventsSecondaryAttacksWhileActive=true
	
	KnockbackStrength=75000
	KnockupStrength=50000
	PhysPowPercentageAsDamage=0.5
	AuraPercentUsage=0.2
	
	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=25
		Factor=0.2
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
		BaseValue=200.0
		UpgradeType=HLW_UT_None
	End Object
	Range=RangeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CastTimeParameter
		BaseValue=0.0
		UpgradeType=HLW_UT_None
	End Object
	CastTime=CastTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=DamageParameter
		BaseValue=60.0
		Factor=0.3
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	Damage=DamageParameter
	
	DecalImage=Texture2D'HLW_Package_Lukas.Textures.SpellSymbol_BaseballSwing'
	
	VoiceClip=SoundCue'HLW_Package_Voices.Barbarian.Ability_Swing'
}