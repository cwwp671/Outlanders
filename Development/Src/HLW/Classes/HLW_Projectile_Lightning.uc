class HLW_Projectile_Lightning extends HLW_Projectile_Spell;

var bool bounced;

/*simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal) //LGK No longer having on hit status effects for Mage weapons
{
	local HLW_StatusEffect_Counter_Stun_Mage StunEffect;

	super.ProcessTouch(Other, HitLocation, HitNormal);

	if (HLW_Pawn(Other) != none)
	{
		StunEffect = Spawn(class'HLW_StatusEffect_Counter_Stun_Mage');

		HLW_Pawn(Other).ApplyStatusEffect(StunEffect, Instigator.Controller, self);
	}
}*/

simulated event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	if(bounced)
	{
		Destroy();
	}
	else
	{
		Velocity = MirrorVectorByNormal(Velocity,HitNormal); //That's the bounce
		SetRotation(Rotator(Velocity));
		TriggerEventClass(class'SeqEvent_HitWall', Wall);
		bounced = true;
    }

	PlaySound(HitSound);
    Wall.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
}

defaultproperties
{
	MyDamageType=class'HLW_DamageType_Magical'
	ProjParticle=ParticleSystem'HLW_AndrewParticles.Particles.FX_LightningBall'
	ExplosionParticle=ParticleSystem'HLW_AndrewParticles.Particles.FX_LightningChunks'
	HitSound=SoundCue'HLW_Package_Chris.SFX.Mage_Thunder_Impact'
    Speed=3000
    MomentumTransfer=0//100
    
    Begin Object Class=AudioComponent Name=TravelSound
		SoundCue=SoundCue'HLW_Package_Chris.SFX.Mage_Thunder_Travel'
		bAutoPlay=true
		bUseOwnerLocation=true
    End Object
    Components.Add(TravelSound)
}