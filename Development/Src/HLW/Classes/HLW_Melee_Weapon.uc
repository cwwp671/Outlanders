/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Melee_Weapon extends Weapon;

enum AttackTypes
{
	HLW_AT_SWING,
	HLW_AT_STAB,
	HLW_AT_CHOP,
	HLW_AT_NONE
};

enum DamageTypes
{
	HLW_DT_HIGH,
	HLW_DT_MEDIUM,
	HLW_DT_LOW,
	HLW_DT_NONE
};

struct Tracer
{
	var Vector Position;
};

var Tracer ChopTracers[18];
var Tracer SwingTracers[18];
var Tracer StabTracers[18];

var Name wSocketNames[18];

var array<Vector> iLocations;
var array<Rotator> iRotations;

var array<Vector> cLocations;
var array<Rotator> cRotations;

var array<Vector> pLocations;
var array<Rotator> pRotations;

var float SwingRate;
var float SwingAnimationTime;

var float ChopRate;
var float ChopAnimationTime;

var float StabRate;
var float StabAnimationTime;

var bool bIsAttacking;

var SoundCue ImpactSound;

var float BlockDamageReduction;
var float cBlockDamageReduction;

/** The class of the attachment to spawn */
var class<HLW_WeaponAttachment>	AttachmentClass;

var() class<DamageType> MyDamageType;
var() float PhysPowerPercentage;

simulated function Tracer CreateTracer(Name SocketName, int Group, AttackTypes Type, DamageTypes Damage)
{
		local Tracer tTracer;
	
		tTracer.Position = GetSocketLocation(SocketName);
		//`log("Position:"@tTracer.Position);
		//tTracer.Group = Group;
		//tTracer.Type = Type;
		//tTracer.Damage = Damage;
		return tTracer;
}

simulated function Vector GetSocketLocation(Name SocketName)
{
   local Vector SocketLocation;
   local Rotator SocketRotation;
   local SkeletalMeshComponent SMC;

   SMC = SkeletalMeshComponent(Mesh);

   if (SMC != none && SMC.GetSocketByName(SocketName) != none)
   {
      SMC.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SocketRotation);
   }

   return SocketLocation;
}

simulated function Rotator GetSocketRotation(Name SocketName)
{
   local Vector SocketLocation;
   local Rotator SocketRotation;
   local SkeletalMeshComponent SMC;

   SMC = SkeletalMeshComponent(Mesh);

   if (SMC != none && SMC.GetSocketByName(SocketName) != none)
   {
      SMC.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SocketRotation);
   }

   return SocketRotation;
}

simulated function int FindDamage(int DamageType)
{
	if(DamageType == HLW_DT_HIGH)
	{
		return 30;	
	}
	else if(DamageType == HLW_DT_MEDIUM)
	{
		return 15;
	}
	else if(DamageType == HLW_DT_LOW)
	{
		return 5;
	}
	else if(DamageType == HLW_DT_NONE)
	{
		return 0;
	}
}

simulated function Vector FindColor(DamageTypes Damage)
{
	local Vector dmgColor;
	
	if(Damage == HLW_DT_HIGH)
	{
		dmgColor.X = 255;
		dmgColor.Y = 0;
		dmgColor.Z = 0;	
	}
	else if(Damage == HLW_DT_MEDIUM)
	{
		dmgColor.X = 255;
		dmgColor.Y = 255;
		dmgColor.Z = 0;
	}
	else if(Damage == HLW_DT_LOW)
	{
		dmgColor.X = 0;
		dmgColor.Y = 0;
		dmgColor.Z = 255;
	}
	else if(Damage == HLW_DT_NONE)
	{
		dmgColor.X = 255;
		dmgColor.Y = 255;
		dmgColor.Z = 255;
	}
	
	return dmgColor;
}

simulated function AttachWeaponTo(SkeletalMeshComponent MeshComponent, optional Name SocketName)
{
	local HLW_Pawn_Class P;

	P = HLW_Pawn_Class(Instigator);
	
	//Spawn Attachment
	if (Role == ROLE_Authority && P != None)
	{
		P.CurrentWeaponAttachmentClass = AttachmentClass;

		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_Client && Instigator.IsLocallyControlled()))
		{
			P.WeaponAttachmentChanged();
		}
	}
}

simulated function TimeWeaponEquipping()
{
	AttachWeaponTo(Instigator.Mesh);

	Super.TimeWeaponEquipping();
}

simulated function StartBlock()
{
	GoToState('Blocking');	
}

simulated function StopBlock()
{
	GoToState('Active');	
}

simulated state Blocking
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		if(Role < ROLE_Authority)
		{
			HLW_Pawn_Class_Warrior(Owner).WarriorPreBlock();
			SetTimer(0.45f, false, 'IdleBlock');
		}
		
		HLW_Pawn_Class_Warrior(Owner).SetIsBlocking(true);
	}
	
	simulated event EndState(Name NextStateName)
	{
		if(Role < ROLE_Authority)
		{
			ServerScaleDamage(cBlockDamageReduction);
			ServerScaleMovement(0.2f);
			super.EndState(NextStateName);
			ClearTimer('IdleBlock');
			HLW_Pawn_Class_Warrior(Owner).WarriorExitBlock();
		}
		
		HLW_Pawn_Class_Warrior(Owner).SetIsBlocking(false);
	}
}

simulated function IdleBlock()
{
	//`log("***PERFECT BLOCK ACTIVE***");
	ServerScaleDamage(-1.0f);
	cBlockDamageReduction = BlockDamageReduction;
	ServerScaleMovement(-0.20f);
	HLW_Pawn_Class_Warrior(Owner).WarriorBlockIdle();
	SetTimer(0.4f, false, 'PerfectBlockEnded');
}

reliable server function ServerScaleMovement(float Rate)
{
	HLW_Pawn_Class_Warrior(Owner).ScaleMovement(Rate);
}

reliable server function ServerScaleDamage(float rate)
{
	HLW_Pawn_Class_Warrior(Owner).ScaleDamage(Rate);
}

simulated function PerfectBlockEnded()
{
	//`log("***PERFECT BLOCK INACTIVE***");
	ServerScaleDamage(BlockDamageReduction);
	cBlockDamageReduction = BlockDamageReduction;
}



defaultproperties
{
	bIsAttacking = false
	PhysPowerPercentage=0.2
}