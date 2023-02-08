/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Projectile_Charge extends HLW_Projectile;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	`log("Post has begun play");
}

simulated function HitWall(Vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	Wall.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	`log("asdaSD aSd asd Other = Inst asd asg fdaSG asfd");
	if (Other != Instigator)
	{
		`log("You just got charged");
		Other.TakeDamage(Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
	}
}

simulated function Destroyed()
{
	`log("Destroyededededed");
	super.Destroyed();	
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=+00100
		CollisionHeight=+00050
		End Object
			
	LifeSpan=0;
	MaxSpeed = 0;
	Speed = 0;
	Damage = 20;
}