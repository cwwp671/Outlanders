/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_StatusEffect_Buff extends HLW_StatusEffect;

enum HLW_Stat
{
	HLW_Stat_MovementSpeed, HLW_Stat_AttackSpeed, HLW_Stat_PhysicalPower,
	HLW_Stat_MagicalPower, HLW_Stat_PhysicalDefense, HLW_Stat_MagicalDefense,
	HLW_Stat_CooldownReduction,	HLW_Stat_Resistance, HLW_Stat_HP5, HLW_Stat_MP5,
	HLW_Stat_ManaMax, HLW_Stat_HealthMax, HLW_Stat_None
};

var(Buff) HLW_Stat StatToAffect;
var(Buff) float BuffAmount;
var HLW_PlayerReplicationInfo TargetPRI;

function Initiate(HLW_Pawn EffectTargetIN, Controller EffectInstigatorIN, optional Actor EffectOwnerIN)
{
	local HLW_Pawn_Class ClassPawn;

	super.Initiate(EffectTargetIN, EffectInstigatorIN, EffectOwnerIN);

	ClassPawn = HLW_Pawn_Class(EffectTargetIN);

	if (ClassPawn != none && ClassPawn.GetPRI() != none)
	{
		TargetPRI = ClassPawn.GetPRI();

		ToggleBuff(true);
	}
}

// This is only meant to be called from within the class itself. It is unsafe to use it anywhere else.
function ToggleBuff(bool bToggleOn)
{
	BuffAmount = bToggleOn ? BuffAmount : -BuffAmount;

	switch(StatToAffect)
	{
	case HLW_Stat.HLW_Stat_AttackSpeed:
		TargetPRI.SetAttackSpeed(TargetPRI.AttackSpeed + BuffAmount);
		break;
	case HLW_Stat.HLW_Stat_CooldownReduction:
		TargetPRI.SetCooldownReduction(TargetPRI.CooldownReduction + BuffAmount);
		break;
	case HLW_Stat.HLW_Stat_HealthMax:
		TargetPRI.SetHealthMax(TargetPRI.HLW_HealthMax + BuffAmount);
		break;
	case HLW_Stat.HLW_Stat_HP5:
		TargetPRI.SetHP5(TargetPRI.HP5 + BuffAmount);
		break;
	case HLW_Stat.HLW_Stat_MagicalDefense:
		TargetPRI.SetMagicalDefense(TargetPRI.MagicalDefense + BuffAmount);
		break;
	case HLW_Stat.HLW_Stat_MagicalPower:
		TargetPRI.SetMagicalPower(TargetPRI.MagicalPower + BuffAmount);
		break;
	case HLW_Stat.HLW_Stat_ManaMax:
		TargetPRI.SetManaMax(TargetPRI.ManaMax + BuffAmount);
		break;
	case HLW_Stat.HLW_Stat_MovementSpeed:
			TargetPRI.SetMovementSpeed(TargetPRI.MovementSpeed + BuffAmount);
		break;
	case HLW_Stat.HLW_Stat_MP5:
		TargetPRI.SetMP5(TargetPRI.MP5 + BuffAmount);
		break;
	case HLW_Stat.HLW_Stat_PhysicalDefense:
		TargetPRI.SetPhysicalDefense(TargetPRI.PhysicalDefense + BuffAmount);
		break;
	case HLW_Stat.HLW_Stat_PhysicalPower:
		TargetPRI.SetPhysicalPower(TargetPRI.PhysicalPower + BuffAmount);
		break;
	case HLW_Stat.HLW_Stat_Resistance:
		TargetPRI.SetResistance(TargetPRI.Resistance + BuffAmount);
		break;
	case HLW_Stat.HLW_Stat_None:
		break;
	default:
		`warn("What the BUCK stat is THIS?!?!?!@: " @ StatToAffect @ " amount " @ BuffAmount);
	}
}

function Expire()
{
	ToggleBuff(false);

	super.Expire();
}

simulated function bool CanBeAppliedTo(HLW_Pawn Target, Controller EffectInstigatorIN)
{
	return (Target.IsSameTeam(EffectInstigatorIN.Pawn) || EffectInstigatorIN.Pawn == Target);
}

defaultproperties
{
	Duration=5.0f
	Period=0.0f
	EffectName="Not Named Status Effect"
	StatToAffect=HLW_Stat_None
	BuffAmount=0.0
}