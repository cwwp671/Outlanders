/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Projectile_Meteor extends HLW_Projectile_Spell;

var HLW_Projectile_Meteor_FractureMesh Fract;
var StaticMeshComponent MeshComp;
var array<HLW_StatusEffect> StatusEffectsToApplyOnHit;
var protectedwrite bool bExploded;

var Vector HitLoc;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	//ProjEffects.SetScale(15.0f);
	//ExplEffects.SetScale(200.0f);
	
	
}


simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);	
	
	if(Role == ROLE_Authority)
	{
		//`log("Distance:"@VSize(HitLoc - Location));
	
		if(VSize(HitLoc - Location) <= 100)
		{
			Explode(HitLoc, HitLoc);	
		}
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local HLW_Pawn Victim;
	local int i;

	//if (Role < ROLE_Authority)
	//{
	//	DrawDebugCylinder(HitLocation, HitLocation, DamageRadius, 24, 256,256,256, true);
	//}

	if (!bExploded && HLW_Ability(Owner) != none && HLW_Ability(Owner).OwnerPC != none)
	{
		bExploded = true;
		OnExplode();
		
		foreach VisibleCollidingActors(class'HLW_Pawn', Victim, DamageRadius, HitLocation)
		{
			if (Victim != none)
			{
				for (i = 0; i < StatusEffectsToApplyOnHit.Length; i++)
				{
					if (StatusEffectsToApplyOnHit[i] != none)
					{
						Victim.ApplyStatusEffect(StatusEffectsToApplyOnHit[i], HLW_Ability(Owner).OwnerPC, Owner);
					}
				}
			}
		}
	}
		
	DetachComponent(MeshComp);
	
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
		//if(WorldInfo.MyEmitterPool != None)
		//{
			//ExplEffects = WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticle, HitLocation);
			//ExplEffects.SetScale(DamageRadius / 750);
		//}
	
		//HLW_Pawn_Class(InstigatorController.Pawn).SpawnEmitter(ExplosionParticle, HitLocation, Rot(0,0,0),, DamageRadius / 750);
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
	
	if(bExploded)
	{
		Destroy();	
	}
	
	//super.Explode(HitLocation, HitNormal);
}

/**
 * Adjusts HurtOrigin up to avoid world geometry, so more traces to actors around explosion will succeed
 */
simulated function bool ProjectileHurtRadius( vector HurtOrigin, vector HitNormal)
{
	local vector AltOrigin, TraceHitLocation, TraceHitNormal;
	local Actor TraceHitActor;

	// early out if already in the middle of hurt radius
	if ( bHurtEntry )
		return false;

	AltOrigin = HurtOrigin;

	if ( (ImpactedActor != None) && ImpactedActor.bWorldGeometry )
	{
		// try to adjust hit position out from hit location if hit world geometry
		AltOrigin = HurtOrigin + 2.0 * class'Pawn'.Default.MaxStepHeight * HitNormal;
		TraceHitActor = Trace(TraceHitLocation, TraceHitNormal, AltOrigin, HurtOrigin, false,,,TRACEFLAG_Bullet);
		if ( TraceHitActor == None )
		{
			// go half way if hit nothing
			AltOrigin = HurtOrigin + class'Pawn'.Default.MaxStepHeight * HitNormal;
		}
		else
		{
			AltOrigin = HurtOrigin + 0.5*(TraceHitLocation - HurtOrigin);
		}
	}

	return HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, AltOrigin,,, true);
}

delegate OnExplode(); //Called When Explode happens

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=MeteorMesh
        StaticMesh=StaticMesh'HLW_worldProps.Meteorite'
        Scale=2.0f
    End Object
    MeshComp=MeteorMesh
	Components.Add(MeteorMesh)

	ExplosionParticle=ParticleSystem'HLW_Package_Randolph.Farticles.Particle_MeteorImpact'//ParticleSystem'HLW_AndrewParticles.Particles.FX_MeteorImpact'
	ProjParticle=ParticleSystem'Castle_Assets.FX.P_FX_Fire_SubUV_01'
	
    Speed=4000
	MyDamageType=class'HLW_DamageType_Magical'
	DamageRadius=500
	MomentumTransfer=10000

	bExploded=false
	bCollideActors=false
	bCollideWorld=false
	HitSound=SoundCue'HLW_Package_Chris.SFX.Mage_Meteor_Impact'
}