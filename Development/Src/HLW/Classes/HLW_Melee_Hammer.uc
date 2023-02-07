class HLW_Melee_Hammer extends HLW_Melee_Wep;

enum AnimStateList
{
	NORMAL,
	MELEE,
	BLOCKING,
	HAMMERTOSS,
	GROUNDSLAM,
	BASEBALLSWING,
	RALLY	
};

enum BarbarianAnimNodesTP
{
	UPPERSTATE,
	LOWERSTATE,
	UPPERMELEE,
	LOWERMELEE,
	UPPERBLOCKING,
	LOWERBLOCKING
};

enum AnimMeleeList
{
	ATTACK1,
	ATTACK1IDLE,
	ATTACK2,
	ATTACK2IDLE,
	ATTACK3,
	ATTACK3IDLE,
	ATTACK4
};

enum AnimBlockList
{
	PREBLOCK,
	BLOCKIDLE,
	BLOCKEND
};

var Tracer TracersFP[17];
var Tracer TracersTP[17];
var Vector BaseballMomentum;
var SoundCue BaseballImpactSound;
var float BaseballDamage;

simulated state Attacking
{
	simulated function BeginState(Name PreviousStateName)
	{
		local HLW_Pawn_Class_Barbarian Pawn;
		
		//AttackNextIndex();
		//CalculateAttackEndTime();

		super.BeginState(PreviousStateName);
		
		Pawn = HLW_Pawn_Class_Barbarian(Owner);
		
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
			//DrawTracers(TracersFP);
			TraceAttack(TracersFP);	
		}
		else
		{
			UpdateTracers(TracersTP);
			//DrawTracers(TracersTP);
			TraceAttack(TracersTP);
		}
	}
	
	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);	
	}
}

simulated function AttackEnd()
{
	super.AttackEnd();
	
	if(bStaggerEnabled)
	{
		HLW_Pawn_Class_Barbarian(Owner).SetAnimState(UPPERMELEE, StaggerAnims[Attack.LastIndex], 0.1f);
	}
}

reliable server function ServerAttackEnd()
{
	super.ServerAttackEnd();
	
	if(bStaggerEnabled)
	{
		HLW_Pawn_Class_Barbarian(Owner).SetAnimState(UPPERMELEE, StaggerAnims[Attack.LastIndex], 0.1f);
	}
}

//Draws Tracers Position Lines
simulated function DrawTracers(Tracer AttackTracers[17])
{
	local int i;
	local Vector dmgColor;
	 	
	dmgColor = vect(255, 0, 0);
	
	for(i = 0; i < SocketTraceOrder.Length - 1; i++)
	{
		DrawDebugLine(AttackTracers[SocketTraceOrder[i]].Position, AttackTracers[SocketTraceOrder[i+1]].Position	, Byte(dmgColor.X), Byte(dmgColor.Y), Byte(dmgColor.Z), true);
	}
	
}

simulated function UpdateTracers(Tracer AttackTracers[17])
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

simulated function TraceAttack(Tracer AttackTracers[17])
{
	local Actor HitActor;
	local Vector HitLocation;
	local Vector HitNormal;
	local Vector HitMomentum;
	local int i;
	local float Damage;
	
	for(i = 0; i < SocketTraceOrder.Length - 1; i++)
	{
		foreach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, AttackTracers[SocketTraceOrder[i]].Position, AttackTracers[SocketTraceOrder[i+1]].Position)
		{
			if(HitActor != self && AddToHitActors(HitActor))
			{
					if(HitActor.IsA('HLW_Pawn') && !Pawn(Owner).IsSameTeam(HLW_Pawn(HitActor)))
					{
						HitInfo.bHitPawn = true;
						PlaySound(HitInfo.PawnImpact,,,, HitLocation);
						HLW_Pawn_Class(Owner).SpawnEmitter(HitInfo.PawnImpactParticle, HitLocation, rotator(HitNormal), true, 6.0f);
						
						Damage = AttackDamages[Attack.LastIndex];
						//Damage += int(Damage * float(Combo.Counter) * Combo.DamageModifier); //Combo Calculation
						Damage += HLW_Pawn_Class(Owner).GetPRI().PhysicalPower * AttackPhysPowerPercentages[Attack.LastIndex];
						HitMomentum = Normal(HitLocation - Owner.Location) * AttackMomentums[Attack.LastIndex];
						//HitMomentum = Normal(AttackTracers[SocketTraceOrder[i+1]].Position - AttackTracers[SocketTraceOrder[i]].Position) * AttackMomentums[Attack.LastIndex];
						
						if(Role == ROLE_Authority)
						{
							HitActor.TakeDamage(Damage, Instigator.Controller, HitLocation, HitMomentum, MyDamageType,, self);
							if(HLW_Pawn_Class_Barbarian(Owner) != None && HLW_Ability_Aura(HLW_Pawn_Class_Barbarian(Owner).GetPRI().Abilities[0]) != None)
							{
								HLW_Ability_Aura(HLW_Pawn_Class_Barbarian(Owner).GetPRI().Abilities[0]).IncreaseAura(Damage, HitActor);
							}
						}
					}
					else
					{
						Damage = AttackDamages[Attack.LastIndex];
						//Damage += int(Damage * float(Combo.Counter) * Combo.DamageModifier); //Combo Calculation
						Damage += HLW_Pawn_Class(Owner).GetPRI().PhysicalPower * AttackPhysPowerPercentages[Attack.LastIndex];
						HitMomentum = Normal(HitLocation - Owner.Location) * AttackMomentums[Attack.LastIndex];
						//HitMomentum = Normal(AttackTracers[SocketTraceOrder[i+1]].Position - AttackTracers[SocketTraceOrder[i]].Position) * AttackMomentums[Attack.LastIndex];
						HitActor.TakeDamage(Damage, Instigator.Controller, HitLocation, HitMomentum, MyDamageType,, self);
					}
			}
		}
	}
}

simulated function TraceBaseball()
{
	local Actor HitActor;
	local Vector HitLocation;
	local Vector HitNormal;
	local Vector HitMomentum;
	local int i;
	
	if(bFirstPersonTrace)
	{
		for(i = 0; i < SocketTraceOrder.Length - 1; i++)
		{
			foreach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, TracersFP[SocketTraceOrder[i]].Position, TracersFP[SocketTraceOrder[i+1]].Position)
			{
				if(HitActor != self && AddToHitActors(HitActor))
				{
						if(HitActor.IsA('HLW_Pawn') && !Pawn(Owner).IsSameTeam(HLW_Pawn(HitActor)))
						{
							if(HitActor.Physics == PHYS_Falling)
							{
								HitMomentum = BaseBallMomentum * Normal( HitLocation - ( (TracersTP[SocketTraceOrder[i+1]].Position - TracersTP[SocketTraceOrder[i]].Position) / 2.0) );
							}
							else
							{
								HitMomentum = BaseBallMomentum * Normal( HitLocation - ( (TracersTP[SocketTraceOrder[i+1]].Position - TracersTP[SocketTraceOrder[i]].Position) / 2.0) ) * 0.3;	
							}
							
							PlaySound(BaseballImpactSound,,,, HitLocation);
							HitActor.TakeDamage(BaseballDamage, Instigator.Controller, HitLocation, HitMomentum, class'HLW_DamageType_Physical',, self);
							//if(HLW_Pawn_Class_Barbarian(Owner) != None && HLW_Ability_Aura(HLW_Pawn_Class_Barbarian(Owner).GetPRI().Abilities[0]) != None)
							//{
							//	HLW_Ability_Aura(HLW_Pawn_Class_Barbarian(Owner).GetPRI().Abilities[0]).IncreaseAura(Damage); I don't know if we want Baseball To Increase Aura
							//}
						}
				}
			}
		}
	}
	else
	{
		for(i = 0; i < SocketTraceOrder.Length - 1; i++)
		{
			foreach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, TracersTP[SocketTraceOrder[i]].Position, TracersTP[SocketTraceOrder[i+1]].Position)
			{
				if(HitActor != self && AddToHitActors(HitActor))
				{
						if(HitActor.IsA('HLW_Pawn') && !Pawn(Owner).IsSameTeam(HLW_Pawn(HitActor)))
						{
							if(HitActor.Physics == PHYS_Falling)
							{
								HitActor.Velocity = vect(0, 0, 0);
								HitMomentum = BaseBallMomentum * Normal( HitLocation - ( (TracersTP[SocketTraceOrder[i]].Position - TracersTP[SocketTraceOrder[i+1]].Position) / 2.0) );
								HitMomentum.Z = BaseBallMomentum.Z;
							}
							else
							{
								HitMomentum = BaseBallMomentum * Normal( HitLocation - ( (TracersTP[SocketTraceOrder[i+1]].Position - TracersTP[SocketTraceOrder[i]].Position) / 2.0) ) * 0.6;		
							}
							
							PlaySound(BaseballImpactSound,,,, HitLocation);
							HitActor.TakeDamage(BaseballDamage, Instigator.Controller, HitLocation, HitMomentum, class'HLW_DamageType_Physical',, self);
							//if(HLW_Pawn_Class_Barbarian(Owner) != None && HLW_Ability_Aura(HLW_Pawn_Class_Barbarian(Owner).GetPRI().Abilities[0]) != None)
							//{
							//	HLW_Ability_Aura(HLW_Pawn_Class_Barbarian(Owner).GetPRI().Abilities[0]).IncreaseAura(Damage);
							//}
						}
				}
			}
		}
	}	
}

defaultproperties
{
	bBlockEnabled=false
	bChargeAttackEnabled=false
	bComboEnabled=false
	bStaggerEnabled=true
	bFirstPersonTrace=false
	bSingleAttackState=true
	bUseSocketTraceOrder=false
	
	Attack=(bActive=false, EndIndex=3, LastIndex=0, NextIndex=0, EndTime=0.00, ResetTime=3.00)
	HitInfo=(PawnImpact=SoundCue'HLW_Package_Randolph.Sounds.Barbarian_Hammer_Impact')
	Stagger=(bActive=false, bIgnoreLastAttack=true, ResetTime=3.00)
	
	AttackAnims(0)=0
	AttackAnims(1)=2
	AttackAnims(2)=4
	AttackAnims(3)=6
	
	StaggerAnims(0)=1
	StaggerAnims(1)=3
	StaggerAnims(2)=5
	
	AttackDamages(0)=32//
	AttackDamages(1)=22 //
	AttackDamages(2)=27 //
	AttackDamages(3)=27 //
	
	AttackMomentums(0)=0 //
	AttackMomentums(1)=0 //
	AttackMomentums(2)=0 //
	AttackMomentums(3)=0 //
	
	AttackPhysPowerPercentages(0)=0.2000 //
	AttackPhysPowerPercentages(1)=0.2000 //
	AttackPhysPowerPercentages(2)=0.2000 //
	AttackPhysPowerPercentages(3)=0.2000 //
	
	AttackAnimLengthsFP(0)=1.2443 //Length of  in AnimSet
	AttackAnimLengthsFP(1)=1.0784 //Length of  in AnimSet
	AttackAnimLengthsFP(2)=0.9954 //Length of  in AnimSet
	AttackAnimLengthsFP(3)=1.0354
	AttackAnimRatesFP(0)=1.0000
	AttackAnimRatesFP(1)=1.0000
	AttackAnimRatesFP(2)=1.0000
	AttackAnimRatesFP(3)=1.0000
	AttackAnimBlendInsFP(0)=0.1555375 //12.5% of  Length
	AttackAnimBlendInsFP(1)=0.1348 //12.5% of  Length
	AttackAnimBlendInsFP(2)=0.124425 //12.5% of  Length
	AttackAnimBlendInsFP(3)=0.129425
	
	AttackAnimLengthsTP(0)=1.2443 //Length of  in AnimSet
	AttackAnimLengthsTP(1)=1.0784 //Length of  in AnimSet
	AttackAnimLengthsTP(2)=0.9954 //Length of  in AnimSet
	AttackAnimLengthsTP(3)=1.0354
	AttackAnimRatesTP(0)=1.0000
	AttackAnimRatesTP(1)=1.0000
	AttackAnimRatesTP(2)=1.0000
	AttackAnimRatesTP(3)=1.0000
	AttackAnimBlendInsTP(0)=0.1555375 //12.5% of  Length
	AttackAnimBlendInsTP(1)=0.1348 //12.5% of  Length
	AttackAnimBlendInsTP(2)=0.124425 //12.5% of  Length
	AttackAnimBlendInsTP(3)=0.129425
	
	WeaponSocketFP=Barbarian_Hammer_Socket
	WeaponSocketsFP(0)=f_t_l
	WeaponSocketsFP(1)=f_t_m
	WeaponSocketsFP(2)=f_t_r
	WeaponSocketsFP(3)=f_m_l
	WeaponSocketsFP(4)=f_m_r
	WeaponSocketsFP(5)=f_b_l
	WeaponSocketsFP(6)=f_b_m
	WeaponSocketsFP(7)=f_b_r
	WeaponSocketsFP(8)=b_t_l
	WeaponSocketsFP(9)=b_t_m
	WeaponSocketsFP(10)=b_t_r
	WeaponSocketsFP(11)=b_m_l
	WeaponSocketsFP(12)=b_m_r
	WeaponSocketsFP(13)=b_b_l
	WeaponSocketsFP(14)=b_b_m
	WeaponSocketsFP(15)=b_b_r
	WeaponSocketsFP(16)=Root
	
	WeaponSocketTP=Barbarian_Hammer_Socket
	WeaponSocketsTP(0)=f_t_l
	WeaponSocketsTP(1)=f_t_m
	WeaponSocketsTP(2)=f_t_r
	WeaponSocketsTP(3)=f_m_l
	WeaponSocketsTP(4)=f_m_r
	WeaponSocketsTP(5)=f_b_l
	WeaponSocketsTP(6)=f_b_m
	WeaponSocketsTP(7)=f_b_r
	WeaponSocketsTP(8)=b_t_l
	WeaponSocketsTP(9)=b_t_m
	WeaponSocketsTP(10)=b_t_r
	WeaponSocketsTP(11)=b_m_l
	WeaponSocketsTP(12)=b_m_r
	WeaponSocketsTP(13)=b_b_l
	WeaponSocketsTP(14)=b_b_m
	WeaponSocketsTP(15)=b_b_r
	WeaponSocketsTP(16)=Root
	
	SocketTraceOrder(0)=0
	SocketTraceOrder(1)=7
	SocketTraceOrder(2)=1
	SocketTraceOrder(3)=6
	SocketTraceOrder(4)=2
	SocketTraceOrder(5)=5
	SocketTraceOrder(6)=3
	SocketTraceOrder(7)=4
	SocketTraceOrder(8)=0
	SocketTraceOrder(9)=8
	SocketTraceOrder(10)=3
	SocketTraceOrder(11)=11
	SocketTraceOrder(12)=5
	SocketTraceOrder(13)=13
	SocketTraceOrder(14)=1
	SocketTraceOrder(15)=9
	SocketTraceOrder(16)=6
	SocketTraceOrder(17)=14
	SocketTraceOrder(18)=2
	SocketTraceOrder(19)=10
	SocketTraceOrder(20)=4
	SocketTraceOrder(21)=12
	SocketTraceOrder(22)=7
	SocketTraceOrder(23)=15
	SocketTraceOrder(24)=8
	SocketTraceOrder(25)=15
	SocketTraceOrder(26)=9
	SocketTraceOrder(27)=14
	SocketTraceOrder(28)=10
	SocketTraceOrder(29)=13
	SocketTraceOrder(30)=11
	SocketTraceOrder(31)=12
	SocketTraceOrder(32)=1
	SocketTraceOrder(33)=16
	SocketTraceOrder(34)=9
	SocketTraceOrder(35)=16
	
	MyDamageType=class'HLW_DamageType_Physical'
	
	WeaponMaterialsFP(0)=Material'HLW_mapProps.Materials.HammerMat'
	WeaponMaterialsTP(0)=Material'HLW_mapProps.Materials.HammerMat'
	BaseballImpactSound=SoundCue'HLW_Package_Chris.SFX.Barbarian_Ability_Swing'
	
	Begin Object Name=SM_FP
		//bEnableSoftBodySimulation=TRUE
	    //bSoftBodyAwakeOnStartup=TRUE
     	//SoftBodyRBChannel=RBCC_SoftBody
      	//SoftBodyImpulseScale=1.0
       	//bSoftBodyUseCompartment=TRUE
		//bEnableFullAnimWeightBodies=TRUE
        //BlockActors=true
		//BlockRigidBody=true
		//CollideActors=true
		
		Rotation=(Roll=-14575, Pitch=-7296, Yaw=15181)
		Translation=(X=-23.082062, Y=2.037301, Z=-2.278708)
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Hammer'
	End Object
	WeaponFP=SM_FP
	Components.Add(SM_FP)
	
	Begin Object Name=SM_TP
		//bEnableSoftBodySimulation=TRUE
	    //bSoftBodyAwakeOnStartup=TRUE
     	//SoftBodyRBChannel=RBCC_SoftBody
      	//SoftBodyImpulseScale=1.0
       	//bSoftBodyUseCompartment=TRUE
		//bEnableFullAnimWeightBodies=TRUE
        //BlockActors=true
		//BlockRigidBody=true
		//CollideActors=true
		
		//Rotation=(Roll=401, Pitch=-2176, Yaw=-28)
		//Translation=(X=-0.307869, Y=0.991734, Z=-25.315689)
		SkeletalMesh=SkeletalMesh'HLW_Package_Randolph.models.Hammer'
	End Object
	WeaponTP=SM_TP
	Components.Add(SM_TP)
}