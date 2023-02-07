class HLW_Ability_Attunement extends HLW_Ability_Passive;

var(Ability) HLW_StatusEffect_Stun StunToApply;
var(Ability) HLW_StatusEffect_Burn BurnToApply;
var(Ability) HLW_StatusEffect_Slow SlowToApply;
var(Ability) float StunDuration;
var(Ability) float StunMPPercAsDuration;
var(Ability) float BurnDuration;
var(Ability) float BurnTickTime;
var(Ability) float BurnDamagePerTick;
var(Ability) float BurnMPPercAsDamage;
var(Ability) float SlowDuration;
var(Ability) float SlowPercentage;
var(Ability) float SlowMPPercAsDuration;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if(OwnerPC != None)
	{
		if (OwnerPC.Pawn != none)
		{
			// If the status effects were set in the editor, they won't be none, so we don't want to overwrite them
			if (StunToApply == none)
			{
				StunToApply = Spawn(class'HLW_StatusEffect_Stun', OwnerPC.Pawn);
				StunToApply.Duration = StunDuration + (StunMPPercAsDuration * OwnerPC.GetPRI().MagicalPower);
			}

			if (BurnToApply == none)
			{
				BurnToApply = Spawn(class'HLW_StatusEffect_Burn', OwnerPC.Pawn);
				BurnToApply.Duration = BurnDuration;
				BurnToApply.Period = BurnTickTime;
				BurnToApply.DamageAmount = BurnDamagePerTick + (BurnMPPercAsDamage * OwnerPC.GetPRI().MagicalPower);
			}

			if (SlowToApply == none)
			{
				SlowToApply = Spawn(class'HLW_StatusEffect_Slow', OwnerPC.Pawn);
				SlowToApply.Duration = SlowDuration + (SlowMPPercAsDuration * OwnerPC.GetPRI().MagicalPower);
				SlowToApply.SlowPercentage = SlowPercentage;
			}
		}
	}
}

simulated function OwnerPawnDied(Controller InstigatedBy, vector DamageHitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local HLW_Ability_MeteorStrike Meteor;
	local HLW_Ability_FrostShield Frost;
	local HLW_Ability_PulsingThunder Thunder;

	super.OwnerPawnDied(InstigatedBy, DamageHitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	Meteor = HLW_Ability_MeteorStrike(OwnerPC.GetAbility(1));
	Frost = HLW_Ability_FrostShield(OwnerPC.GetAbility(2));
	Thunder = HLW_Ability_PulsingThunder(OwnerPC.GetAbility(3));

	if (Meteor.StatusEffectsToApplyOnHit.Find(BurnToApply) != INDEX_NONE)
	{
		Meteor.StatusEffectsToApplyOnHit.RemoveItem(BurnToApply);
	}

	if (Frost.StatusEffectsToApplyOnHit.Find(SlowToApply) != INDEX_NONE)
	{
		Frost.StatusEffectsToApplyOnHit.RemoveItem(SlowToApply);
	}

	if (Thunder.StatusEffectsToApplyOnHit.Find(StunToApply) != INDEX_NONE)
	{
		Thunder.StatusEffectsToApplyOnHit.RemoveItem(StunToApply);
	}
}

simulated function OwnerChangedWeapon(Weapon PrevWeapon, Weapon NewWeapon)
{
	super.OwnerChangedWeapon(PrevWeapon, NewWeapon);

	if (OwnerPC != none && OwnerPC.Pawn != none && NewWeapon != none)
	{
		if (PrevWeapon != none)
		{
			// If the previous weapon was fire, remove the additional status effect from meteor (etc etc)
			if (PrevWeapon.IsA('HLW_Spell_Fire'))
			{
				HLW_Ability_MeteorStrike(OwnerPC.GetAbility(1)).StatusEffectsToApplyOnHit.RemoveItem(BurnToApply);
			}
			else if (PrevWeapon.IsA('HLW_Spell_Frost'))
			{
				HLW_Ability_FrostShield(OwnerPC.GetAbility(2)).StatusEffectsToApplyOnHit.RemoveItem(SlowToApply);
			}
			else if (PrevWeapon.IsA('HLW_Spell_Lightning'))
			{
				HLW_Ability_PulsingThunder(OwnerPC.GetAbility(3)).StatusEffectsToApplyOnHit.RemoveItem(StunToApply);
			}
		}

		// If the new weapon is fire, add the additional status effect to meteor (etc etc)
		if (NewWeapon.IsA('HLW_Spell_Fire'))
		{
			HLW_Ability_MeteorStrike(OwnerPC.GetAbility(1)).StatusEffectsToApplyOnHit.AddItem(BurnToApply);
		}
		else if (NewWeapon.IsA('HLW_Spell_Frost'))
		{
			HLW_Ability_FrostShield(OwnerPC.GetAbility(2)).StatusEffectsToApplyOnHit.AddItem(SlowToApply);
		}
		else if (NewWeapon.IsA('HLW_Spell_Lightning'))
		{
			HLW_Ability_PulsingThunder(OwnerPC.GetAbility(3)).StatusEffectsToApplyOnHit.AddItem(StunToApply);
		}
	}
}

simulated function AbilityComplete(bool bIsPremature = false);

DefaultProperties
{
	StunDuration=1.25
	StunMPPercAsDuration=0.0038

	BurnDuration=6.0
	BurnTickTime=1
	BurnDamagePerTick=5
	BurnMPPercAsDamage=0.07

	SlowDuration=2
	SlowPercentage=0.5
	SlowMPPercAsDuration=0.01
}
