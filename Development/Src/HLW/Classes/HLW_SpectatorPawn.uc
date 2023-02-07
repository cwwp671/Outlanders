class HLW_SpectatorPawn extends Pawn;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	SetCollision(false, false, true);
}

DefaultProperties
{
	CollisionType=COLLIDE_NoCollision
	Physics=PHYS_Flying
}
