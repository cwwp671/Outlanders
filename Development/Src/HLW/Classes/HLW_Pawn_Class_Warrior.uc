/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Pawn_Class_Warrior extends HLW_Pawn_Class
placeable;

var Name SwordSocket;
var Name ShieldSocket;
var Name SwordSocketTP;
var Name ShieldSocketTP;
var Name HelmetSocketTP;

var bool bBlockHeld;
var bool bIsBlocking;
var bool bCanHitReaction;
var bool bIsAttacking;

var bool bIsCharging;
var bool bIsChasing;
var bool bNoBlocking;

var StaticMeshComponent Helmet;

var SkeletalMeshComponent WeaponTP;
var SkeletalMeshComponent ShieldTP;

var DroppedPickup DroppedShield;
var SkeletalMeshComponent DroppedShieldMesh;
var class<DroppedPickup> DroppedShieldClass;

var array<Actor> ChargeHitActors;
var HLW_Melee_Longsword SwordWeapon;

var SoundCue VoiceCueChargeHit;
var SoundCue ChargeHitSound;

var repnotify byte RainbowKiller;

enum WarriorAudioType
{
	AT_Hurt, AT_Died, AT_LevelUp, AT_Idle,
	AT_ChargeHit
};

//var UDKAnimBlendBase StateList;
var UDKAnimBlendBase MeleeList;
var UDKAnimBlendBase BlockingList;
//var UDKAnimBlendBase ChargeList;
//var UDKAnimBlendBase LeapSlamList;

var UDKAnimBlendBase UpperMeleeList;
var UDKAnimBlendBase LowerMeleeList;
var UDKAnimBlendBase UpperBlockingList;
var UDKAnimBlendBase LowerBlockingList;
var UDKAnimBlendBase UpperChargeList;
var UDKAnimBlendBase LowerChargeList;
var UDKAnimBlendBase UpperLeapSlamList;
var UDKAnimBlendBase LowerLeapSlamList;

var repnotify byte UpperMeleeIndex;
var repnotify byte LowerMeleeIndex;
var repnotify byte UpperBlockingIndex;
var repnotify byte LowerBlockingIndex;
var repnotify byte UpperChargeIndex;
var repnotify byte LowerChargeIndex;
var repnotify byte UpperLeapSlamIndex;
var repnotify byte LowerLeapSlamIndex;

enum AnimStateList
{
	_NORMAL,
	_MELEE,
	_BLOCKING,
	_CHARGE,
	_SHIELDBASH,
	_SHINKICK,
	_LEAPSLAM	
};

enum AnimMeleeList
{
	_CHOP,
	_SWING,
	_STAB
};

enum AnimBlockList
{
	_PREBLOCK,
	_BLOCKIDLE,
	_BLOCKEND
};

enum AnimChargeList
{
	_PRECHARGE,
	_CHARGING,
	_CHARGEEND
};

enum AnimLeapSlamList
{
	_PRELEAPSLAM,
	_LEAPSLAMAIR,
	_LEAPSLAMEND
};

enum WarriorAnimNodesFP
{
	STATES,
	MELEE,
	BLOCKING,
	CHARGE,
	LEAPSLAM
};

enum WarriorAnimNodesTP
{
	UPPERSTATE,
	LOWERSTATE,
	UPPERMELEE,
	LOWERMELEE,
	UPPERBLOCKING,
	LOWERBLOCKING,
	UPPERCHARGE,
	LOWERCHARGE,
	UPPERLEAPSLAM,
	LOWERLEAPSLAM
};

replication 
{     
	if(bNetDirty && !bNetOwner)
		UpperMeleeIndex,
		LowerMeleeIndex,
		UpperBlockingIndex,
		LowerBlockingIndex,
		UpperChargeIndex,
		LowerChargeIndex,
		UpperLeapSlamIndex,
		LowerLeapSlamIndex,
		RainbowKiller;
		
}

simulated function ReplicatedEvent(name VarName)
{
    if(VarName == 'UpperStateIndex')
	{
		
		//`log("Rep UpperState:"@UpperStateIndex);
		
		switch(UpperStateIndex)
		{
			case _NORMAL:
				ClientSetAnimState(UPPERSTATE, _NORMAL);
				break;
			case _MELEE:
				ClientSetAnimState(UPPERSTATE, _MELEE);
				break;
			case _BLOCKING:
				ClientSetAnimState(UPPERSTATE, _BLOCKING);
				break;
			case _CHARGE:
				ClientSetAnimState(UPPERSTATE, _CHARGE);
				break;
			case _SHIELDBASH:
				ClientSetAnimState(UPPERSTATE, _SHIELDBASH);
				break;
			case _SHINKICK:
				ClientSetAnimState(UPPERSTATE, _SHINKICK);
				break;
			case _LEAPSLAM:
				ClientSetAnimState(UPPERSTATE, _LEAPSLAM);
				break;
		}

		return;
	}
	else if(VarName == 'LowerStateIndex')
	{
		//`log("Rep LowerState:"@LowerStateIndex);
		
		switch(LowerStateIndex)
		{
			case _NORMAL:
				ClientSetAnimState(LOWERSTATE, _NORMAL);
				break;
			case _MELEE:
				ClientSetAnimState(LOWERSTATE, _MELEE);
				break;
			case _BLOCKING:
				ClientSetAnimState(LOWERSTATE, _BLOCKING);
				break;
			case _CHARGE:
				ClientSetAnimState(LOWERSTATE, _CHARGE);
				break;
			case _SHIELDBASH:
				ClientSetAnimState(LOWERSTATE, _SHIELDBASH);
				break;
			case _SHINKICK:
				ClientSetAnimState(LOWERSTATE, _SHINKICK);
				break;
			case _LEAPSLAM:
				ClientSetAnimState(LOWERSTATE, _LEAPSLAM);
				break;
		}
		
		return;
	}
	else if(VarName == 'UpperMeleeIndex')
	{
		//`log("Rep UpperMelee:"@UpperMeleeIndex);

		switch(UpperMeleeIndex)
		{
			case _CHOP:
				ClientSetAnimState(UPPERMELEE, _CHOP);
				break;
			case _SWING:
				ClientSetAnimState(UPPERMELEE, _SWING);
				break;
			case _STAB:
				ClientSetAnimState(UPPERMELEE, _STAB);
				break;
		}
		
		return;
	}
	else if(VarName == 'LowerMeleeIndex')
	{
		//`log("Rep LowerMelee:"@LowerMeleeIndex);
		
		switch(LowerMeleeIndex)
		{
			case _CHOP:
				ClientSetAnimState(LOWERMELEE, _CHOP);
				break;
			case _SWING:
				ClientSetAnimState(LOWERMELEE, _SWING);
				break;
			case _STAB:
				ClientSetAnimState(LOWERMELEE, _STAB);
				break;
		}
		
		return;
	}	
	else if(VarName == 'UpperBlockingIndex')
	{
		//`log("Rep UpperBlocking:"@UpperBlockingIndex);
		
		switch(UpperBlockingIndex)
		{
			case _PREBLOCK:
				ClientSetAnimState(UPPERBLOCKING, _PREBLOCK);
				break;
			case _BLOCKIDLE:
				ClientSetAnimState(UPPERBLOCKING, _BLOCKIDLE);
				break;
			case _BLOCKEND:
				ClientSetAnimState(UPPERBLOCKING, _BLOCKEND);
				break;
		}

		return;
	}
	else if(VarName == 'LowerBlockingIndex')
	{
		//`log("Rep LowerBlocking:"@LowerBlockingIndex);
		
		switch(LowerBlockingIndex)
		{
			case _PREBLOCK:
				ClientSetAnimState(LOWERBLOCKING, _PREBLOCK);
				break;
			case _BLOCKIDLE:
				ClientSetAnimState(LOWERBLOCKING, _BLOCKIDLE);
				break;
			case _BLOCKEND:
				ClientSetAnimState(LOWERBLOCKING, _BLOCKEND);
				break;
		}
		
		return;
	}	
	else if(VarName == 'UpperChargeIndex')
	{
		//`log("Rep UpperCharge:"@UpperChargeIndex);
		
		switch(UpperChargeIndex)
		{
			case _PRECHARGE:
				ClientSetAnimState(UPPERCHARGE, _PRECHARGE);
				break;
			case _CHARGING:
				ClientSetAnimState(UPPERCHARGE, _CHARGING);
				break;
			case _CHARGEEND:
				ClientSetAnimState(UPPERCHARGE, _CHARGEEND);
				break;
		}
		
		return;
	}
	else if(VarName == 'LowerChargeIndex')
	{
		//`log("Rep LowerCharge:"@LowerChargeIndex);
		
		switch(LowerChargeIndex)
		{
			case _PRECHARGE:
				ClientSetAnimState(LOWERCHARGE, _PRECHARGE);
				break;
			case _CHARGING:
				ClientSetAnimState(LOWERCHARGE, _CHARGING);
				break;
			case _CHARGEEND:
				ClientSetAnimState(LOWERCHARGE, _CHARGEEND);
				break;
		}

		return;
	}
	else if(VarName == 'UpperLeapSlamIndex')
	{
		//`log("Rep UpperLeapSlam:"@UpperLeapSlamIndex);
		
		switch(UpperLeapSlamIndex)
		{
			case _PRELEAPSLAM:
				ClientSetAnimState(UPPERLEAPSLAM, _PRELEAPSLAM);
				break;
			case _LEAPSLAMAIR:
				ClientSetAnimState(UPPERLEAPSLAM, _LEAPSLAMAIR);
				break;
			case _LEAPSLAMEND:
				ClientSetAnimState(UPPERLEAPSLAM, _LEAPSLAMEND);
				break;
		}
		
		return;
	}
	else if(VarName == 'LowerLeapSlamIndex')
	{
		//`log("Rep LowerLeapSlam:"@LowerLeapSlamIndex);
		
		switch(LowerLeapSlamIndex)
		{
			case _PRELEAPSLAM:
				ClientSetAnimState(LOWERLEAPSLAM, _PRELEAPSLAM);
				break;
			case _LEAPSLAMAIR:
				ClientSetAnimState(LOWERLEAPSLAM, _LEAPSLAMAIR);
				break;
			case _LEAPSLAMEND:
				ClientSetAnimState(LOWERLEAPSLAM, _LEAPSLAMEND);
				break;
		}
		
		return;
	}
	else if(VarName == 'RainbowKiller')
	{
		ClientKillRainbow();	
	}
    super.ReplicatedEvent(VarName);
}

simulated function PostBeginPlay()
{
	local MaterialInstanceConstant Material3P;
	
	super.PostBeginPlay();
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_Package_Lukas.Materials.Lambert_Param'); 
	Mesh.SetMaterial(0, MatInst); 
	
	Material3P = new(None) Class'MaterialInstanceConstant';
	Material3P.SetParent(Material'HLW_Package_Randolph.Materials.WarriorMat_Upper');
	ThirdPerson.SetMaterial(0, Material3P);
	
	Material3P = new(None) Class'MaterialInstanceConstant';
	Material3P.SetParent(Material'HLW_Package_Randolph.Materials.WarriorMat_Lower');
	ThirdPerson.SetMaterial(1, Material3P);
	
	//ThirdPerson.SetMaterial(0, MatInst);
	//Helmet.SetMaterial(0, MatInst); 
	//ThirdPerson.AttachComponentToSocket(Helmet, HelmetSocketTP);
	AttachWeapons();
	AttachComponent(ThirdPerson);
}

reliable client function KillRainbow()
{
	local ParticleSystemComponent PSCIterator;
	
	foreach AllOwnedComponents(class'ParticleSystemComponent', PSCIterator)
	{
		if(PSCIterator.Template == ParticleSystem'HLW_Package_Randolph.Farticles.RainbowRoad')
		{
			PSCIterator.DeactivateSystem();
		}
	}
	
	if(Role < ROLE_Authority)
	{
		ServerKillRainbow();
	}
}

reliable server function ServerKillRainbow()
{
	RainbowKiller++;
}

reliable client function ClientKillRainbow()
{
	local ParticleSystemComponent PSCIterator;

	foreach AllOwnedComponents(class'ParticleSystemComponent', PSCIterator)
	{
		if(PSCIterator.Template == ParticleSystem'HLW_Package_Randolph.Farticles.RainbowRoad')
		{
			PSCIterator.DeactivateSystem();
		}
	}
	
}

reliable client function ClientSetTeamColor(LinearColor NewTeamColor)
{
	super.ClientSetTeamColor(NewTeamColor);
	
	ClientSetMaterialVector(ThirdPerson, 0, 'TeamColor', NewTeamColor);
	ClientSetMaterialVector(ThirdPerson, 1, 'TeamColor', NewTeamColor);
    ClientSetMaterialVector(Mesh, 0, 'TeamColor', NewTeamColor);
	//ClientSetMaterialVector(Helmet, 0, 'TeamColor', NewTeamColor);
	ClientSetMaterialVector(WeaponTP, 0, 'TeamColor', NewTeamColor);
	ClientSetMaterialVector(ShieldTP, 0, 'TeamColor', NewTeamColor);
	ClientSetMaterialVector(ShieldTP, 1, 'TeamColor', NewTeamColor);
}

simulated function AttachWeapons()
{
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_mapProps.Materials.SwordMatMaster');
	WeaponTP.SetMaterial(0, MatInst);
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_mapProps.Materials.SheildMainMaster');
	ShieldTP.SetMaterial(0, MatInst);
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_mapProps.Materials.SheildMainMaster');
	ShieldTP.SetMaterial(1, MatInst);

	ThirdPerson.AttachComponentToSocket(WeaponTP, SwordSocketTP);
	ThirdPerson.AttachComponentToSocket(ShieldTP, ShieldSocketTP);
}


simulated function PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	
	if (SkelComp == Mesh)
    {
        CustomAnim = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('CustomAnimNode'));
        StateList = UDKAnimBlendBase(Mesh.FindAnimNode('StateList'));
		MeleeList = UDKAnimBlendBase(Mesh.FindAnimNode('MeleeList'));
		BlockingList = UDKAnimBlendBase(Mesh.FindAnimNode('BlockingList'));
    }
    
    if (SkelComp == ThirdPerson)
    {
    	CustomAnimTP_Upper = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('CustomUpperAnimation'));
    	CustomAnimTP_Lower = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('CustomLowerAnimation'));
		UpperStateList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('UpperStateList'));
		LowerStateList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('LowerStateList'));
		UpperMeleeList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('UpperMeleeList'));
		LowerMeleeList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('LowerMeleeList'));
		UpperBlockingList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('UpperBlockingList'));
		LowerBlockingList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('LowerBlockingList'));
		UpperChargeList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('UpperChargeList'));
		LowerChargeList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('LowerChargeList'));
		UpperLeapSlamList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('UpperLeapSlamList'));
		LowerLeapSlamList = UDKAnimBlendBase(ThirdPerson.FindAnimNode('LowerLeapSlamList'));		
    }
}

simulated function SetAnimState(byte AnimNode, byte AnimState, float BlendIn = 0.0f)
{
	switch(AnimNode)
	{
		case UPPERSTATE:
			super.SetAnimState(AnimNode, AnimState, BlendIn);
			return;
		case LOWERSTATE:
			super.SetAnimState(AnimNode, AnimState, BlendIn);
			return;
		case UPPERMELEE:
			UpperMeleeList.SetActiveChild(AnimState, BlendIn);
			MeleeList.SetActiveChild(AnimState, BlendIn);
			break;
		case LOWERMELEE:
			LowerMeleeList.SetActiveChild(AnimState, BlendIn);
			break;
		case UPPERBLOCKING:
			UpperBlockingList.SetActiveChild(AnimState, BlendIn);
			BlockingList.SetActiveChild(AnimState, BlendIn);
			break;
		case LOWERBLOCKING:
			LowerBlockingList.SetActiveChild(AnimState, BlendIn);
			break;
		case UPPERCHARGE:
			UpperChargeList.SetActiveChild(AnimState, BlendIn);
			break;
		case LOWERCHARGE:
			LowerChargeList.SetActiveChild(AnimState, BlendIn);
			break;
		case UPPERLEAPSLAM:
			UpperLeapSlamList.SetActiveChild(AnimState, BlendIn);
			break;
		case LOWERLEAPSLAM:
			LowerLeapSlamList.SetActiveChild(AnimState, BlendIn);
			break;	
	}

	if(Role < ROLE_Authority)
	{
		ServerSetAnimState(AnimNode, AnimState);
	}
}


reliable server function ServerSetAnimState(byte AnimNode, byte AnimState)
{
	switch(AnimNode)
	{
		case UPPERMELEE:
			UpperMeleeIndex = AnimState;
			return;
		case LOWERMELEE:
			LowerMeleeIndex = AnimState;
			return;
		case UPPERBLOCKING:
			UpperBlockingIndex = AnimState;
			return;
		case LOWERBLOCKING:
			LowerBlockingIndex = AnimState;
			return;
		case UPPERCHARGE:
			UpperChargeIndex = AnimState;
			return;
		case LOWERCHARGE:
			LowerChargeIndex = AnimState;
			return;
		case UPPERLEAPSLAM:
			UpperLeapSlamIndex = AnimState;
			return;
		case LOWERLEAPSLAM:
			LowerLeapSlamIndex = AnimState;
			return;
	}
	
	super.ServerSetAnimState(AnimNode, AnimState);
}

reliable client function ClientSetAnimState(byte AnimNode, byte AnimState)
{
	switch(AnimNode)
	{
		case UPPERMELEE:
			UpperMeleeList.SetActiveChild(AnimState, 0.0f);
			MeleeList.SetActiveChild(AnimState, 0.0f);
			return;
		case LOWERMELEE:
			LowerMeleeList.SetActiveChild(AnimState, 0.0f);
			return;
		case UPPERBLOCKING:
			UpperBlockingList.SetActiveChild(AnimState, 0.0f);
			BlockingList.SetActiveChild(AnimState, 0.0f);
			return;
		case LOWERBLOCKING:
			LowerBlockingList.SetActiveChild(AnimState, 0.0f);
			return;
		case UPPERCHARGE:
			UpperChargeList.SetActiveChild(AnimState, 0.0f);
			return;
		case LOWERCHARGE:
			LowerChargeList.SetActiveChild(AnimState, 0.0f);
			return;
		case UPPERLEAPSLAM:
			UpperLeapSlamList.SetActiveChild(AnimState, 0.0f);
			return;
		case LOWERLEAPSLAM:
			LowerLeapSlamList.SetActiveChild(AnimState, 0.0f);
			return;
	}
	
	super.ClientSetAnimState(AnimNode, AnimState);
}

simulated function AddDefaultInventory()
{
	super.AddDefaultInventory();
	
	//InvManager.CreateInventory(class'HLW_Melee_Longsword');
	InvManager.CreateInventory(class'HLW_Melee_Sword');
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	//HLW_HUD_Warrior(HLW_PlayerController(Controller).myHUD).ComboComponentHUD.Close();
	
	return super.Died(Killer, damageType, HitLocation);	
}

simulated function Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
}

simulated function Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
	local HLW_Ability_Charge ChargeAbility;

	// CJL notify the ability of the bump so it can do appropriate things there
	if(bIsCharging)
	{
		if(Other.IsA('HLW_Pawn') && AddToChargeHitActors(Other))
		{
			if(HLW_Pawn_Class(Other) != None)
			{
				if(IsSameTeam(HLW_Pawn_Class(Other)))
				{
					return;	
				}
			}
			
			ChargeAbility = HLW_Ability_Charge(HLW_PlayerController(Controller).GetAbility(1));

			if (ChargeAbility != none)
			{
				ChargeAbility.Bump(Other, OtherComp, HitNormal);
			}
			
			VoiceOver = VoiceCueChargeHit;
			PlayVoiceOver(VoiceOver);

			if (Role == ROLE_Authority)
			{
				PlaySound(ChargeHitSound,,,,Location);
			}
			
			//AbilityToMelee();
		}
	}
}

//Check For Landing To Transition To LeapEnding State
simulated function Landed( Vector HitNormal, Actor FloorActor )
{
	// Would be nice to find a way to keep all this contained in the Ability class
	local HLW_Ability_LeapSlam LeapSlamAbility;
	
	if (Controller != none && HLW_PlayerController(Controller) != none)
	{
		LeapSlamAbility = HLW_Ability_LeapSlam(HLW_PlayerController(Controller).GetAbility(4));
	}

	if(LeapSlamAbility != None && LeapSlamAbility.bIsLeapSlamming)
	{
		KillRainbow();
		LeapSlamAbility.GotoState('LeapEnding');
	}
	
	super.Landed(HitNormal, FloorActor);
}

simulated function CauseRagdoll()
{
	//ThrowActiveWeapons();
	super.CauseRagdoll();
}

reliable client function ClientCauseRagdoll()
{
	//ThrowActiveWeapons();
	super.ClientCauseRagdoll();
}

function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross)
{
	local float speed;
	speed = 2.0;

	switch(DoubleClickMove)
	{
		case DCLICK_Left:
			PlayAnimTP_Upper('CustomAnimTP', 'Warrior_Evade_Right', speed, 0.1927125*speed, 0.1927125*speed, false, true);
			PlayAnimTP_Lower('CustomAnimTP', 'Warrior_Evade_Right', speed, 0.1927125*speed, 0.1927125*speed, false, true);
			break;
		case DCLICK_Right:
			PlayAnimTP_Upper('CustomAnimTP', 'Warrior_Evade_Right', speed, 0.1927125*speed, 0.1927125*speed, false, true);
			PlayAnimTP_Lower('CustomAnimTP', 'Warrior_Evade_Right', speed, 0.1927125*speed, 0.1927125*speed, false, true);
			break;	
	}
	
	
	return super.PerformDodge(DoubleClickMove, Dir, Cross);	
}

simulated function Destroyed()
{
	super.Destroyed();
	
	MeleeList = None;
	BlockingList = None;
	UpperMeleeList = None;
	LowerMeleeList = None;
	UpperBlockingList = None;
	LowerBlockingList = None;
	UpperChargeList = None;
	LowerChargeList = None;
	UpperLeapSlamList = None;
	LowerLeapSlamList = None;	
}

function ThrowActiveWeapons()
{
	local vector	POVLoc, TossVel, TossLoc;
	local rotator	POVRot, TossRot;

	GetActorEyesViewPoint(POVLoc, POVRot);
	TossVel = Vector(POVRot);
	TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,200);

	if(CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.DetachFrom(ThirdPerson);
		CurrentWeaponAttachment.Destroy();
	}
	
	ThirdPerson.GetSocketWorldLocationAndRotation(SwordSocketTP, TossLoc, TossRot);
	
	SwordWeapon.DropWeapons(TossLoc, TossRot);
}

simulated function AbilityToMelee()
{
	local HLW_Melee_Longsword Inv;
	
	foreach InvManager.InventoryActors( Class'HLW_Melee_Longsword', Inv )
	{
		//`log("CHANGING");
		InvManager.SetCurrentWeapon( (Inv) );
		InvManager.ServerSetCurrentWeapon( (Inv) );
		break;
	}
}

//Adds Hit Actor To Array (Prevents Hitting An Actor More Than Once Per Attack)
simulated function bool AddToChargeHitActors(Actor HitActor)
{
   local int index;

   for (index = 0; index < ChargeHitActors.Length; index++)
   {
      if (ChargeHitActors[index] == HitActor)
      {
         return false;
      }
   }

   ChargeHitActors.AddItem(HitActor);
   return true;
}

simulated function FlushChargeHitActors()
{
	ChargeHitActors.Remove(0, ChargeHitActors.Length);	
}

simulated function SetCharging()
{
	bIsCharging = true;	
}

simulated function DisableCharging()
{
	bIsCharging = false;	
}

simulated function StartBlock()
{
	if(bNoBlocking)
	{
		//`log("Can't Block");
		return;	
	}
	
	if(HLW_Melee_Weapon(Weapon) != None)
	{
		ClearTimer('AllowAttack');
		bNoWeaponFiring = true;
		bIsBlocking = true;
		HLW_Melee_Weapon(Weapon).GotoState('Blocking');
		//HLW_Melee_Weapon(Weapon).StartBlock();
	}
	
	if(HLW_Melee_Wep(Weapon) != None)
	{
		HLW_Melee_Wep(Weapon).StartAlternateAttack();	
	}
	
	if(Role < ROLE_Authority)
	{
		ServerStartBlock();
	}
}
reliable server function ServerStartBlock()
{
	StartBlock();
}

simulated function StopBlock()
{
	if(HLW_Melee_Weapon(Weapon) != None)
	{
		SetTimer(0.5f, false, 'AllowAttack');
		HLW_Melee_Weapon(Weapon).StopBlock();
		HLW_Melee_Weapon(Weapon).GoToState('Active');
	}
	
	if(HLW_Melee_Wep(Weapon) != None)
	{
		//`log("Pawn Stop Block");
		HLW_Melee_Wep(Weapon).StopAlternateAttack();	
	}
	
	if(Role < ROLE_Authority)
	{
		ServerStopBlock();
	}
}
reliable server function ServerStopBlock()
{
	StopBlock();
}

function ApplyStatusEffect(HLW_StatusEffect StatusEffect, Controller EffectInstigator, optional Actor EffectOwner)
{
	if(!bIsBlocking)
	{
		super.ApplyStatusEffect(StatusEffect, EffectInstigator);
	}	
} 

simulated event Tick(float DeltaTime)
{
	if(HLW_Melee_Weapon(Weapon) != None)
	{
		if(Weapon != None && !bIsBlocking && bBlockHeld && !HLW_Melee_Weapon(Weapon).bIsAttacking)
		{
			StartBlock();
		}
	}
	
	if(HLW_Melee_Wep(Weapon) != None && bBlockHeld)
	{
		StartBlock();
	}
	
	super.Tick(DeltaTime);
}

simulated function PlayerInitialized()
{
	super.PlayerInitialized();
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(1, "Charge", 1);
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(2, "Bash", 1);
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(3, "Ham", 1);
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(4, "Leap", 1);
}

simulated function AllowAttack()
{
	bNoWeaponFiring = false;
}

simulated function ScaleMovement(float Rate)
{
	MovementSpeedModifier += Rate;
	
	if(MovementSpeedModifier < 0.0f)
	{
		MovementSpeedModifier = 0.0f;
	}
	else if(MovementSpeedModifier > 1.0f)
	{
		MovementSpeedModifier = 1.0f;
	}
}

simulated function ScaleDamage(float Rate)
{
	DamageScaling += Rate;
	
	if(DamageScaling < 0.0f)
	{
		DamageScaling = 0.0f;
	}
	else if(DamageScaling > 1.0f)
	{
		DamageScaling = 1.0f;
	}
}

//****************************
//ATTACK ANIMATION REPLICATION
//****************************

simulated function WarriorChop()
{
	PlayAnim('CustomAnim', 'Warrior_Hands_Chop', 1.0, 0.078125, 0.078125, false, true);
}

simulated function WarriorChopTP()
{
	PlayAnimTP_Upper('CustomAnimTP', 'Warrior_Upper_Chop', 1.0, 0.078125, 0.078125, false, true);
}

simulated function WarriorSwing()
{
	PlayAnim('CustomAnim', 'Warrior_Hands_Swing', 1.0, 0.125, 0.125, false, true);
}

simulated function WarriorSwingTP()
{
	PlayAnimTP_Upper('CustomAnimTP', 'Warrior_Upper_Swing', 1.0, 0.125, 0.125, false, true);
}

simulated function WarriorStab()
{
	PlayAnim('CustomAnim', 'Warrior_Hands_Stab', 1.0, 0.0833375, 0.0833375, false, true);
}

simulated function WarriorStabTP()
{
	PlayAnimTP_Upper('CustomAnim', 'Warrior_Upper_Stab', 1.0, 0.0833375, 0.0833375, false, true);
}

simulated function WarriorDanceTP()
{
	PlayAnimTP_Upper('CustomAnim', 'Warrior_Upper_Dance', 0.78, 0.0989625, 0.0989625, true, true);
	PlayAnimTP_Lower('CustomAnim', 'Warrior_Lower_Dance', 0.78,  0.515625, 0.515625, true, true);
	
	SetTimer(5.25,false,'StopDoDance');
}

simulated function StopDoDance()
{
	CustomAnimTP_Upper.StopCustomAnim(0.0f);
	CustomAnimTP_Lower.StopCustomAnim(0.0f);
}
//****************************
//BLOCK ANIMATION REPLICATION
//****************************

simulated function WarriorPreBlock()
{
	PlayAnim('CustomAnim', 'Warrior_Hands_Block_Pre', 1.0, 0.0729125, 0.0729125, false, true);
	PlayAnimTP_Upper('CustomAnimTP', 'Warrior_Upper_Block_Pre', 1.0, 0.0729125, 0.0729125, false, true);
}

simulated function WarriorBlockIdle()
{
	PlayAnim('CustomAnim', 'Warrior_Hands_Block_Idle', 1.0, 0.3072875, 0.3072875, true, true);
	PlayAnimTP_Upper('CustomAnimTP', 'Warrior_Upper_Block_Idle', 1.0, 0.2447875, 0.2447875, true, true);
}

simulated function WarriorExitBlock()
{
	PlayAnim('CustomAnim', 'Warrior_Hands_Block_Reverse', 1.0, 0.0729125, 0.0729125, false, true);
	PlayAnimTP_Upper('CustomAnimTP', 'Warrior_Upper_Block_Reverse', 1.0, 0.0729125, 0.0729125, false, true);
	
	
}

//****************************
//HIT REACTION ANIMATION REPLICATION
//****************************

simulated function TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(Role < ROLE_Authority)
	{
		if(bCanHitReaction && !bIsAttacking)
		{
			HitReaction();
		}
    }
	
	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

//reliable server function ResetHurtVO()
//{
	//`log("Reset Hurt VO");
	//bCanHurtVO = true;	
//}

simulated function SetIsBlocking(bool Blocking)
{
	bIsBlocking = Blocking;
}

simulated function SetIsAttacking(bool Attacking)
{
	bIsAttacking = Attacking;
}

simulated function HitReaction()
{

	if(!bIsBlocking)
	{
		PlayAnimTP_Upper('CustimAnimTP', 'Warrior_Upper_HitReaction', 1.0, 0.05, 0.05, false, true);
	}
	else
	{
		PlayAnimTP_Upper('CustimAnimTP', 'Warrior_Upper_Block_HitReaction', 1.0, 0.05, 0.05, false, true);
		SetTimer(0.4f, false, 'ResetBlockIdle');
	}
	
	bCanHitReaction = false;
	SetTimer(1.5f, false, 'ResetHitReaction');	
}

simulated function ResetBlockIdle()
{
	if(bIsBlocking)
	{
		WarriorBlockIdle();
	}
}

simulated function ResetHitReaction()
{
	bCanHitReaction = true;	
}

//Decide Whether I Am Attacking (Called At Attack Animation Start + End)
simulated function StartAttackStatus()
{
	//`log("Starting Attack Status");
	if(HLW_Melee_Longsword(Weapon) != None)
	{
		HLW_Melee_Longsword(Weapon).EnableAttackStatus();
		HLW_Melee_Longsword(Weapon).DisableCompletedAttackStatus();
		HLW_Melee_Longsword(Weapon).DisableTraceStatus();
	}
	
	if(Role < ROLE_Authority)
	{
		ServerStartAttackStatus();	
	}
}
reliable server function ServerStartAttackStatus()
{
	StartAttackStatus();
}

simulated function EndAttackStatus()
{
	//`log("Ending Attack Status");
	if(HLW_Melee_Longsword(Weapon) != None)
	{
		HLW_Melee_Longsword(Weapon).DisableAttackStatus();
		HLW_Melee_Longsword(Weapon).DisableTraceStatus();
		HLW_Melee_Longsword(Weapon).EnableCompletedAttackStatus();
	}
	
	if(Role < ROLE_Authority)
	{
		ServerEndAttackStatus();	
	}
}
reliable server function ServerEndAttackStatus()
{
	EndAttackStatus();
}

//Decide Whether I Can Trace Attack (Called At Specific Point In Animation + End)
simulated function UpdateTraceStatus()
{
	//`log("Updating Trace Status");
	if(HLW_Melee_Longsword(Weapon) != None)
	{
		HLW_Melee_Longsword(Weapon).EnableTraceStatus();
	}
	
	if(Role < ROLE_Authority)
	{
		ServerUpdateTraceStatus();	
	}
}
reliable server function ServerUpdateTraceStatus()
{
	UpdateTraceStatus();
}

simulated function LeapStartEnd()
{
	// Would be nice to find a way to keep all this contained in the Ability class
	local HLW_Ability_LeapSlam LeapSlamAbility;

	if (Controller != none && HLW_PlayerController(Controller) != none)
	{
		LeapSlamAbility = HLW_Ability_LeapSlam(HLW_PlayerController(Controller).GetAbility(4));
	}

	if(LeapSlamAbility != None)
	{
		LeapSlamAbility.LeapStartEnd();
	}
	
	if(Role < ROLE_Authority)
	{
		ServerLeapStartEnd();	
	}

}
reliable server function ServerLeapStartEnd()
{
	LeapStartEnd();	
}

DefaultProperties
{
	Begin Object Name=ArmsMesh
		SkeletalMesh=SkeletalMesh'HLW_Package_Dan.models.warrior1stPerson'
		AnimSets(0)=AnimSet'HLW_Package_Randolph.Animations.1p_warrior_animset'
		AnimTreeTemplate=AnimTree'HLW_Package_Randolph.Animations.Warrior_AnimTree_1P'//AnimTree'HLW_Package_Randolph.Animations.1p_warrior_animtree'
		Translation=(X=-2.0, Y=0.0, Z=-30.0)
	End Object
	
	Begin Object Name=ThirdPersonMesh
		bHasPhysicsAssetInstance=true
		AnimSets(0)=AnimSet'HLW_Package_Randolph.Animations.3p_Warrior_Animset_HatchIsJerk'
		AnimTreeTemplate=AnimTree'HLW_Package_Randolph.Animations.Warrior_AnimTree_3P'//AnimTree'HLW_CONNOR_PAKAGE.Animations.3p_Warrior_Animtree'
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Warrior_New_3'//SkeletalMesh'HLW_Package_Randolph.models.Warrior_New_Model'//SkeletalMesh'HLW_Package_Randolph.models.NewWarriorTest'//SkeletalMesh'HLW_Package.Models.3p_Warrior_Base_Temp'
		PhysicsAsset=PhysicsAsset'HLW_Package.Physics.3p_Warrior_Physics'
	End Object
	
	Begin Object Class=StaticMeshComponent Name=ThirdPersonHelmetMesh
		CastShadow = true
		bOwnerNoSee=true
		StaticMesh=StaticMesh'HLW_Package.Models.Warrior_Helmet'
		bCastHiddenShadow=true
	End Object
	Helmet=ThirdPersonHelmetMesh
	
	Begin Object Class=SkeletalMeshComponent Name=SM_TP
		bAcceptsDynamicDecals=true //Future Blood Decals?
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bCacheAnimSequenceNodes=false
		bCastDynamicShadow=true
		bCastHiddenShadow=true
		CastShadow=true
		bChartDistanceFactor=true
		bIgnoreControllersWhenNotRendered=false
		bOnlyOwnerSee=false
		bOverrideAttachmentOwnerVisibility=true
		bPerBoneMotionBlur=true
		bUseOnePassLightingOnTranslucency=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		RBDominanceGroup=20
		MinDistFactorForKinematicUpdate=0.2f
		Rotation=(Roll=50973, Pitch=16384, Yaw=16384)
		Translation=(X=-3.0, Y=2.5, Z=-1.0)
		Scale=1.25
		SkeletalMesh=SkeletalMesh'HLW_Package.Models.Longsword'
	End Object
	WeaponTP=SM_TP
	
	Begin Object Class=SkeletalMeshComponent Name=Shield_TP
		bAcceptsDynamicDecals=true //Future Blood Decals?
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bCacheAnimSequenceNodes=false
		bCastDynamicShadow=true
		bCastHiddenShadow=true
		CastShadow=true
		bChartDistanceFactor=true
		bIgnoreControllersWhenNotRendered=false
		bOnlyOwnerSee=false
		bOverrideAttachmentOwnerVisibility=true
		bPerBoneMotionBlur=true
		bUseOnePassLightingOnTranslucency=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		RBDominanceGroup=20
		MinDistFactorForKinematicUpdate=0.2f
		Scale=1.25
		SkeletalMesh=SkeletalMesh'HLW_Package.Models.Warrior_Shield'
	End Object
	ShieldTP=Shield_TP
	
	
	//Weapon SkeletalMesh
	Begin Object Class=SkeletalMeshComponent Name=WeaponSkeletalMesh
		bHasPhysicsAssetInstance=true
		bOwnerNoSee=false
		bOnlyOwnerSee=false
		CollideActors=true
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		MaxDrawDistance=4000
		bForceRefPose=1
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		CastShadow=true
		bCastDynamicShadow=true
		bPerBoneMotionBlur=true
		Scale=1.25
		SkeletalMesh=SkeletalMesh'HLW_CONNOR_PAKAGE.Physics.Longsword_Deco_Skele'
		PhysicsAsset=PhysicsAsset'HLW_CONNOR_PAKAGE.Physics.Longsword_Deco_Skele_Physics'
	End Object
	DroppedWeaponMesh=WeaponSkeletalMesh
	DroppedWeaponClass=HLW_M_Longsword_DroppedPickup
	
	//Shield SkeletalMesh
	Begin Object Class=SkeletalMeshComponent Name=ShieldSkeletalMesh
		bHasPhysicsAssetInstance=true
		bOwnerNoSee=false
		bOnlyOwnerSee=false
		CollideActors=true
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		MaxDrawDistance=4000
		bForceRefPose=1
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=false
		CastShadow=true
		bCastDynamicShadow=true
		bPerBoneMotionBlur=true
		Scale=1.25
		SkeletalMesh=SkeletalMesh'HLW_CONNOR_PAKAGE.Physics.Warrior_Shield_Skele'
		PhysicsAsset=PhysicsAsset'HLW_CONNOR_PAKAGE.Physics.Warrior_Shield_Skele_Physics'
	End Object
	DroppedShieldMesh=ShieldSkeletalMesh
	DroppedShieldClass=HLW_M_Longsword_DroppedPickup
	
	SwordSocket=Warrior_Palm_R
	ShieldSocket=Warrior_Shield_Socket
	SwordSocketTP=Warrior_Hand_Right_TP
	ShieldSocketTP=Warrior_Shield_Socket
	HelmetSocketTP=Warrior_Head_Socket
	HeadBone=Warrior1_Head
	
	bBlockHeld=false
	bIsBlocking=false
	bCanHitReaction=true
	
	bNoBlocking=false
	
	RainbowKiller=255
	
	//GroundSpeed=410
	
	BasePhysicalPower=40.0
	BaseMagicalPower=0.0
	BasePhysicalDefense=0.0
	BaseMagicalDefense=0.0
	BaseCooldownReduction=0.0
	BaseMovementSpeed=350
	BaseAttackSpeed=1.0
	BaseHealth=400
	BaseHealthMax=400
	BaseMana=175
	BaseManaMax=175
	BaseHP5=6.0
	BaseMP5=10.0
	BaseResistance=0.0

	ManaIncreaseOnLevelPercentage=0.24
	HealthIncreaseOnLevelPercentage=0.23
	PhysicalPowerIncreaseOnLevelPercentage=0.4
	MagicalPowerIncreaseOnLevelPercentage=0.0
	HP5IncreaseOnLevelPercentage=0.22
	MP5IncreaseOnLevelPercentage=0.23

	AbilityClasses(0)=class'HLW_Ability_Chase' // PASSIVE
	AbilityClasses(1)=class'HLW_Ability_Charge' // 1
	AbilityClasses(2)=class'HLW_Ability_ShieldBash' // 2
	AbilityClasses(3)=class'HLW_Ability_Hamstring' // 3
	AbilityClasses(4)=class'HLW_Ability_LeapSlam' // 4 (Ultimate)
	
	CurrentTeamColor=(R=0,G=0,B=0,A=0)
	
	VoiceCueDied=SoundCue'HLW_Package_Voices.Warrior.Died'
	VoiceCueIdle=SoundCue'HLW_Package_Voices.Warrior.Idle'
	VoiceCueLevelUp=SoundCue'HLW_Package_Voices.Warrior.LevelUp'
	VoiceCueHurt=SoundCue'HLW_Package_Randolph.Sounds.Warrior_Hurt'
	VoiceCueKill=SoundCue'HLW_Package_Randolph.Sounds.Warrior_KillPlayer'
	VoiceCueChargeHit=SoundCue'HLW_Package_Randolph.Sounds.Ability_Charge_Hit'
	ChargeHitSound=SoundCue'HLW_Package_Chris.SFX.Warrior_Ability_ChargeHit'
}