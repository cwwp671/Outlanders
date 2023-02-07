class HLW_Spell_Weapon extends UDKWeapon
placeable;

var() name RightShootSocket, LeftShootSocket;	//Finger sockets
var() name SpellName;							//Name of spell
var() ParticleSystemComponent	RProjEffects;	//Right hand particle
var() ParticleSystemComponent	LProjEffects;	//Left hand particle
var() ParticleSystem ProjParticle;				//Projectile particle
var() SoundCue ShootSound;						//Shooting weapon sound
var() SoundCue EquipSound;						//Equipping weapon sound
var() float ParticleScale;						//Scale of the particle
var bool pressed;
var bool bShootFromRightHand;
var bool bCanSwitchWeapon;
var() int BaseDamage;
var() float MagPowerPercentage;
var int indexHUD;
var LinearColor SpellColor;

var repnotify bool hasEquiped;

replication
{
	if(bNetDirty)
		hasEquiped;
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'hasEquiped')
	{
		ClientSpawnHandParticle(hasEquiped);
	}
}

reliable client function ClientSpawnHandParticle(bool bCreate)
{
	if(bCreate)
	{
		//RIGHT HAND PARTICLE EFFECT
		RProjEffects = new class'ParticleSystemComponent';
		RProjEffects.SetTemplate(ProjParticle);
		RProjEffects.SetScale(particleScale);
		RProjEffects.SetAbsolute(false, false, false);
		
		//LEFT HAND PARTICLE EFFECT
		LProjEffects = new class'ParticleSystemComponent';
		LProjEffects.SetTemplate(ProjParticle);
		LProjEffects.SetScale(particleScale);
		LProjEffects.SetAbsolute(false, false, false);
	
		if(HLW_Pawn_Class(Owner) != None && HLW_Pawn_Class(Owner).Mesh.GetSocketByName(RightShootSocket) != None)
		{
			HLW_Pawn_Class(Owner).Mesh.AttachComponentToSocket(RProjEffects, RightShootSocket);
		}
	
		if(HLW_Pawn_Class(Owner) != None && HLW_Pawn_Class(Owner).Mesh.GetSocketByName(LeftShootSocket) != None)
		{
			HLW_Pawn_Class(Owner).Mesh.AttachComponentToSocket(LProjEffects, LeftShootSocket);
		}
	}
	else
	{
			HLW_Pawn_Class(Owner).Mesh.DetachComponent(RProjEffects);
			HLW_Pawn_Class(Owner).Mesh.DetachComponent(LProjEffects);
	}
}

reliable server function ServerSpawnHandParticle(bool bCreate)
{
	SpawnHandParticles(bCreate);
}

function SpawnHandParticles(bool bCreate)
{
	if(bCreate)
	{
		//RIGHT HAND PARTICLE EFFECT
		RProjEffects = new class'ParticleSystemComponent';
		RProjEffects.SetTemplate(ProjParticle);
		RProjEffects.SetScale(particleScale);
		RProjEffects.SetAbsolute(false, false, false);
		
		//LEFT HAND PARTICLE EFFECT
		LProjEffects = new class'ParticleSystemComponent';
		LProjEffects.SetTemplate(ProjParticle);
		LProjEffects.SetScale(particleScale);
		LProjEffects.SetAbsolute(false, false, false);
	
		if(HLW_Pawn_Class(Owner) != None && HLW_Pawn_Class(Owner).Mesh.GetSocketByName(RightShootSocket) != None)
		{
			HLW_Pawn_Class(Owner).Mesh.AttachComponentToSocket(RProjEffects, RightShootSocket);
		}
	
		if(HLW_Pawn_Class(Owner) != None && HLW_Pawn_Class(Owner).Mesh.GetSocketByName(LeftShootSocket) != None)
		{
			HLW_Pawn_Class(Owner).Mesh.AttachComponentToSocket(LProjEffects, LeftShootSocket);
		}
	}
	else
	{
		HLW_Pawn_Class(Owner).Mesh.DetachComponent(RProjEffects);
		HLW_Pawn_Class(Owner).Mesh.DetachComponent(LProjEffects);
	}
	
	if(Role < ROLE_Authority)
	{
		ServerSpawnHandParticle(bCreate);
	}
}

//When a projectile is shot this function gets called
simulated function Projectile ProjectileFire()
{
	local Projectile FiredProjectile;

	if (Role == ROLE_Authority)
	{
		PlaySound(ShootSound,,,, Owner.Location); //PLAYS SHOOT SOUND

		FiredProjectile = super.ProjectileFire();
		FiredProjectile.Damage = BaseDamage + (HLW_Pawn_Class(Owner).GetPRI().MagicalPower * MagPowerPercentage);
		return FiredProjectile;
	}

	return super.ProjectileFire();
}

simulated function FireAmmunition()
{
	if(Role == ROLE_Authority)
	{
		if(bShootFromRightHand)
		{
			HLW_Pawn_Class(Owner).PlayAnim('CustomAnim', 'Mage_Hands_Shoot_Right', 1.95f / FireInterval[0],0.05,0.05,false,true);
			HLW_Pawn_Class(Owner).PlayAnimTP_Upper('CustomAnimation', 'Mage_Upper_Right_Shoot', 1.95f / FireInterval[0],0.05,0.05,false,true);
		}
		else
		{
			HLW_Pawn_Class(Owner).PlayAnim('CustomAnim', 'Mage_Hands_Shoot_Left', 1.95f / FireInterval[0],0.05,0.05,false,true);
			HLW_Pawn_Class(Owner).PlayAnimTP_Upper('CustomAnimation', 'Mage_Upper_Left_Shoot', 1.95f / FireInterval[0],0.05,0.05,false,true);
		}
	}
	super.FireAmmunition();
}


//Enters this state when unequipping weapon
simulated state WeaponPuttingDown
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
	}
	
	simulated function WeaponIsDown()
	{
		hasEquiped = false;
		SpawnHandParticles(hasEquiped);
		super.WeaponIsDown();
	}

	simulated function bool TryPutDown()
	{
		return super.TryPutDown();
	}

	reliable client function ClientWeaponThrown()
	{
		super.ClientWeaponThrown();
	}

	simulated event EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
	}
}

//Enters this state when equipping weapon
simulated state WeaponEquipping
{
	simulated event BeginState(Name PreviousStateName)
	{
		bCanSwitchWeapon = false;
		HLW_Pawn_Class_Mage(Owner).PlayAnim('CustomAnim', 'Mage_Hands_Switch', 1.0, 0.1, 0.1, false,true);
		HLW_Pawn_Class_Mage(Owner).CurrentSpellColor = SpellColor;
		HLW_Pawn_Class_Mage(Owner).GetPRI().SetWeaponIndex(indexHUD);
		super.BeginState(PreviousStateName);
	}

	simulated function Activate()
	{
		super.Activate();
	}

	simulated event EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
	}

	simulated function WeaponEquipped()
	{
		//WorldInfo.Game.Broadcast(self, SpellName@"EQUIPPED");
		hasEquiped = true;

		SpawnHandParticles(hasEquiped);
		
		if (Role == ROLE_Authority)
		{
			PlaySound(EquipSound,,,, Owner.Location); //PLAY EQUIP SOUND
		}
		
		bCanSwitchWeapon = true;
		
		super.WeaponEquipped();
	}
}

/**
 * Put Down current weapon
 * Once the weapon is put down, the InventoryManager will switch to InvManager.PendingWeapon.
 *
 * @return	returns true if the weapon can be put down.
 */
simulated function bool TryPutDown()
{
	bWeaponPutDown = TRUE;
	return TRUE;
}

reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	super.ClientGivenTo(NewOwner, bDoNotActivate);
}

simulated event vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	local vector SocketLocation;
	local Rotator SocketRotation;
	
	SocketLocation = vect(0, 0, 0);
	
		if(bShootFromRightHand)
		{	
			if(HLW_Pawn_Class(Owner) != None && HLW_Pawn_Class(Owner).Mesh.GetSocketByName(RightShootSocket) != None)
			{
				HLW_Pawn_Class(Owner).Mesh.GetSocketWorldLocationAndRotation(RightShootSocket, SocketLocation, SocketRotation);
			}
			bShootFromRightHand = false;
		}
		else
		{
			if(HLW_Pawn_Class(Owner) != None && HLW_Pawn_Class(Owner).Mesh.GetSocketByName(LeftShootSocket) != None)
			{
				HLW_Pawn_Class(Owner).Mesh.GetSocketWorldLocationAndRotation(LeftShootSocket, SocketLocation, SocketRotation);
			}
			bShootFromRightHand = true;
		}
	
	return SocketLocation;
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
} 

defaultproperties
{
	FiringStatesArray(0)=WeaponFiring
	WeaponFireTypes(0)=EWFT_Projectile
	bCanThrow=false
	ProjParticle=ParticleSystem'HLW_Package.Mage.Fire'
	LeftShootSocket=Mage_FingerL
	RightShootSocket=Mage_FingerR
	bShootFromRightHand=true
	bGameRelevant=true
	bReplicateInstigator=true
	EquipTime=+0.5//0.9583
}