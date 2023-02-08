/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Spell_Lightning extends HLW_Spell_Weapon;

defaultproperties
{
	SpellName=Lightning
	ProjParticle=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam_Blue'
	ParticleScale=0.05f
	WeaponFireTypes[0]=EWFT_Projectile
	FireInterval[0]=0.30f
	WeaponRange=500.0
	Spread[0]=0.0
	WeaponProjectiles[0]=class'HLW.HLW_projectile_lightning'
	ShootSound=SoundCue'HLW_Package_Chris.SFX.Mage_Thunder_Shoot'
	EquipSound=SoundCue'HLW_Package_Chris.SFX.Mage_Thunder_Equip'
	indexHUD=2
	BaseDamage=10f
	MagPowerPercentage=0.1
	SpellColor=(R=1.0f, G=0.86f, B=0.0f, A=1.0f)
}