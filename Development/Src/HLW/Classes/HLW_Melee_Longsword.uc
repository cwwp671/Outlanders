/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Melee_Longsword extends HLW_Melee_Weapon;

var() SkeletalMeshComponent Shield;
var array<Actor> AttackHitActors;
var repnotify byte Combo;
var byte NextAttackType;
var repnotify float ComboDamageModifier;
var float ComboResetTime;
var bool bCanCombo;
var bool bCanDrawTracers;
var bool bCanTrace;
var bool bCompletedAttack;
var SkeletalMeshComponent DroppedWeaponMesh;
var SkeletalMeshComponent DroppedShieldMesh;
var SoundCue FleshImpact;
var SoundCue VoiceCombo;

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

replication 
{
    if(bNetDirty)
		Combo, ComboDamageModifier;
}

simulated event ReplicatedEvent(name VarName)
{
    if ( VarName == 'Combo')
    {
        ClientUpdateCombo(Combo);
        return;
    }
    else if ( VarName == 'ComboDamageModifier')
    {
        ClientUpdateComboDamageModifier(ComboDamageModifier);
        return;
    }
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}

reliable client function ClientUpdateCombo(byte newCombo)
{
	Combo = newCombo;
}

reliable client function ClientUpdateComboDamageModifier(float newComboDamageModifier)
{
	ComboDamageModifier = newComboDamageModifier;
}

simulated function PostBeginPlay()
{	
	bCompletedAttack = true;
	bIsAttacking = false;
	
	NextAttackType = 0;
	BlockDamageReduction = 0.5f;
	Combo = 0;
	ComboDamageModifier = 0.15f;
	ComboResetTime = 2.0f;
	
	super.PostBeginPlay();
}

simulated function DetachWeapon()
{
	DetachComponent(Mesh);
	DetachComponent(Shield);
}

simulated function Tick(float DeltaTime)
{
	if(Role < ROLE_Authority)
	{
		if(HLW_Pawn_Class_Warrior(Owner) != None)
		{
			HLW_HUD_Warrior(HLW_PlayerController(HLW_Pawn_Class_Warrior(Owner).Controller).myHUD).ComboComponentHUD.CallUpdateCombo(100 + (Combo * (ComboDamageModifier*100)));
		}
	}
	
	super.Tick(DeltaTime);	
}

/********************************************/
/********************STATES******************/
/********************************************/

simulated state WeaponEquipping
{
	simulated event BeginState(Name PreviousStateName)
	{
		local Rotator SwordRotation;
		local Vector SwordPosition;
		local MaterialInstanceConstant SwordMatInst, ShieldMatInst;
		
		SwordMatInst = new(None) Class'MaterialInstanceConstant';
		ShieldMatInst = new(None) Class'MaterialInstanceConstant';
		
		SwordMatInst.SetParent(Material'HLW_mapProps.Materials.SwordMatMaster');
		ShieldMatInst.SetParent(Material'HLW_mapProps.Materials.SheildMainMaster');
		
		if(HLW_Pawn_Class_Warrior(Owner) != None)
		{
			SwordMatInst.SetVectorParameterValue('TeamColor', HLW_Pawn_Class_Warrior(Owner).CurrentTeamColor); //TODO:Switch back to PawnClass when fixed
			ShieldMatInst.SetVectorParameterValue('TeamColor', HLW_Pawn_Class_Warrior(Owner).CurrentTeamColor); //TODO:Switch back to PawnClass when fixed
		}
			
		Mesh.SetMaterial(0, SwordMatInst);
		Shield.SetMaterial(0, ShieldMatInst);
		
		//Set Animation Times For Fire Intervals
		ChopAnimationTime = HLW_Pawn_Class_Warrior(Owner).Mesh.GetAnimLength('Warrior_Hands_Chop');
		FireInterval[0] = ChopAnimationTime - (ChopAnimationTime * 0.0625f);
	
		SwingAnimationTime = HLW_Pawn_Class_Warrior(Owner).Mesh.GetAnimLength('Warrior_Hands_Swing');
		FireInterval[1] = SwingAnimationTime - (SwingAnimationTime * 0.0625f);
	
		StabAnimationTime = HLW_Pawn_Class_Warrior(Owner).Mesh.GetAnimLength('Warrior_Hands_Stab');
		FireInterval[2] = StabAnimationTime - (StabAnimationTime * 0.0625f);
		
		////If Client
		//if(Role < ROLE_Authority)
		//{
			if (HLW_Pawn_Class_Warrior(Owner) != None)
			{
				//Combine Shadows With First Person Player
				Mesh.SetShadowParent(HLW_Pawn_Class_Warrior(Owner).Mesh);
				
				//Adjust Sword Local Rotation
				SwordRotation.Roll = 16384;
				SwordRotation.Pitch = 0;
				SwordRotation.Yaw = 16384 * 3;
				Mesh.SetRotation(SwordRotation);
				
				//Adjust Sword Local Position
				SwordPosition = Mesh.Translation;
				SwordPosition.X -= 1.0;
				Mesh.SetTranslation(SwordPosition);
				
				//Attach Skeletal Meshes To First Person Player
				HLW_Pawn_Class_Warrior(Owner).Mesh.AttachComponentToSocket(Mesh, HLW_Pawn_Class_Warrior(Owner).SwordSocket);
				HLW_Pawn_Class_Warrior(Owner).Mesh.AttachComponentToSocket(Shield, HLW_Pawn_Class_Warrior(Owner).ShieldSocket);
				HLW_Pawn_Class_Warrior(Owner).SwordWeapon = self;
				
				if(Role == ROLE_Authority)
				{
					//Initialize Chop Tracers
					ChopTracers[0] = CreateTracer(wSocketNames[0], 0, HLW_AT_CHOP, HLW_DT_LOW); //Left Blade Side
					ChopTracers[1] = CreateTracer(wSocketNames[1], 0, HLW_AT_CHOP, HLW_DT_LOW);
					ChopTracers[2] = CreateTracer(wSocketNames[2], 0, HLW_AT_CHOP, HLW_DT_HIGH);
					ChopTracers[3] = CreateTracer(wSocketNames[3], 0, HLW_AT_CHOP, HLW_DT_HIGH);
					ChopTracers[4] = CreateTracer(wSocketNames[4], 0, HLW_AT_CHOP, HLW_DT_HIGH);
					ChopTracers[5] = CreateTracer(wSocketNames[5], 0, HLW_AT_CHOP, HLW_DT_HIGH);
					ChopTracers[6] = CreateTracer(wSocketNames[6], 0, HLW_AT_CHOP, HLW_DT_MEDIUM);
					ChopTracers[7] = CreateTracer(wSocketNames[7], 0, HLW_AT_CHOP, HLW_DT_MEDIUM);
					ChopTracers[8] = CreateTracer(wSocketNames[8], 0, HLW_AT_CHOP, HLW_DT_LOW); //Right Blade Side
					ChopTracers[9] = CreateTracer(wSocketNames[9], 0, HLW_AT_CHOP, HLW_DT_LOW);
					ChopTracers[10] = CreateTracer(wSocketNames[10], 0, HLW_AT_CHOP, HLW_DT_HIGH);
					ChopTracers[11] = CreateTracer(wSocketNames[11], 0, HLW_AT_CHOP, HLW_DT_HIGH);
					ChopTracers[12] = CreateTracer(wSocketNames[12], 0, HLW_AT_CHOP, HLW_DT_HIGH);
					ChopTracers[13] = CreateTracer(wSocketNames[13], 0, HLW_AT_CHOP, HLW_DT_HIGH);
					ChopTracers[14] = CreateTracer(wSocketNames[14], 0, HLW_AT_CHOP, HLW_DT_MEDIUM);
					ChopTracers[15] = CreateTracer(wSocketNames[15], 0, HLW_AT_CHOP, HLW_DT_MEDIUM);
					ChopTracers[16] = CreateTracer(wSocketNames[16], 0, HLW_AT_CHOP, HLW_DT_LOW); //Blade Tip
					ChopTracers[17] = CreateTracer(wSocketNames[17], 0, HLW_AT_CHOP, HLW_DT_NONE); //Handle
			
					//Initialize Swing Tracers
					SwingTracers[0] = CreateTracer(wSocketNames[0], 0, HLW_AT_SWING, HLW_DT_LOW); //Left Blade Side
					SwingTracers[1] = CreateTracer(wSocketNames[1], 0, HLW_AT_SWING, HLW_DT_LOW);
					SwingTracers[2] = CreateTracer(wSocketNames[2], 0, HLW_AT_SWING, HLW_DT_LOW);
					SwingTracers[3] = CreateTracer(wSocketNames[3], 0, HLW_AT_SWING, HLW_DT_MEDIUM);
					SwingTracers[4] = CreateTracer(wSocketNames[4], 0, HLW_AT_SWING, HLW_DT_MEDIUM);
					SwingTracers[5] = CreateTracer(wSocketNames[5], 0, HLW_AT_SWING, HLW_DT_MEDIUM);
					SwingTracers[6] = CreateTracer(wSocketNames[6], 0, HLW_AT_SWING, HLW_DT_HIGH);
					SwingTracers[7] = CreateTracer(wSocketNames[7], 0, HLW_AT_SWING, HLW_DT_HIGH);
					SwingTracers[8] = CreateTracer(wSocketNames[8], 0, HLW_AT_SWING, HLW_DT_LOW); //Right Blade Side
					SwingTracers[9] = CreateTracer(wSocketNames[9], 0, HLW_AT_SWING, HLW_DT_LOW);
					SwingTracers[10] = CreateTracer(wSocketNames[10], 0, HLW_AT_SWING, HLW_DT_LOW);
					SwingTracers[11] = CreateTracer(wSocketNames[11], 0, HLW_AT_SWING, HLW_DT_MEDIUM);
					SwingTracers[12] = CreateTracer(wSocketNames[12], 0, HLW_AT_SWING, HLW_DT_MEDIUM);
					SwingTracers[13] = CreateTracer(wSocketNames[13], 0, HLW_AT_SWING, HLW_DT_MEDIUM);
					SwingTracers[14] = CreateTracer(wSocketNames[14], 0, HLW_AT_SWING, HLW_DT_HIGH);
					SwingTracers[15] = CreateTracer(wSocketNames[15], 0, HLW_AT_SWING, HLW_DT_HIGH);
					SwingTracers[16] = CreateTracer(wSocketNames[16], 0, HLW_AT_SWING, HLW_DT_HIGH); //Blade Tip
					SwingTracers[17] = CreateTracer(wSocketNames[17], 0, HLW_AT_SWING, HLW_DT_NONE); //Handle
				
					//Initialize Stab Tracers
					StabTracers[0] = CreateTracer(wSocketNames[0], 0, HLW_AT_STAB, HLW_DT_LOW); //Left Blade Side
					StabTracers[1] = CreateTracer(wSocketNames[1], 0, HLW_AT_STAB, HLW_DT_LOW);
					StabTracers[2] = CreateTracer(wSocketNames[2], 0, HLW_AT_STAB, HLW_DT_LOW);
					StabTracers[3] = CreateTracer(wSocketNames[3], 0, HLW_AT_STAB, HLW_DT_LOW);
					StabTracers[4] = CreateTracer(wSocketNames[4], 0, HLW_AT_STAB, HLW_DT_LOW);
					StabTracers[5] = CreateTracer(wSocketNames[5], 0, HLW_AT_STAB, HLW_DT_LOW);
					StabTracers[6] = CreateTracer(wSocketNames[6], 0, HLW_AT_STAB, HLW_DT_MEDIUM);
					StabTracers[7] = CreateTracer(wSocketNames[7], 0, HLW_AT_STAB, HLW_DT_MEDIUM);
					StabTracers[8] = CreateTracer(wSocketNames[8], 0, HLW_AT_STAB, HLW_DT_LOW); //Right Blade Side
					StabTracers[9] = CreateTracer(wSocketNames[9], 0, HLW_AT_STAB, HLW_DT_LOW);
					StabTracers[10] = CreateTracer(wSocketNames[10], 0, HLW_AT_STAB, HLW_DT_LOW);
					StabTracers[11] = CreateTracer(wSocketNames[11], 0, HLW_AT_STAB, HLW_DT_LOW);
					StabTracers[12] = CreateTracer(wSocketNames[12], 0, HLW_AT_STAB, HLW_DT_LOW);
					StabTracers[13] = CreateTracer(wSocketNames[13], 0, HLW_AT_STAB, HLW_DT_LOW);
					StabTracers[14] = CreateTracer(wSocketNames[14], 0, HLW_AT_STAB, HLW_DT_MEDIUM);
					StabTracers[15] = CreateTracer(wSocketNames[15], 0, HLW_AT_STAB, HLW_DT_MEDIUM);
					StabTracers[16] = CreateTracer(wSocketNames[16], 0, HLW_AT_STAB, HLW_DT_HIGH); //Blade Tip
					StabTracers[17] = CreateTracer(wSocketNames[17], 0, HLW_AT_STAB, HLW_DT_NONE); //Handle
				}
			}//End Inner If
		//}//End Outer If
		
		super.BeginState(PreviousStateName);
	}	
}

simulated function StartFire( byte FireModeNum)
{
	switch(NextAttackType)
	{
		Case 0:
			GoToState('Chopping');
			break;
		Case 1:
			GoToState('Swinging');
			break;
		Case 2:
			GoToState('Stabbing');
			break;
		Default:
			`log("You suck monkeys");
			break;
	}	
	
	if(Role < ROLE_Authority)
	{
		ServerStartFire(FireModeNum);	
	}
}

reliable server function ServerStartFire(byte FireModeNum)
{
	StartFire(FireModeNum);
}

//Chop Attack State
simulated state Chopping //extends WeaponFiring
{
	//Play Animations + Destroy Tracers Lines
	simulated event BeginState(Name PreviousStateName)
	{
		ClearTimer('ResetCombos');
		
		//If Client
		if(Role < ROLE_Authority)
		{
			FlushPersistentDebugLines();
			
			//if(HLW_Pawn_Class(Owner).UpperStateList.ActiveChildIndex != _MELEE)
			//{
				//`log("Chop Set Melee");
				HLW_Pawn_Class(Owner).SetAnimState(UPPERSTATE, _MELEE, 0.25f);
			//}
			
			//`log("Set To Chop");
			HLW_Pawn_Class_Warrior(Owner).SetAnimState(UPPERMELEE, _CHOP);
		}
		else
		{
			HLW_Pawn_Class_Warrior(Owner).WarriorChop();
			//HLW_Pawn_Class_Warrior(Owner).WarriorChopTP();	
		}
		
		SetTimer(FireInterval[0], false, 'ChopTimer');
		
		super.BeginState(PreviousStateName);
	}
	
	
	simulated function ChopTimer()
	{
		GoToState('Active');
		
		//`log("Set To Normal");
		HLW_Pawn_Class_Warrior(Owner).SetAnimState(UPPERSTATE, _NORMAL, 0.25f);
	}
	
	//Update Tracer Positions + Trace Attack + Draw Tracer Debug Lines (If Toggled)
	simulated event Tick(float DeltaTime)
	{
		if(bCanTrace)
		{
			UpdateTracers(ChopTracers);
			TraceAttack(ChopTracers, "Chop");
			
			if(bCanDrawTracers)
			{
				DrawTracers(ChopTracers, "Chop");
			}
		}
		
		super.Tick(DeltaTime);
	}
	
	//Add To Combo Count Or Reset Combo Count
	simulated event EndState(Name NextStateName)
	{
		if(Role == ROLE_Authority)
		{
			if(bCanCombo)
			{
				Combo += 1;
				bCanCombo = false;
			}
			else
			{
				Combo = 0;
			}
		}
		
		if(bCompletedAttack)
		{
			NextAttackType = 1;
		}
		else
		{
			NextAttackType = 0;
		}
		
		AttackHitActors.Remove(0, AttackHitActors.Length);
		
		if(Role == ROLE_Authority)
		{
			SetTimer(ComboResetTime, false, 'ResetCombo');
		}
		
		ClearTimer('ChopTimer');
		
		//if(HLW_Pawn_Class(Owner).UpperStateList.ActiveChildIndex != _NORMAL)
		//{
			//`log("Chop Set Normal");
			HLW_Pawn_Class(Owner).SetAnimState(UPPERSTATE, _NORMAL, 0.25f);
		//}
		
		super.EndState(NextStateName);
	}
}

//Swing Attack State
simulated state Swinging //extends WeaponFiring
{
	//Play Animations + Destroy Tracers Lines
	simulated event BeginState(Name PreviousStateName)
	{
		ClearTimer('ResetCombos');
		
		//If Client
		if(Role < ROLE_Authority)
		{
			FlushPersistentDebugLines();
			
			//if(HLW_Pawn_Class(Owner).UpperStateList.ActiveChildIndex != _MELEE)
			//{
				//`log("Swing Set Melee");
				HLW_Pawn_Class(Owner).SetAnimState(UPPERSTATE, _MELEE, 0.25f);
			//}
			
			//`log("Set To Swing");
			HLW_Pawn_Class_Warrior(Owner).SetAnimState(UPPERMELEE, _SWING);
		}
		else
		{
			HLW_Pawn_Class_Warrior(Owner).WarriorSwing();
			//HLW_Pawn_Class_Warrior(Owner).WarriorSwingTP();	
		}
		
		SetTimer(FireInterval[1], false, 'SwingTimer');
		
		super.BeginState(PreviousStateName);
	}
	
	simulated function SwingTimer()
	{
		GoToState('Active');
		
		//`log("Set To Normal");
		HLW_Pawn_Class(Owner).SetAnimState(UPPERSTATE, _NORMAL, 0.25f);
	}
	
	//Update Tracer Positions + Trace Attack + Draw Tracer Debug Lines (If Toggled)
	simulated event Tick(float DeltaTime)
	{
		if(bCanTrace)
		{
			UpdateTracers(SwingTracers);
			TraceAttack(SwingTracers, "Swing");

			if(bCanDrawTracers)
			{
				DrawTracers(SwingTracers, "Swing");
			}
		}
		
		super.Tick(DeltaTime);
	}
	
	//Add To Combo Count Or Reset Combo Count
	simulated event EndState(Name NextStateName)
	{	
		if(Role == ROLE_Authority)
		{
			if(bCanCombo)
			{
				Combo += 1;
				bCanCombo = false;
			}
			else
			{
				Combo = 0;
			}
		}
		
		if(bCompletedAttack)
		{
			NextAttackType = 2;
		}
		else
		{
			NextAttackType = 0;
		}
		
		AttackHitActors.Remove(0, AttackHitActors.Length);
		
		if(Role == ROLE_Authority)
		{
			SetTimer(ComboResetTime, false, 'ResetCombo');
		}
		
		ClearTimer('SwingTimer');
		
		//if(HLW_Pawn_Class(Owner).UpperStateList.ActiveChildIndex != _NORMAL)
		//{
			//`log("Swing Set Normal");
			HLW_Pawn_Class(Owner).SetAnimState(UPPERSTATE, _NORMAL, 0.25f);
		//}
		
		super.EndState(NextStateName);
	}
}

//Stab Attack State
simulated state Stabbing //extends WeaponFiring
{
	//Play Animations + Destroy Tracers Lines
	simulated event BeginState(Name PreviousStateName)
	{
		ClearTimer('ResetCombos');
		
		//If Client
		if(Role < ROLE_Authority)
		{
			FlushPersistentDebugLines();
			
			//if(HLW_Pawn_Class(Owner).UpperStateList.ActiveChildIndex != _MELEE)
			//{
				//`log("Stab Set Melee");
				HLW_Pawn_Class(Owner).SetAnimState(UPPERSTATE, _MELEE, 0.25f);
			//}
			
			//`log("Set To Stab");
			HLW_Pawn_Class_Warrior(Owner).SetAnimState(UPPERMELEE, _STAB);
		}
		else
		{
			HLW_Pawn_Class_Warrior(Owner).WarriorStab();
			//HLW_Pawn_Class_Warrior(Owner).WarriorStabTP();	
		}
		
		SetTimer(FireInterval[2], false, 'StabTimer');
		
		super.BeginState(PreviousStateName);
	}
	
	
	simulated function StabTimer()
	{
		GoToState('Active');

		//`log("Set To Normal");
		HLW_Pawn_Class(Owner).SetAnimState(UPPERSTATE, _NORMAL, 0.25f);
	}
	
	//Update Tracer Positions + Trace Attack + Draw Tracer Debug Lines (If Toggled)
	simulated event Tick(float DeltaTime)
	{
		if(bCanTrace)
		{
			UpdateTracers(StabTracers);
			TraceAttack(StabTracers, "Stab");
			
			if(bCanDrawTracers)
			{
				DrawTracers(StabTracers, "Stab");
			}
		}
		
		super.Tick(DeltaTime);
	}
	
	//Add To Combo Count Or Reset Combo Count
	simulated event EndState(Name NextStateName)
	{	
		if(Role == ROLE_Authority)
		{
			if(bCanCombo)
			{
				Combo += 1;
				bCanCombo = false;
			}
			else
			{
				Combo = 0;
			}
		}
		
		NextAttackType = 0;
		
		AttackHitActors.Remove(0, AttackHitActors.Length);

		if(Role == ROLE_Authority)
		{
			SetTimer(ComboResetTime, false, 'ResetCombo');
		}
		
		ClearTimer('StabTimer');
		
		//if(HLW_Pawn_Class(Owner).UpperStateList.ActiveChildIndex != _NORMAL)
		//{
			//`log("Set To Normal");
			HLW_Pawn_Class(Owner).SetAnimState(UPPERSTATE, _NORMAL, 0.25f);
		//}
		
		super.EndState(NextStateName);
	}
}

/********************************************/
/********************************************/
/********************************************/

simulated function ResetCombo()
{
	if(Role == ROLE_Authority)
	{
		bCanCombo = false;
		NextAttackType = 0;
		Combo = 0;
	}
	
	if(Role < ROLE_Authority)
	{
		//if(HLW_Pawn_Class(Owner).UpperStateList.ActiveChildIndex != _NORMAL)
		//{
			//`log("Set To Normal");
			HLW_Pawn_Class(Owner).SetAnimState(UPPERSTATE, _NORMAL, 0.25f);
		//}
	}
}

//Updates Tracers Positions
simulated function UpdateTracers(out Tracer Tracers[18])
{
	local int index;
	
	for(index = 0; index < ArrayCount(Tracers); index++)
	{
		Tracers[index].Position = GetSocketLocation(wSocketNames[index]);
		
		//if(Role == ROLE_Authority)
		//{
			//`log("Server Tracer["$index$"]"@"Position:"@Tracers[index].Position);
		//}
		//else
		//{
			//`log("Client Tracer["$index$"]"@"Position:"@Tracers[index].Position);
		//}
	}
}

//Traces Attacks (Reliable Causes Rubberbanding)
unreliable server function TraceAttack(Tracer Tracers[18], string AttackType)
{
	local Actor HitActor;
	local Vector HitLoc, HitNorm, Momentum;
	local int index;
	local int DamageAmount;
	//local HLW_StatusEffect_Bleed BleedEffect;
	
	//Socket Indexes
	//(Bottom)0-7(Top) - Left
	//(Bottom)8-15(Top) - Right
	//16 - Tip
	//17 - Handle
	
	//`log("Tracing Attack");
	
	foreach TraceActors(class'Actor', HitActor, HitLoc, HitNorm, Tracers[16].Position, Tracers[7].Position)
	{
		if(HitActor != self && AddToAttackHitActors(HitActor))
   		{
   			switch(AttackType)
   			{
   				Case "Chop":
   					DamageAmount = InstantHitDamage[0]; //Calculate damage based on part of sword that hit
   					break;
   				Case "Swing":
   					DamageAmount = InstantHitDamage[1]; //Calculate damage based on part of sword that hit
   					break;
   				Case "Stab":
   					DamageAmount = InstantHitDamage[2]; //Calculate damage based on part of sword that hit
   					break;	
   				Default:
   					break;
   			}
   			
			if(!HitActor.IsA('HLW_Pawn'))
			{
				Momentum = Normal(Tracers[16].Position - Tracers[7].Position) * InstantHitMomentum[CurrentFireMode]; //Momentum transfer calculations
				PlaySound(ImpactSound,,,, HitLoc);
			}
			else
			{
				if (HLW_Pawn(HitActor) != None)
				{
					//BleedEffect = Spawn(class'HLW_StatusEffect_Bleed');
					bCanCombo = true;
					//HLW_Pawn(HitActor).ApplyStatusEffect(BleedEffect, Instigator.Controller, self);
					//HLW_Pawn_Class(Owner).SpawnEmitter(ParticleSystem'HLW_AndrewParticles.Particles.FX_BleedEffects', HitLoc, rotator(HitNorm),,6.0f);
				}
				
				PlaySound(FleshImpact,,,, HitLoc);
				
				if(Combo != 0)
				{
					PlaySound(VoiceCombo,,,, Owner.Location);
				}
				
				Momentum = vect(0, 0, 0);
			}
			
			
			DamageAmount += int(float(DamageAmount) * float(Combo) * ComboDamageModifier);
			DamageAmount += HLW_Pawn_Class(Owner).GetPRI().PhysicalPower * PhysPowerPercentage;
			
			HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, MyDamageType); //Cause hit actor to react accordingly

			
			
				
			//`log("Hit:"@DamageAmount);
   		}
	}
	
	foreach TraceActors(class'Actor', HitActor, HitLoc, HitNorm, Tracers[16].Position, Tracers[15].Position)
	{
		if(HitActor != self && AddToAttackHitActors(HitActor))
   		{
   			switch(AttackType)
   			{
   				Case "Chop":
   					DamageAmount = InstantHitDamage[0]; //Calculate damage based on part of sword that hit
   					break;
   				Case "Swing":
   					DamageAmount = InstantHitDamage[1]; //Calculate damage based on part of sword that hit
   					break;
   				Case "Stab":
   					DamageAmount = InstantHitDamage[2]; //Calculate damage based on part of sword that hit
   					break;	
   				Default:
   					break;
   			}

   			if(!HitActor.IsA('HLW_Pawn'))
			{
				Momentum = Normal(Tracers[16].Position - Tracers[7].Position) * InstantHitMomentum[CurrentFireMode]; //Momentum transfer calculations
				PlaySound(ImpactSound,,,, HitLoc);
			}
			else
			{
				if (HLW_Pawn(HitActor) != None)
				{
					//BleedEffect = Spawn(class'HLW_StatusEffect_Bleed');
					bCanCombo = true;
					//HLW_Pawn(HitActor).ApplyStatusEffect(BleedEffect, Instigator.Controller, self);
					//HLW_Pawn_Class(Owner).SpawnEmitter(ParticleSystem'HLW_AndrewParticles.Particles.FX_BleedEffects', HitLoc, rotator(HitNorm),,6.0f);
				}
				
				PlaySound(FleshImpact,,,, HitLoc);
				
				if(Combo != 0)
				{
					PlaySound(VoiceCombo,,,, Owner.Location);
				}
				
				Momentum = vect(0, 0, 0);
			}
			
			DamageAmount += int(float(DamageAmount) * float(Combo) * ComboDamageModifier);
			DamageAmount += HLW_Pawn_Class(Owner).GetPRI().PhysicalPower * PhysPowerPercentage;

			HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, MyDamageType); //Cause hit actor to react accordingly
			
			//`log("Hit:"@DamageAmount);
   		}
	}
	
	for(index = 7; index > 0; index--)
	{
		foreach TraceActors(class'Actor', HitActor, HitLoc, HitNorm, Tracers[index].Position, Tracers[index-1].Position)
		{
			if(HitActor != self && AddToAttackHitActors(HitActor))
   			{
   				switch(AttackType)
   				{
   					Case "Chop":
   						DamageAmount = InstantHitDamage[0]; //Calculate damage based on part of sword that hit
   						break;
   					Case "Swing":
   						DamageAmount = InstantHitDamage[1]; //Calculate damage based on part of sword that hit
   						break;
   					Case "Stab":
   						DamageAmount = InstantHitDamage[2]; //Calculate damage based on part of sword that hit
   						break;	
   					Default:
   						break;
   				}
   				
   				if(!HitActor.IsA('HLW_Pawn'))
				{
					Momentum = Normal(Tracers[16].Position - Tracers[7].Position) * InstantHitMomentum[CurrentFireMode]; //Momentum transfer calculations
					PlaySound(ImpactSound,,,, HitLoc);
				}
				else
				{
					if (HLW_Pawn(HitActor) != None)
					{
						//BleedEffect = Spawn(class'HLW_StatusEffect_Bleed');
						bCanCombo = true;
						//HLW_Pawn(HitActor).ApplyStatusEffect(BleedEffect, Instigator.Controller, self);
						//HLW_Pawn_Class(Owner).SpawnEmitter(ParticleSystem'HLW_AndrewParticles.Particles.FX_BleedEffects', HitLoc, rotator(HitNorm),,6.0f);
					}
				
					PlaySound(FleshImpact,,,, HitLoc);
					
					if(Combo != 0)
					{
						PlaySound(VoiceCombo,,,, Owner.Location);
					}
					
					Momentum = vect(0, 0, 0);
				}
				
				DamageAmount += int(float(DamageAmount) * float(Combo) * ComboDamageModifier);
				DamageAmount += HLW_Pawn_Class(Owner).GetPRI().PhysicalPower * PhysPowerPercentage;

				HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, MyDamageType); //Cause hit actor to react accordingly
				
				//`log("Hit:"@DamageAmount);	
   			}
		}
	}
	
	for(index = 15; index > 8; index--)
	{
		foreach TraceActors(class'Actor', HitActor, HitLoc, HitNorm, Tracers[index].Position, Tracers[index-1].Position)
		{
			if(HitActor != self && AddToAttackHitActors(HitActor))
   			{
   				switch(AttackType)
   				{
   					Case "Chop":
   						DamageAmount = InstantHitDamage[0]; //Calculate damage based on part of sword that hit
   						break;
   					Case "Swing":
   						DamageAmount = InstantHitDamage[1]; //Calculate damage based on part of sword that hit
   						break;
   					Case "Stab":
   						DamageAmount = InstantHitDamage[2]; //Calculate damage based on part of sword that hit
   						break;	
   					Default:
   						break;
   				}
   				
   				if(!HitActor.IsA('HLW_Pawn'))
				{
					Momentum = Normal(Tracers[16].Position - Tracers[7].Position) * InstantHitMomentum[CurrentFireMode]; //Momentum transfer calculations
					PlaySound(ImpactSound,,,, HitLoc);
				}
				else
				{
					if (HLW_Pawn(HitActor) != None)
					{
						//BleedEffect = Spawn(class'HLW_StatusEffect_Bleed');
						bCanCombo = true;
						//HLW_Pawn(HitActor).ApplyStatusEffect(BleedEffect, Instigator.Controller, self);
						//HLW_Pawn_Class(Owner).SpawnEmitter(ParticleSystem'HLW_AndrewParticles.Particles.FX_BleedEffects', HitLoc, rotator(HitNorm),,6.0f);
					}
				
					PlaySound(FleshImpact,,,, HitLoc);
					
					if(Combo != 0)
					{
						PlaySound(VoiceCombo,,,, Owner.Location);
					}
					
					Momentum = vect(0, 0, 0);
				}
			
				DamageAmount += int(float(DamageAmount) * float(Combo) * ComboDamageModifier);
				DamageAmount += HLW_Pawn_Class(Owner).GetPRI().PhysicalPower * PhysPowerPercentage;

				HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, MyDamageType); //Cause hit actor to react accordingly
				
				//`log("Hit:"@DamageAmount);
   			}
		}
	}
}

//Draws Tracers Position Lines
simulated function DrawTracers(Tracer Tracers[18], string AttackType)
{
	local int index;
	local Vector dmgColor;
	
	//Socket Indexes
	//(Bottom)0-7(Top) - Left
	//(Bottom)8-15(Top) - Right
	//16 - Tip
	//17 - Handle
	
	switch(AttackType)
   	{
   		Case "Chop":
   			dmgColor = vect(255, 0, 0); //Calculate damage based on part of sword that hit
   			break;
   		Case "Swing":
   			dmgColor = vect(0, 255, 0); //Calculate damage based on part of sword that hit
   			break;
   		Case "Stab":
   			dmgColor = vect(0, 0, 255); //Calculate damage based on part of sword that hit
   			break;	
   		Default:
   			dmgColor = vect(0, 0, 0);
   			break;
   	}
	
	DrawDebugLine(Tracers[16].Position, Tracers[7].Position, Byte(dmgColor.X), Byte(dmgColor.Y), Byte(dmgColor.Z), true);
	
	for(index = 7; index > 0; index--)
	{
		DrawDebugLine(Tracers[index].Position, Tracers[index - 1].Position, Byte(dmgColor.X), Byte(dmgColor.Y), Byte(dmgColor.Z), true);
	}
	
	DrawDebugLine(Tracers[16].Position, Tracers[15].Position, Byte(dmgColor.X), Byte(dmgColor.Y), Byte(dmgColor.Z), true);
	
	for(index = 15; index > 8; index--)
	{
		DrawDebugLine(Tracers[index].Position, Tracers[index - 1].Position, Byte(dmgColor.X), Byte(dmgColor.Y), Byte(dmgColor.Z), true);
	}	
	
	for(index = 7; index > 0; index--)
	{
		DrawDebugLine(Tracers[index].Position, Tracers[index + 8].Position, Byte(dmgColor.X), Byte(dmgColor.Y), Byte(dmgColor.Z), true);
	}
}

//Adds Hit Actor To Array (Prevents Hitting An Actor More Than Once Per Attack)
simulated function bool AddToAttackHitActors(Actor HitActor)
{
   local int index;

   for (index = 0; index < AttackHitActors.Length; index++)
   {
      if (AttackHitActors[index] == HitActor)
      {
         return false;
      }
   }

   AttackHitActors.AddItem(HitActor);
   return true;
}

simulated function FireAmmunition()
{
	StopFire(CurrentFireMode);
	AttackHitActors.Remove(0, AttackHitActors.Length);
	
	super.FireAmmunition();
}

simulated function DropWeapons(vector StartLocation, rotator StartRotation)
{
	local HLW_RB_Item RB_Sword, RB_Shield;
	
	RB_Sword = Spawn(class'HLW_RB_Item',,, StartLocation, StartRotation);
    //if (RBItem == None)
    //{
        //Destroy();
        //return;
    //}

    RB_Sword.SetItem(self, DroppedWeaponMesh, StartLocation, StartRotation);

	RB_Shield = Spawn(class'HLW_RB_Item',,, StartLocation, StartRotation);
	RB_Shield.SetItem(self, DroppedShieldMesh, StartLocation, StartRotation);
}
//simulated function Tick(float DeltaTime)
//{
	//
//}
/********************************************/
/**********ANIMATION NOTIFY SCRIPTS**********/
/********************************************/

//Decide Whether I Am Attacking (Called At Attack Animation Start + End)
simulated function EnableAttackStatus()
{
	bIsAttacking = true;
}

simulated function DisableAttackStatus()
{
	bIsAttacking = false;
}

simulated function EnableCompletedAttackStatus()
{
	bCompletedAttack = true;	
}

simulated function DisableCompletedAttackStatus()
{
	bCompletedAttack = false;	
}

//Decide Whether I Can Trace Attack (Called At Specific Point In Animation + End)
simulated function EnableTraceStatus()
{
	bCanTrace = true;	
}

simulated function DisableTraceStatus()
{
	bCanTrace = false;	
}

/********************************************/
/********************************************/
/********************************************/

/********************************************/
/***************EXEC FUNCTIONS***************/
/********************************************/

//Toggles Tracer Debug Line Drawing
simulated exec function EnableTracers()
{
	bCanDrawTracers = !bCanDrawTracers;	
}

/********************************************/
/********************************************/
/********************************************/

defaultproperties
{
	MyDamageType=class'HLW_DamageType_Physical'
	PhysPowerPercentage=0.1

	FiringStatesArray(0)="Chopping" //Chop
	FiringStatesArray(1)="Swinging" //Swing
	FiringStatesArray(2)="Stabbing" //Stab
	
	WeaponFireTypes(0)=EWFT_Custom //Chop
	WeaponFireTypes(1)=EWFT_Custom //Swing
	WeaponFireTypes(2)=EWFT_Custom //Stab
	
	FireInterval[0]=0.01 //Chop
	FireInterval[1]=0.01 //Swing
	FireInterval[2]=0.01 //Stab
	
	InstantHitMomentum[0]=10000 //Chop
	InstantHitMomentum[1]=10000 //Swing
	InstantHitMomentum[2]=10000 //Stab
	
	InstantHitDamage[0]=10 //Chop
	InstantHitDamage[1]=10 //Swing
	InstantHitDamage[2]=10 //Stab
	
	//Sword Tracer Sockets
	wSocketNames[0]=blade_left_1_socket //Bottom Left Blade
	wSocketNames[1]=blade_left_2_socket
	wSocketNames[2]=blade_left_3_socket
	wSocketNames[3]=blade_left_4_socket
	wSocketNames[4]=blade_left_5_socket
	wSocketNames[5]=blade_left_6_socket
	wSocketNames[6]=blade_left_7_socket
	wSocketNames[7]=blade_left_8_socket //Top Left Blade (Not Tip)
	wSocketNames[8]=blade_right_1_socket//Bottom Right Blade
	wSocketNames[9]=blade_right_2_socket
	wSocketNames[10]=blade_right_3_socket
	wSocketNames[11]=blade_right_4_socket
	wSocketNames[12]=blade_right_5_socket
	wSocketNames[13]=blade_right_6_socket
	wSocketNames[14]=blade_right_7_socket
	wSocketNames[15]=blade_right_8_socket//Top Right Blade (Not Tip)
	wSocketNames[16]=blade_tip_socket//Blade Tip
	wSocketNames[17]=handle_socket//Handle
	
	AttachmentClass=class'HLW_Longsword_Attachment'
	ImpactSound=SoundCue'HLW_Package_Randolph.Sounds.Longsword_Impact_SoundCue'
	FleshImpact=SoundCue'HLW_Package_Randolph.Sounds.FleshImpact_Sound'
	VoiceCombo=SoundCue'HLW_Package_Randolph.Sounds.Warrior_Combo'
	
	//First Person Sword Skeletal Mesh
	Begin Object Class=SkeletalMeshComponent Name=Longsword_SM
		bAcceptsDynamicDecals=TRUE //Future Blood Decals?
		AlwaysLoadOnClient=TRUE //IDK
		AlwaysLoadOnServer=TRUE //IDK
		bCacheAnimSequenceNodes=FALSE //IDK
		bCastDynamicShadow=TRUE //Dynamic Shadow
		CastShadow=TRUE //Shadow
		bChartDistanceFactor=TRUE //IDK
		bIgnoreControllersWhenNotRendered=FALSE //IDK
		bOnlyOwnerSee=TRUE //Only Visible To Player
		bOverrideAttachmentOwnerVisibility=TRUE //Anything Attached Gets My Visibility Setting
		bPerBoneMotionBlur=TRUE //IDK
		bUseOnePassLightingOnTranslucency=TRUE //IDK
		bUpdateKinematicBonesFromAnimation=TRUE //IDK
		bUpdateSkelWhenNotRendered=TRUE //Needed For Accurate Tracer Positions When Invisible
		RBChannel=RBCC_Untitled3 //IDK
		RBCollideWithChannels=(Untitled3=TRUE) //IDK
		RBDominanceGroup=20 //IDK
		MinDistFactorForKinematicUpdate=0.2f //IDK
		TickGroup=TG_PreAsyncWork //Ticks Before Asynchronous Updates (Physics + Others Things)
		SkeletalMesh=SkeletalMesh'HLW_Package.Models.Longsword'
	End Object
	Mesh=Longsword_SM
	Components.Add(Longsword_SM)
	
	//First Person Shield Skeletal Mesh
	Begin Object Class=SkeletalMeshComponent Name=Shield_SM
		BlockRigidBody=FALSE //No Collision Please
		BlockZeroExtent=FALSE //No Collision Please
		bCastDynamicShadow=FALSE //Dynamic Shadow
		CastShadow = FALSE //Shadow
		CollideActors=FALSE //No Collision Please
		bOnlyOwnerSee=TRUE //Only Visible To Player 
		SkeletalMesh=SkeletalMesh'HLW_Package.Models.Warrior_Shield'
	End Object
	Shield=Shield_SM
	Components.Add(Shield_SM)
	
	//Dropped Weapon SkeletalMesh
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
		Scale=2
		SkeletalMesh=SkeletalMesh'HLW_CONNOR_PAKAGE.Physics.Longsword_Deco_Skele'
		PhysicsAsset=PhysicsAsset'HLW_CONNOR_PAKAGE.Physics.Longsword_Deco_Skele_Physics'
	End Object
	DroppedWeaponMesh=WeaponSkeletalMesh
	//DroppedWeaponClass=HLW_M_Longsword_DroppedPickup
	
	//Dropped Shield SkeletalMesh
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
		Scale=2
		SkeletalMesh=SkeletalMesh'HLW_CONNOR_PAKAGE.Physics.Warrior_Shield_Skele'
		PhysicsAsset=PhysicsAsset'HLW_CONNOR_PAKAGE.Physics.Warrior_Shield_Skele_Physics'
	End Object
	DroppedShieldMesh=ShieldSkeletalMesh
	//DroppedShieldClass=HLW_M_Longsword_DroppedPickup
}