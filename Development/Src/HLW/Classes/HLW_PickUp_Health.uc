/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_PickUp_Health extends HLW_PickUp
placeable;

var(Pickup) int HealAmount;
var(Pickup) float HealthPercentage;

reliable server function PickupEffect()
{
	super.PickupEffect();
	
	HealAmount = HitPawn.GetPRI().HLW_HealthMax * HealthPercentage;
	HitPawn.HealDamage(HealAmount, None, None);
	HitPawn = None;
}

defaultproperties
{
	HealthPercentage=0.25
	PickupRadius=100
	RespawnTime=60
	LiquidColor=(R=0.8, G=0.028102, B=0, A=1)
	PickupParticle=ParticleSystem'hlw_andrewparticles.Particles.FX_Health'
}