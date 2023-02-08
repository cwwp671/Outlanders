/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
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
