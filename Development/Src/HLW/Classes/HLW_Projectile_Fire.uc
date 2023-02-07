class HLW_Projectile_Fire extends HLW_Projectile_Spell;

var StaticMeshComponent MeshComp;

/*simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)//LGK No more on hit status effects
{
	local HLW_StatusEffect_Burn_Mage BurnEffect;

	super.ProcessTouch(Other, HitLocation, HitNormal);

	if (HLW_Pawn(Other) != none && Other != Instigator)
	{
		BurnEffect = Spawn(class'HLW_StatusEffect_Burn_Mage');
		
		HLW_Pawn(Other).ApplyStatusEffect(BurnEffect, Instigator.Controller, self);
	}
}*/

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	ProjEffects.SetScale(0.4);	
}

simulated event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	Wall.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
	super.HitWall(HitNormal, Wall, WallComp);	
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	DetachComponent(MeshComp);
	super.Explode(HitLocation, HitNormal);
}

defaultproperties
{	
	MyDamageType=class'HLW_DamageType_Magical'
	Begin Object Class=StaticMeshComponent Name=MeteorMesh
        StaticMesh=StaticMesh'HLW_CONNOR_PAKAGE.Models.fireballNEW'
        Scale=2f
    End Object
    MeshComp=MeteorMesh
	Components.Add(MeteorMesh)
	
	ProjParticle=ParticleSystem'HLW_AndrewParticles.Particles.FX_FireBall'
	ExplosionParticle=ParticleSystem'HLW_AndrewParticles.Particles.FX_FireChunks'
	HitSound=SoundCue'HLW_Package_Chris.SFX.Mage_Fire_Impact'
	
    Speed=2750
    MomentumTransfer=0//15000
    bRotationFollowsVelocity=false
    
    Begin Object Class=AudioComponent Name=TravelSound
		SoundCue=SoundCue'HLW_Package_Chris.SFX.Mage_Fire_Travel'
		bAutoPlay=true
		bUseOwnerLocation=true
    End Object
    Components.Add(TravelSound)
}