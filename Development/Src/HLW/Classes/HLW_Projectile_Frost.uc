/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Projectile_Frost extends HLW_Projectile_Spell;

var ParticleSystem SlowParticleEffect;
var StaticMeshComponent MeshComp;
var bool bDead;

simulated event Tick(float DeltaTime)
{
	local Vector newLocation;
	if(!bDead)
	{
		upAmount *= 1.01f;
		newLocation.X = Location.X;
		newLocation.Y = Location.Y;
		newLocation.Z = Location.Z + (upAmount * DeltaTime);
		SetLocation(newLocation);
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal) //LGK No more on hit status effects
{
	//local HLW_StatusEffect_Slow_Mage SlowEffect;
	local Name BoneHit;
	
	super.ProcessTouch(Other, HitLocation, HitNormal);

	if (HLW_Pawn(Other) != none)
	{
		DetachComponent(MeshComp);
		if (HLW_Pawn_Class(Other) != none)
		{
			BoneHit = HLW_Pawn_Class(Other).ThirdPerson.FindClosestBone(HitLocation);
			HLW_Pawn_Class(Other).ThirdPerson.AttachComponent(MeshComp, BoneHit,,Rotator(HitNormal));
		}
		/*SlowEffect = Spawn(class'HLW_StatusEffect_Slow_Mage');
		SlowEffect.ParticleEffect = SlowParticleEffect;
		HLW_Pawn(Other).ApplyStatusEffect(SlowEffect, Instigator.Controller, self);*/
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	bDead = true;
	super.Explode(HitLocation, HitNormal);	
}

defaultproperties
{
	SlowParticleEffect=ParticleSystem'HLW_AndrewParticles.Particles.FX_IceChunks'
	
	MyDamageType=class'HLW_DamageType_Magical'
	Begin Object Class=StaticMeshComponent Name=MeteorMesh
        StaticMesh=StaticMesh'HLW_Package_Dan.Models.Icicle'
        Scale=2.0f
    End Object
    MeshComp=MeteorMesh
	Components.Add(MeteorMesh)
	
	ProjParticle=ParticleSystem'HLW_AndrewParticles.Particles.FX_SnowBall'
    ExplosionParticle=ParticleSystem'HLW_AndrewParticles.Particles.FX_IceChunks'
	HitSound=SoundCue'HLW_Package_Chris.SFX.Mage_Frost_Impact'
    
    Speed=1000
    MomentumTransfer=0//125
    upAmount=-4f
    bRotationFollowsVelocity=false
    bDead=false
}