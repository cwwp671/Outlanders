class HLW_Spell_Frost extends HLW_Spell_Weapon;

defaultproperties
{
	SpellName=Frost
	ProjParticle=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF_Blue'
	ParticleScale=0.125f
	WeaponFireTypes[0]=EWFT_Projectile
	FireInterval[0]=0.30f
	WeaponRange=500.0
	Spread[0]=0.0
	WeaponProjectiles[0]=class'HLW.HLW_projectile_frost'
	ShootSound=SoundCue'HLW_Package_Chris.SFX.Mage_Frost_Shoot'
	EquipSound=SoundCue'HLW_Package_Chris.SFX.Mage_Frost_Equip'
	indexHUD=1
	BaseDamage=10f
	MagPowerPercentage=0.1
	SpellColor=(R=0.1f, G=1.0f, B=1.0f, A=1.0f)
}