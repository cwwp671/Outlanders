/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Melee_Sword extends HLW_Melee_Wep;

enum AnimStateList
{
	NORMAL,
	MELEE,
	BLOCKING,
	CHARGE,
	SHIELDBASH,
	SHINKICK,
	LEAPSLAM	
};

enum WarriorAnimNodes
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

enum AnimMeleeList
{
	CHOP,
	SWING,
	STAB
};

enum AnimBlockList
{
	PREBLOCK,
	BLOCKIDLE,
	BLOCKEND
};

var Tracer TracersFP[5];
var Tracer TracersTP[5];

var SkeletalMeshComponent ShieldFP;
var SkeletalMeshComponent ShieldTP;

var Name ShieldSocketFP;
var Name ShieldSocketTP;

var Array<Material> ShieldMaterialsFP;
var Array<Material> ShieldMaterialsTP;

simulated state Attacking
{
	simulated function BeginState(Name PreviousStateName)
	{
		local HLW_Pawn_Class_Warrior Pawn;
		
		//AttackNextIndex();
		//CalculateAttackEndTime();

		super.BeginState(PreviousStateName);
		
		Pawn = HLW_Pawn_Class_Warrior(Owner);
		
		Pawn.SetAnimState(UPPERSTATE, MELEE, 0.0f);
		
		//`log("Attack LastIndex:"@Attack.LastIndex);
		//`log("Attack NextIndex:"@Attack.NextIndex);
		
		Pawn.SetAnimState(UPPERMELEE, AttackAnims[Attack.LastIndex], CalculateBlendIn());
	}
	
	simulated function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);
		
		if(bFirstPersonTrace)
		{
			UpdateTracers(TracersFP);
			TraceAttack(TracersFP);	
		}
		else
		{
			UpdateTracers(TracersTP);
			TraceAttack(TracersTP);
		}
	}
	
	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);	
	}
}

simulated state Blocking
{
	simulated function BeginState(Name PreviousStateName)
	{
		local HLW_Pawn_Class_Warrior Pawn;	
		
		super.BeginState(PreviousStateName);
		
		Pawn = HLW_Pawn_Class_Warrior(Owner);
		Pawn.SetAnimState(UPPERSTATE, BLOCKING, 0.0f);
		Pawn.SetAnimState(UPPERBLOCKING, PREBLOCK, 0.05f);
	}
	
	simulated function EndState(Name NextStateName)
	{
		local HLW_Pawn_Class_Warrior Pawn;
		
		Pawn = HLW_Pawn_Class_Warrior(Owner);
		Pawn.SetAnimState(UPPERBLOCKING, BLOCKEND, 0.05f);
		ResetAnims();
		super.EndState(NextStateName);	
	}
}

simulated function EnterBlock()
{
	local HLW_Pawn_Class_Warrior Pawn;
		
	Pawn = HLW_Pawn_Class_Warrior(Owner);
	Pawn.SetAnimState(UPPERBLOCKING, BLOCKIDLE, 0.0f);
		
	super.EnterBlock();	
}

simulated function UpdateTracers(Tracer AttackTracers[5])
{
	local int i;
	
	for(i = 0; i < ArrayCount(AttackTracers); i++)
	{
		if(bFirstPersonTrace)
		{
			TracersFP[i].Position =	GetSocketLocation(WeaponSocketsFP[i]);
		}
		else
		{
			TracersTP[i].Position = GetSocketLocation(WeaponSocketsTP[i]);
		}
	}	
}

simulated function TraceAttack(Tracer AttackTracers[5])
{
	local Actor HitActor;
	local Vector HitLocation;
	local Vector HitNormal;
	local Vector HitMomentum;
	local TraceHitInfo TracerHitInfo;
	//local HLW_StatusEffect_Bleed BleedStatus;
	local int i;
	local float Damage;
	
	for(i = 0; i < ArrayCount(AttackTracers) - 1; i++)
	{
		foreach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, AttackTracers[i].Position, AttackTracers[i + 1].Position,, TracerHitInfo)
		{
			if(HitActor != self && AddToHitActors(HitActor))
			{
					if(HitActor.IsA('HLW_Pawn') && !Pawn(Owner).IsSameTeam(HLW_Pawn(HitActor)))
					{
						HitInfo.bHitPawn = true;
						//BleedStatus = Spawn(class'HLW_StatusEffect_Bleed');
						//HLW_Pawn(HitActor).ApplyStatusEffect(BleedStatus, Instigator.Controller, self);
						PlaySound(HitInfo.PawnImpact,,,, HitLocation);
						HLW_Pawn_Class(Owner).SpawnEmitter(HitInfo.PawnImpactParticle, HitLocation, rotator(HitNormal), true, 6.0f);
						
						Damage = AttackDamages[Attack.LastIndex];
						Damage += int(Damage * float(Combo.Counter) * Combo.DamageModifier); //Combo Calculation
						Damage += HLW_Pawn_Class(Owner).GetPRI().PhysicalPower * AttackPhysPowerPercentages[Attack.LastIndex];
						HitMomentum = Normal(HitLocation - Owner.Location) * AttackMomentums[Attack.LastIndex];
						
						//if(Role == ROLE_Authority)
						//{
							HitActor.TakeDamage(Damage, Instigator.Controller, HitLocation, HitMomentum, MyDamageType, TracerHitInfo, self);
							//HLW_Pawn(HitActor).SpawnImpactDecal(HitActor, HitLocation, HitNormal, TracerHitInfo);
						//}
					}
					else
					{
						Damage = AttackDamages[Attack.LastIndex];
						Damage += int(Damage * float(Combo.Counter) * Combo.DamageModifier); //Combo Calculation
						Damage += HLW_Pawn_Class(Owner).GetPRI().PhysicalPower * AttackPhysPowerPercentages[Attack.LastIndex];
						HitMomentum = Normal(HitLocation - Owner.Location) * AttackMomentums[Attack.LastIndex];
						HitActor.TakeDamage(Damage, Instigator.Controller, HitLocation, HitMomentum, MyDamageType,, self);
					}
			}
		}
	}
}

simulated function AttachWeapon()
{
	local HLW_Pawn_Class Pawn;
	local LinearColor TeamColor;
	local MaterialInstanceConstant MatInst;
	local int i;
	
	Pawn = HLW_Pawn_Class(Owner);
	TeamColor = HLW_Pawn_Class_Warrior(Owner).CurrentTeamColor;
	
	if(ShieldFP.SkeletalMesh != None)
	{
		ShieldFP.SetShadowParent(Pawn.Mesh);
		
		for(i = 0; i < ShieldMaterialsFP.Length; i++)
		{
			MatInst = new(None) Class'MaterialInstanceConstant';
			MatInst.SetParent(ShieldMaterialsFP[i]);
			MatInst.SetVectorParameterValue('TeamColor', TeamColor);
			ShieldFP.SetMaterial(i, MatInst);
		}
		
		Pawn.Mesh.AttachComponentToSocket(ShieldFP, ShieldSocketFP);
	}
	
	if(ShieldTP.SkeletalMesh != None)
	{
		ShieldTP.SetShadowParent(Pawn.ThirdPerson);
		
		for(i = 0; i < ShieldMaterialsTP.Length; i++)
		{
			MatInst = new(None) Class'MaterialInstanceConstant';
			MatInst.SetParent(ShieldMaterialsTP[i]);
			MatInst.SetVectorParameterValue('TeamColor', TeamColor);
			ShieldTP.SetMaterial(i, MatInst);		
		}
		
		Pawn.ThirdPerson.AttachComponentToSocket(ShieldTP, ShieldSocketTP);
	}
	
	super.AttachWeapon();
}

simulated function Tick(float DeltaTime)
{
	if(Role < ROLE_Authority)
	{
		if(bComboEnabled)
		{
			if(HLW_Pawn_Class_Warrior(Owner) != None && HLW_Pawn_Class_Warrior(Owner).Controller != none)
			{
				HLW_HUD_Warrior(HLW_PlayerController(HLW_Pawn_Class_Warrior(Owner).Controller).myHUD).ComboComponentHUD.CallUpdateCombo(100 + (Combo.Counter * (Combo.DamageModifier*100)));
			}
		}
	}
}

defaultproperties
{	
	bBlockEnabled=true
	bChargeAttackEnabled=false
	bComboEnabled=true
	bStaggerEnabled=false
	bFirstPersonTrace=false
	bSingleAttackState=true
	bUseSocketTraceOrder=false
	
	Attack=(bActive=false, EndIndex=2, LastIndex=0, NextIndex=0, EndTime=0.00, ResetTime=2.00)
	Combo=(bActive=false, bResetAttacks=false, Counter=0, ResetTime=2.00, DamageModifier=0.15, VO=SoundCue'HLW_Package_Randolph.Sounds.Warrior_Combo')
	HitInfo=(PawnImpact=SoundCue'HLW_Package_Randolph.Sounds.FleshImpact_Sound')
	Stagger=(bActive=false, ResetTime=2.00)
	Block=(bCanSpam=true, bPerfectEnabled=true, RaiseTime=0.45, PerfectTime=0.40, MovementModifier=0.00, PerfectDamageModifier=1.00, DamageModifier=0.50)
	
	AttackAnims(0)=0
	AttackAnims(1)=1
	AttackAnims(2)=2
	
	AttackDamages(0)=20 //Chop
	AttackDamages(1)=20 //Swing
	AttackDamages(2)=20 //Stab
	
	AttackMomentums(0)=10000 //Chop
	AttackMomentums(1)=10000 //Swing
	AttackMomentums(2)=10000 //Stab
	
	AttackPhysPowerPercentages(0)=0.2000 //Chop
	AttackPhysPowerPercentages(1)=0.2000 //Swing
	AttackPhysPowerPercentages(2)=0.2000 //Stab
	
	AttackAnimLengthsFP(0)=0.6250 //Length of Chop Anim in AnimSet
	AttackAnimLengthsFP(1)=1.0000 //Length of Swing Anim in AnimSet
	AttackAnimLengthsFP(2)=0.6667 //Length of Stab Anim in AnimSet
	AttackAnimRatesFP(0)=1.0000
	AttackAnimRatesFP(1)=1.0000
	AttackAnimRatesFP(2)=1.0000
	AttackAnimBlendInsFP(0)=0.0781 //12.5% of Chop Anim Length
	AttackAnimBlendInsFP(1)=0.1250 //12.5% of Swing Anim Length
	AttackAnimBlendInsFP(2)=0.0834 //12.5% of Stab Anim Length
	
	AttackAnimLengthsTP(0)=0.6250 //Length of Chop Anim in AnimSet
	AttackAnimLengthsTP(1)=1.0000 //Length of Swing Anim in AnimSet
	AttackAnimLengthsTP(2)=0.6667 //Length of Stab Anim in AnimSet
	AttackAnimRatesTP(0)=1.0000
	AttackAnimRatesTP(1)=1.0000
	AttackAnimRatesTP(2)=1.0000
	AttackAnimBlendInsTP(0)=0.0781 //12.5% of Chop Anim Length
	AttackAnimBlendInsTP(1)=0.1250 //12.5% of Swing Anim Length
	AttackAnimBlendInsTP(2)=0.0834 //12.5% of Stab Anim Length
	
	WeaponSocketFP=Warrior_Palm_R
	WeaponSocketsFP(0)=blade_left_1_socket
	WeaponSocketsFP(1)=blade_left_8_socket
	WeaponSocketsFP(2)=blade_tip_socket
	WeaponSocketsFP(3)=blade_right_8_socket
	WeaponSocketsFP(4)=blade_right_1_socket
	
	WeaponSocketTP=Warrior_Hand_Right_TP
	WeaponSocketsTP(0)=blade_left_1_socket
	WeaponSocketsTP(1)=blade_left_8_socket
	WeaponSocketsTP(2)=blade_tip_socket
	WeaponSocketsTP(3)=blade_right_8_socket
	WeaponSocketsTP(4)=blade_right_1_socket
	
	WeaponMaterialsFP(0)=Material'HLW_mapProps.Materials.SwordMatMaster'
	WeaponMaterialsTP(0)=Material'HLW_mapProps.Materials.SwordMatMaster'
	
	ShieldSocketFP=Warrior_Shield_Socket
	ShieldSocketTP=Warrior_Shield_Socket
	ShieldMaterialsFP(0)=Material'HLW_mapProps.Materials.SheildMainMaster'
	ShieldMaterialsFP(1)=Material'HLW_mapProps.Materials.SheildMainMaster'
	ShieldMaterialsTP(0)=Material'HLW_mapProps.Materials.SheildMainMaster'
	ShieldMaterialsTP(1)=Material'HLW_mapProps.Materials.SheildMainMaster'
	
	
	MyDamageType=class'HLW_DamageType_Physical'
	
	Begin Object Name=SM_FP
		Rotation=(Roll=16384, Yaw=49152)
		Translation=(X=-1.0)
		SkeletalMesh=SkeletalMesh'HLW_Package.Models.Longsword'
	End Object
	WeaponFP=SM_FP
	Components.Add(SM_FP)
	
	Begin Object Name=SM_TP
		Rotation=(Roll=50973, Pitch=16384, Yaw=16384)
		Translation=(X=-3.0, Y=2.5, Z=-1.0)
		Scale=1.25
		SkeletalMesh=SkeletalMesh'HLW_Package.Models.Longsword'
	End Object
	WeaponTP=SM_TP
	Components.Add(SM_TP)
	
	Begin Object Class=SkeletalMeshComponent Name=Shield_FP
		bAcceptsDynamicDecals=true //Future Blood Decals?
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bCacheAnimSequenceNodes=false
		bCastDynamicShadow=false
		CastShadow=false
		bChartDistanceFactor=true
		bIgnoreControllersWhenNotRendered=false
		bOnlyOwnerSee=true //Only Visible To Player
		bOverrideAttachmentOwnerVisibility=true
		bPerBoneMotionBlur=true
		bUseOnePassLightingOnTranslucency=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		RBDominanceGroup=20
		MinDistFactorForKinematicUpdate=0.2f
		SkeletalMesh=SkeletalMesh'HLW_Package.Models.Warrior_Shield'
	End Object
	ShieldFP=Shield_FP
	Components.Add(Shield_FP)
	
	Begin Object Class=SkeletalMeshComponent Name=Shield_TP
		bAcceptsDynamicDecals=true //Future Blood Decals?
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bCacheAnimSequenceNodes=false
		bCastDynamicShadow=true
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
	Components.Add(Shield_TP)
}