class HLW_StatusEffect extends Actor
	DependsOn(HLW_Pawn);

// CJL TODO: Give status effects variables for whether it affects/ignores teammates/enemies/self
// Handle that logic in the status effects so we don't have to worry about it elsewhere

var float Duration;
var float Period; // How often the effect updates

var string EffectName;

var HLW_Pawn EffectTarget;
var Controller EffectInstigator;
var Actor EffectOwner;

/*
 * Sub-class must ALWAYS call the super of this function FIRST.
 */
function Initiate(HLW_Pawn EffectTargetIN, Controller EffectInstigatorIN, optional Actor EffectOwnerIN)
{
	self.EffectTarget = EffectTargetIN;
	self.EffectInstigator = EffectInstigatorIN;
	self.EffectOwner = EffectOwnerIN == none ? EffectInstigator : EffectOwnerIN;

	if (EffectTarget != none)
	{
		SetTimer(Duration, false, 'Expire');

		if (Period > 0)
		{
			SetTimer(Period, true, 'EffectTick');
		}
	}
}

// Called every <Period> seconds until the effect expires
function EffectTick();

/*
 * Sub-class must ALWAYS call the super of this function LAST.
 */
function Expire()
{
	ClearTimer('EffectTick');

	// The effect has expired prematurely
	if (!HasExpired())
	{
		ClearTimer('Expire');
	}

	if (EffectTarget != none)
	{
		EffectTarget.RemoveStatusEffect(self);
	}

	// Should this be called, or will garbage collection take care of it?
	//Destroy();
}

function bool HasExpired()
{
	return !IsTimerActive('Expire');
}

simulated function bool CanBeAppliedTo(HLW_Pawn Target, Controller EffectInstigatorIN);

defaultproperties
{
	Duration=5.0f
	Period=0.5f
	EffectName="Not Named Status Effect"
}