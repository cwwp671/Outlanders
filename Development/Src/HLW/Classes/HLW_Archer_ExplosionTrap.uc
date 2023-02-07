class HLW_Archer_ExplosionTrap extends HLW_Archer_Trap;

//var ParticleSystem ExplosionParticle;
var ParticleSystemComponent FlameComponent;
var ParticleSystem FlameParticle;
var SoundCue ExplosionSound;
var int ExplosiveDamage;
var float ExplosiveMomentum;
var bool FireSpawned;

reliable server function TrapEffect()
{
	HurtRadius(
				ExplosiveDamage,
				EffectRadius,
				class'HLW_DamageType_Physical',
				ExplosiveMomentum,
				Location,
				HLW_PlayerController(Owner).Pawn,
				HLW_PlayerController(Owner));
				
	HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).SpawnEmitter(TrapParticle, Location, Rotation,, 0.4f);
	PlaySound(ExplosionSound,,,, Location);
	Destroy();
}

defaultproperties
{
	TrapParticle=ParticleSystem'HLW_AndrewParticles.Particles.FX_Explosion'
	FlameParticle=ParticleSystem'HLW_Package_Randolph.Farticles.TrapFlame'
	ExplosionSound=SoundCue'HLW_Package_Chris.SFX.Archer_Ability_TrapExplosive_Explode'
	ActivationSound=SoundCue'HLW_Package_Voices.Archer.Ability_ExplosiveTrap'
	ExplosiveDamage=70
	ExplosiveMomentum=220000
	ActivationRadius=50
	EffectRadius=150
	FireSpawned=false
	
	Begin Object Name=TrapMesh
		StaticMesh=StaticMesh'HLW_Package_Randolph.models.Traps_Bomb'
		Scale=1.5f
	End Object
	
	Begin Object Class=ParticleSystemComponent Name=Fuse_PSC
		Template=ParticleSystem'HLW_AndrewParticles.Particles.FX_BomeFuse'
		Scale=0.5
		Translation=(X=-8,Y=0,Z=52)
	End Object
	FlameComponent=Fuse_PSC
	Components.Add(Fuse_PSC)
}