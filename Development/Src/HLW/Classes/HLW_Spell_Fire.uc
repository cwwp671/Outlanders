class HLW_Spell_Fire extends HLW_Spell_Weapon;

defaultproperties
{
	SpellName=Fire
	ProjParticle=ParticleSystem'HLW_Package.Mage.Fire'
	ParticleScale=0.04f
	WeaponFireTypes[0]=EWFT_Projectile
	FireInterval[0]=0.30f
	WeaponRange=350.0
	Spread[0]=0.0
	WeaponProjectiles[0]=class'HLW.HLW_projectile_fire'
	ShootSound=SoundCue'HLW_Package_Chris.SFX.Mage_Fire_Shoot'
	EquipSound=SoundCue'HLW_Package_Chris.SFX.Mage_Fire_Equip'
	indexHUD=0
	BaseDamage=10f
	MagPowerPercentage=0.1
	SpellColor=(R=1.0f, G=0.015f, B=0.015f, A=1.0f)
}