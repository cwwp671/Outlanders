/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Base_Structure extends HLW_Pawn;

var(Structure) const int TeamIndex;
var bool isGoal;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	CylinderComponent.SetCylinderSize(35.0 * Mesh.Scale3D.X, 40.0 * Mesh.Scale3D.Y);
}

defaultproperties
{
	isGoal=false
	
	bAlwaysRelevant=true
	
	Begin Object Name=CollisionCylinder
	CollisionRadius=+0035.000000
	CollisionHeight=+0040.000000
	End Object
}