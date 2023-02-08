/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Projectile_InitialVolley extends HLW_Projectile_Volley;

simulated function PostBeginPlay()
{
	SetTimer(1.0f, false, 'Destroy');	
}

defaultproperties
{
}