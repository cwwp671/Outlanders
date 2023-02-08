/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Projectile_AmplifyAbility extends HLW_Projectile_Spell;

var HLW_Pawn_Class MyCaster;

replication
{
	if (bNetDirty)
		MyCaster;
}

simulated event ReplicatedEvent(Name VarName)
{
	super.ReplicatedEvent(VarName);

	if (VarName == 'MyRadius' && Role < ROLE_Authority)
	{
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	//ProjEffects.SetScale(15.0f);
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (MyCaster != none)
	{
		// Set location to the owner (the caster) of our owner (the ability)
		SetLocation(MyCaster.Location);
	}
}

defaultproperties
{	
	ProjParticle=ParticleSystem'HLW_AndrewParticles.Particles.FX_Vortex_White'
	
    Speed=0
	MyDamageType=class'HLW_DamageType_Magical'
	DamageRadius=0
	MomentumTransfer=0
	Damage=0
}