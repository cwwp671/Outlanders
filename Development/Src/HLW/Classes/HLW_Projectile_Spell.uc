class HLW_Projectile_Spell extends HLW_Projectile;

var ParticleSystemComponent	ProjEffects;
var ParticleSystemComponent ExplEffects;
var() ParticleSystem ProjParticle;
var() ParticleSystem ExplosionParticle;
var() HLW_Emitter ExplosionEmitter;
var() SoundCue HitSound;
var float upAmount;
var bool ThisIsDead;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();	
	
	ProjEffects = new class'ParticleSystemComponent';
	ProjEffects.SetTemplate(ProjParticle);
	ProjEffects.SetAbsolute(false, false, false);
	AttachComponent(ProjEffects);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{	
	if(Damage > 0 && DamageRadius > 0)
	{
		if ( Role == ROLE_Authority )
		{
			PlaySound(HitSound,,,, HitLocation);
			ProjectileHurtRadius(HitLocation, HitNormal);
			Damage = 0;
			DamageRadius = 0;
		}
	}
	
	if(Role < ROLE_Authority)
	{
		if(WorldInfo.MyEmitterPool != None)
		{
			ExplEffects = WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticle, HitLocation);
		}
	
		// Shut down physics and collision
		SetPhysics(PHYS_None);
		SetCollision(false, false);

		if (CollisionComponent != None)
		{
			CollisionComponent.SetBlockRigidBody(false);
		}

		SetCollision(false,false);
		//ExplEffects.DeactivateSystem();
		ProjEffects.DeactivateSystem();
		SetTimer(ProjEffects.GetMaxLifespan(), false, 'Destroy');
		Damage = 0;
		DamageRadius = 0;
	}

	Damage = 0;
	DamageRadius = 0;
}

/**
 * Adjusts HurtOrigin up to avoid world geometry, so more traces to actors around explosion will succeed
 */


defaultproperties
{
	HitSound=SoundCue'HLW_Package.Sounds.FireballExplosionSound'
	ThisIsDead=true
	DamageRadius=0
}