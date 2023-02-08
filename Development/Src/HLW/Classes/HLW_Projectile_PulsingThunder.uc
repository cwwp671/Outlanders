/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Projectile_PulsingThunder extends HLW_Projectile_Spell;

var Pawn PawnToFollow;

replication
{
	if (bNetDirty)
		PawnToFollow;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	ProjEffects.SetScale(3.0f);
}

simulated event Tick(float DeltaTime)
{
	local Vector V;

	super.Tick(DeltaTime);

	if (PawnToFollow != none)
	{
		V = PawnToFollow.Location;

		SetLocation(V);
	}
}

defaultproperties
{
	//ExplosionParticle=ParticleSystem'HLW_AndrewParticles.Particles.FX_Lightning_AoE'
	//ProjParticle=ParticleSystem'HLW_AndrewParticles.Particles.FX_LightningBall'
	
    Speed=4000
	MyDamageType=class'HLW_DamageType_Magical'
	DamageRadius=1000
	MomentumTransfer=10000
}