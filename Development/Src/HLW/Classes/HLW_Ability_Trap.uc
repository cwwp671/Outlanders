/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Ability_Trap extends HLW_Ability;

var HLW_Archer_PoisonTrap PoisonTrap;
var HLW_Archer_BearTrap BearTrap;
var HLW_Archer_ExplosionTrap ExplosionTrap;
var SoundCue SetSound;
var(Ability) HLW_UpgradableParameter BearTrapStunDuration;
var(Ability) HLW_UpgradableParameter ExplosionTrapDamage;
var(Ability) HLW_UpgradableParameter ExplosionTrapMomentum;
var(Ability) HLW_UpgradableParameter PoisonTrapPoisonDuration;
var(Ability) HLW_UpgradableParameter PoisonTrapDamage;
var(Ability) float PhysPowPercentAsDamage;

var Name AnimTrap;
var float AnimTrapLength;
var int TrapIndex;

enum TrapType
{
	HLW_POISON,
	HLW_EXPLOSIVE,
	HLW_BEAR
};

simulated function ActivateAbility()
{
	super.ActivateAbility();
	ConsumeResources();
	StartCooldown();
	AbilityComplete();
	GoToState('SettingTrap');
}

//simulated function Tick(float DeltaTime)
//{
	//`log("Trap:"@TrapIndex);	
//}

state Aiming
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		switch(TrapIndex)
		{
			case HLW_POISON:
				AimingDecal.SetRadius(class'HLW_Archer_PoisonTrap'.default.ActivationRadius);
				DecalImage = Texture2D'HLW_Package_Lukas.Textures.SpellSymbol_Trap_Poison';
				AimingDecal.MatInst.SetTextureParameterValue('SpellSymbol', DecalImage);
				break;
			case HLW_BEAR:
				DecalImage = Texture2D'HLW_mapProps.guimaterials.SpellSymbol_None';
				AimingDecal.MatInst.SetTextureParameterValue('SpellSymbol', DecalImage);
				AimingDecal.SetRadius(class'HLW_Archer_BearTrap'.default.ActivationRadius);
				break;
			case HLW_EXPLOSIVE:
				DecalImage = Texture2D'HLW_Package_Lukas.Textures.SpellSymbol_Trap_Explosion';
				AimingDecal.MatInst.SetTextureParameterValue('SpellSymbol', DecalImage);
				AimingDecal.SetRadius(class'HLW_Archer_ExplosionTrap'.default.ActivationRadius);
				break;
		}
	}
}

simulated state SettingTrap
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		if(Role < ROLE_Authority)
		{
			AnimSetTrap();
			PlaySound(SetSound,,,, HitLocation);
		}
		else
		{
			switch(TrapIndex)
			{
				case HLW_POISON:
					SpawnPoisonTrap();
					break;
				case HLW_BEAR:
					SpawnBearTrap();
					break;
				case HLW_EXPLOSIVE:
					SpawnExplosiveTrap();
					break;
			}
		}
		
		GoToState('Inactive');
	}
	
	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);	
	}
}

simulated function AnimSetTrap()
{
	if(HLW_Pawn_Class_Archer(OwnerPC.Pawn) != None)
	{
		HLW_Pawn_Class_Archer(OwnerPC.Pawn).PlayCustomAnim("TPB", AnimTrap, AnimTrapLength);	
	}
}

simulated function SpawnPoisonTrap()
{
	local Vector SpawnLocation;
	local float rawTotalPoisonDamage, trueTotalPoisonDamage, truePoisonTickDamage;
		
	if(Role == ROLE_Authority)
	{
		SpawnLocation = OwnerPC.Pawn.Location;
		SpawnLocation.Z -= OwnerPC.Pawn.GetCollisionHeight();
			
		PoisonTrap = Spawn(class'HLW_Archer_PoisonTrap', OwnerPC,, SpawnLocation, OwnerPC.Pawn.Rotation);
		PoisonTrap.SetOwner(OwnerPC);
		//PoisonTrap.SetColor(ColorToLinearColor(HLW_Pawn_Class(OwnerPC.Pawn).GetPRI().Team.TeamColor));
		PoisonTrap.PoisonDuration = PoisonTrapPoisonDuration.CurrentValue;

		rawTotalPoisonDamage = PoisonTrapDamage.CurrentValue * PoisonTrapPoisonDuration.CurrentValue;   // Get the total damage that would be done from poison over the duration
		trueTotalPoisonDamage = rawTotalPoisonDamage + (PhysPowPercentAsDamage * OwnerPC.GetPRI().PhysicalPower); // Add a percentage of PP to that total poison damage amount
		truePoisonTickDamage = trueTotalPoisonDamage / PoisonTrapPoisonDuration.CurrentValue; // With this new total, calculate what the new individual tick damage should be

		PoisonTrap.PoisonDamage = truePoisonTickDamage;
	}
}

simulated function SpawnExplosiveTrap()
{
	local Vector SpawnLocation;
		
	if(Role == ROLE_Authority)
	{
		SpawnLocation = OwnerPC.Pawn.Location;
		SpawnLocation.Z -= OwnerPC.Pawn.GetCollisionHeight();
			
		ExplosionTrap = Spawn(class'HLW_Archer_ExplosionTrap', OwnerPC,, SpawnLocation, OwnerPC.Pawn.Rotation);
		ExplosionTrap.SetOwner(OwnerPC);
		//ExplosionTrap.SetColor(ColorToLinearColor(HLW_Pawn_Class(OwnerPC.Pawn).GetPRI().Team.TeamColor));
		ExplosionTrap.ExplosiveDamage = ExplosionTrapDamage.CurrentValue + (PhysPowPercentAsDamage * OwnerPC.GetPRI().PhysicalPower);
		ExplosionTrap.ExplosiveMomentum = ExplosionTrapMomentum.CurrentValue;
	}
}

simulated function SpawnBearTrap()
{
	local Vector SpawnLocation;
		
	if(Role == ROLE_Authority)
	{
		SpawnLocation = OwnerPC.Pawn.Location;
		SpawnLocation.Z -= OwnerPC.Pawn.GetCollisionHeight();
			
		BearTrap = Spawn(class'HLW_Archer_BearTrap', OwnerPC,, SpawnLocation, OwnerPC.Pawn.Rotation);
		BearTrap.SetOwner(OwnerPC);
		//BearTrap.SetColor(ColorToLinearColor(HLW_Pawn_Class(OwnerPC.Pawn).GetPRI().Team.TeamColor));
		BearTrap.StunDuration = BearTrapStunDuration.CurrentValue;
	}
}

simulated function string GetTrapName()
{
	switch(TrapIndex)
	{
		case HLW_POISON:
			return "Poison Trap";
			break;
		case HLW_BEAR:
			return "Bear Trap";
			break;
		case HLW_EXPLOSIVE:
			return "Explosive Trap";
			break;
		default:
			return "Can't Get Trap, You Suck";
			break;
	}
}

simulated function int GetTrap()
{
	switch(TrapIndex)
	{
		case HLW_POISON:
			return 0;
			break;
		case HLW_BEAR:
			return 2;
			break;
		case HLW_EXPLOSIVE:
			return 1;
			break;
		default:
			return 1000;
			break;
	}
}

function SetTrap(int Trap)
{
	//`log("CURRENT Trap:"@TrapIndex);
	TrapIndex = Trap;
	//`log("NEW Trap:"@TrapIndex);
	
	if(Role < ROLE_Authority)
	{
		//`log("ROLE IS CLIENT");
		ServerSetTrap(Trap);
	}
	else
	{
		ClientSetTrap(Trap);	
	}
}

reliable server function ServerSetTrap(int Trap)
{
	SetTrap(Trap);
}

reliable client function ClientSetTrap(int Trap)
{
	TrapIndex = Trap;
}

simulated function LevelUp()
{
	super.LevelUp();
	
	BearTrapStunDuration.Upgrade(AbilityLevel);
	ExplosionTrapDamage.Upgrade(AbilityLevel);
	ExplosionTrapMomentum.Upgrade(AbilityLevel);
	PoisonTrapPoisonDuration.Upgrade(AbilityLevel);
	PoisonTrapDamage.Upgrade(AbilityLevel);
}

defaultproperties
{
	AnimTrap=Archer_Traps
	AnimTrapLength=0.7917
	TrapIndex=0
	PhysPowPercentAsDamage=0.4
	
	AimType=HLW_AAT_Fixed
	
	SetSound=SoundCue'HLW_Package_Chris.SFX.Archer_Ability_Trap_Set'
	
	Begin Object Class=HLW_UpgradableParameter Name=ManaCostParameter
		BaseValue=20
		Factor=0.3
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ManaCost=ManaCostParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CooldownTimeParameter
		BaseValue=10.0
		//Factor=0.05
		UpgradeType=HLW_UT_None
	End Object
	CooldownTime=CooldownTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=CastTimeParameter
		BaseValue=0.25
		UpgradeType=HLW_UT_None
	End Object
	CastTime=CastTimeParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=BearTrapStunDurationParameter
		BaseValue=1.75
		Factor=0.14
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	BearTrapStunDuration=BearTrapStunDurationParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=ExplosionTrapDamageParameter
		BaseValue=70.0
		Factor=0.1
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ExplosionTrapDamage=ExplosionTrapDamageParameter

	Begin Object Class=HLW_UpgradableParameter Name=ExplosionTrapMomentumParameter
		BaseValue=150000
		Factor=0.02
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	ExplosionTrapMomentum=ExplosionTrapMomentumParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=PoisonTrapPoisonDurationParameter
		BaseValue=10.0
		UpgradeType=HLW_UT_None
	End Object
	PoisonTrapPoisonDuration=PoisonTrapPoisonDurationParameter
	
	Begin Object Class=HLW_UpgradableParameter Name=PoisonTrapPoisonDamageParameter
		BaseValue=10.0
		Factor=0.4
		UpgradeType=HLW_UT_AddPercentOfBase
	End Object
	PoisonTrapDamage=PoisonTrapPoisonDamageParameter
	
	DecalImage=Texture2D'HLW_Package_Lukas.Textures.SpellSymbol_Trap_Explosion'
}