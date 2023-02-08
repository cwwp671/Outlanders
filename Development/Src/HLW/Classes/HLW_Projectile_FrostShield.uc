/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Projectile_FrostShield extends HLW_Projectile_Spell;

var HLW_Pawn_Class MyCaster;
var repnotify float MyRadius;

replication
{
	if (bNetDirty)
		MyCaster, MyRadius;
}


simulated function PostBeginPlay()
{
	local Vector ParticleSize;
	
	Super.PostBeginPlay();	
	
	ProjEffects.SetTranslation(vect(0, 0, -60));
	ParticleSize.X = 350 / 225; //Current Radius / Default Particle Radius
	ParticleSize.Y = 350 / 225; //Current Radius / Default Particle Radius
	ParticleSize.Z = 3;
	ProjEffects.SetScale3D(ParticleSize);
}

simulated function Init(Vector Direction)
{
	super.Init(Direction);
	
	
	
	
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (MyCaster != none)
	{
		// Set location to the owner (the caster) of our owner (the ability)
		SetLocation(MyCaster.Location);

		if (Role < ROLE_Authority && Owner != none && HLW_Ability(Owner).bIsActive)
		{
			//DrawDebugCylinder(MyCaster.Location + vect(0, 0, -60), MyCaster.Location + vect(0, 0, -60), MyRadius, 24, 256,256,256);
		}
	}
}

defaultproperties
{
	ProjParticle=ParticleSystem'HLW_Package_Randolph.Farticles.Particle_FrostShield'//ParticleSystem'HLW_AndrewParticles.Particles.FX_IceShield'
	
    Speed=0
	MyDamageType=class'HLW_DamageType_Magical'
	DamageRadius=0
	MomentumTransfer=0
}