/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Ability_Charge extends HLW_Ability;

var(Ability) HLW_UpgradableParameter Damage;
var(Ability) HLW_UpgradableParameter NumberAllowedHits;
var(Ability) HLW_UpgradableParameter StunDuration;
var(Ability) SoundCue VoiceClip;
var(Ability) float PhysPowPercentageAsDamage;
var(Ability) float ChargeDuration;
var(Ability) float ChargeSpeed;
var(Ability) float ChargeDistance;
var(Ability) int ChargeForce;
var(Ability) protectedwrite int numHits;

simulated function ActivateAbility()
{
	super.ActivateAbility();
	
	OwnerPC.Pawn.Weapon.GotoState('Active');
	
	ConsumeResources();
	
	if(OwnerPC.Pawn != None)
	{
		if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).UpperStateList.ActiveChildIndex != _CHARGE)
		{
			HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERSTATE, _CHARGE);
		}
	
		if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).LowerStateList.ActiveChildIndex != _CHARGE)
		{
			HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERSTATE, _CHARGE);
		}
	
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERCHARGE, _PRECHARGE, 0.0364625);
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERCHARGE, _PRECHARGE, 0.0364625);
	}
	
	GoToState('Charging');
}

reliable server function MovePlayer(Vector newVel);

state Charging
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERCHARGE, _CHARGING, 0.0989625);
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERCHARGE, _CHARGING, 0.0989625);
		HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetCharging();

		if (Role == ROLE_Authority)
		{
			HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver = VoiceClip;
			HLW_Pawn_Class(OwnerPC.Pawn).PlayVoiceOver(HLW_Pawn_Class(OwnerPC.Pawn).VoiceOver);
		}
		
		OwnerPC.Pawn.JumpZ = 0;
		OwnerPC.Pawn.bJumpCapable = false;
		
		SetTimer(ChargeDuration, false, 'EndCharge');
	}
	
	simulated function Tick(float DeltaTime)
	{	
		local Vector ChargeDirection;
		
		super.Tick(DeltaTime);
		
		if(OwnerPC.Pawn.Physics != PHYS_Falling)
		{
			ChargeDirection = Vector(Normalize(OwnerPC.Pawn.Rotation));
		
			if(OwnerPC != None && OwnerPC.Pawn != none)
			{		
				OwnerPC.Pawn.GroundSpeed = (HLW_Pawn_Class(OwnerPC.Pawn).BaseMovementSpeed + ChargeSpeed);
				OwnerPC.Pawn.Velocity = ChargeDirection * OwnerPC.Pawn.GroundSpeed;
			}
		}
	}
	
	simulated function EndCharge()
	{
		ClearTimer('EndCharge');

		StartCooldown();
		AbilityComplete();
		
		if(OwnerPC.Pawn != None)
		{
			OwnerPC.Pawn.JumpZ = OwnerPC.Pawn.default.JumpZ;
			OwnerPC.Pawn.bJumpCapable = true;
		}
		
		GotoState('Inactive');
	}

	simulated function EndState(Name NextState)
	{
		super.EndState(NextState);
		
		ClearTimer('EndCharge');
		
		if(OwnerPC.Pawn != None)
		{		
			if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).UpperStateList.ActiveChildIndex == _CHARGE)
			{
				HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(UPPERSTATE, _NORMAL);
			}
	
			if(HLW_Pawn_Class_Warrior(OwnerPC.Pawn).LowerStateList.ActiveChildIndex == _CHARGE)
			{
				HLW_Pawn_Class_Warrior(OwnerPC.Pawn).SetAnimState(LOWERSTATE, _NORMAL);
			}
		
			HLW_Pawn_Class_Warrior(OwnerPC.Pawn).DisableCharging();
			HLW_Pawn_Class_Warrior(OwnerPC.Pawn).FlushChargeHitActors();
		}
	}
	
	simulated function Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
	{
		local HLW_StatusEffect_Stun ChargeHitStun;
		
		numHits++;

		HLW_Pawn(Other).TakeDamage(
			Damage.CurrentValue + (OwnerPC.GetPRI().PhysicalPower * PhysPowPercentageAsDamage),
			OwnerPC,
			Location,
			vect(0,0,0),
			class'HLW_DamageType_Physical');

		ChargeHitStun = Spawn(class'HLW_StatusEffect_Stun', OwnerPC.Pawn);
		ChargeHitStun.Duration = StunDuration.CurrentValue;
		HLW_Pawn(Other).ApplyStatusEffect(ChargeHitStun, OwnerPC);
		
		if (numHits >= NumberAllowedHits.CurrentValue)
		{
			EndCharge();
		}
	}
}

simulated function LevelUp()
{
	super.LevelUp();
	
	Damage.Upgrade(AbilityLevel);
	StunDuration.Upgrade(AbilityLevel);
	NumberAllowedHits.Upgrade(AbilityLevel);
}

simulated function AbilityComplete(bool bIsPremature = false)
{
	if(bIsPremature == true)
	{
		ClearTimer('EndCharge');
		StartCooldown();
	}
	
	super.AbilityComplete(bIsPremature);
}

defaultproperties
{
	PhysPowPercentageAsDamage=0.4
	ChargeDuration=4.0
	ChargeSpeed=950
	ChargeForce=100000
	numHits=0
	ChargeDistance=5200
	
	bPreventsPrimaryAttacksWhileActive=true
	bPreventsSecondaryAttacksWhileActive=true
	bPreventsOtherAbilitiesWhileActive=true
	bPreventsMoveInputWhileActive=true

	VoiceClip=SoundCue'HLW_Package_Voices.Warrior.Ability_Charge'
	DecalImage=Texture2D'HLW_Package_Lukas.Textures.SpellSymbol_Charge'
	
	AimType=HLW_AAT_Instant

	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=25.0
		Factor=0.08
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter

	Begin Object Class=HLW_UpgradableParameter Name=CastTimeParameter
		BaseValue=0.0
		UpgradeType=HLW_UT_None
	End Object
	CastTime=CastTimeParameter

	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=10.0
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter

	Begin Object Class=HLW_UpgradableParameter Name=DamageParameter
		BaseValue=40
		Factor=0.1
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	Damage=DamageParameter

	Begin Object Class=HLW_UpgradableParameter Name=StunDurationParameter
		BaseValue=1.5
		Factor=0.1
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	StunDuration=StunDurationParameter

	Begin Object Class=HLW_UpgradableParameter Name=NumberAllowedHitsParameter
		BaseValue=1
		Factor=0
		LevelFrequency=2
		UpgradeType=HLW_UT_AddFixedValue
	End Object
	NumberAllowedHits=NumberAllowedHitsParameter
}