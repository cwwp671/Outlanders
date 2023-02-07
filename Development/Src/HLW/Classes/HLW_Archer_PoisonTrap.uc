class HLW_Archer_PoisonTrap extends HLW_Archer_Trap;

var HLW_StatusEffect_PoisonTrap PoisonStatus;
var SoundCue TrapSound;
var float PoisonDuration;
var float PoisonDamage;

reliable server function TrapEffect()
{
	local Actor HitActor;
	
	foreach VisibleCollidingActors(class'Actor', HitActor, EffectRadius, Location)
	{
		if(HitActor != HLW_PlayerController(Owner).Pawn)
		{
			if(HLW_Pawn(HitActor) != None)
			{
				PoisonStatus = Spawn(class'HLW_StatusEffect_PoisonTrap');
				PoisonStatus.Duration = PoisonDuration;
				PoisonStatus.DamageAmount = PoisonDamage;
				HLW_Pawn(HitActor).ApplyStatusEffect(PoisonStatus, HLW_PlayerController(Owner));
				
			}
		}
	}	
	
	PlaySound(TrapSound,,,, Location);
	HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).SpawnEmitter(TrapParticle, Location, Rotation,, 1.0f);
	Destroy();
}

defaultproperties
{
	ActivationSound=SoundCue'HLW_Package_Voices.Archer.Ability_PoisonTrap'
	TrapParticle=ParticleSystem'HLW_Package_Randolph.Farticles.PoisonTrapEffect'
	TrapSound=SoundCue'HLW_Package_Randolph.Sounds.Trap_Poison_Activate'
	
	PoisonDamage=10
	PoisonDuration=5.0
	ActivationRadius=50
	EffectRadius=150
	
	Begin Object Name=TrapMesh
		StaticMesh=StaticMesh'HLW_mapProps.models.Trap_Poison_Static'//StaticMesh'HLW_Package_Randolph.models.Traps_Vial'
		Scale=1
	End Object
}