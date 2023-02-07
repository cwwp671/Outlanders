class HLW_PickUp_Mana extends HLW_PickUp
placeable;

var(Pickup) int ManaAmount;
var(Pickup) float ManaPercentage;

reliable server function PickupEffect()
{
	super.PickupEffect();
	
	ManaAmount = HitPawn.GetPRI().ManaMax * ManaPercentage;
	HitPawn.GetPRI().SetMana(HitPawn.GetPRI().Mana + ManaAmount);
	HitPawn = None;
}

defaultproperties
{
	ManaPercentage=0.25
	PickupRadius=100
	RespawnTime=60
	LiquidColor=(R=0.031029, G=0, B=0.8, A=1)
	PickupParticle=ParticleSystem'hlw_andrewparticles.Particles.FX_Mana_Pickup'
}