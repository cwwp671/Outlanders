/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Archer_BearTrap extends HLW_Archer_Trap;

var HLW_StatusEffect_BearTrap RootStatus;
var SoundCue TrapSound;
var float StunDuration;

reliable server function TrapEffect()
{
	local Actor HitActor;
	
	foreach VisibleCollidingActors(class'Actor', HitActor, EffectRadius, Location)
	{
		if(HitActor != HLW_PlayerController(Owner).Pawn)
		{
			if(HLW_Pawn(HitActor) != None)
			{
				RootStatus = Spawn(class'HLW_StatusEffect_BearTrap');
				RootStatus.Duration = StunDuration;
				HLW_Pawn(HitActor).ApplyStatusEffect(RootStatus, HLW_PlayerController(Owner));
				HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).SpawnEmitter(TrapParticle, Location, Rotation,, 2.0f);
				PlaySound(TrapSound,,,, Location);
				Destroy();
			}
		}
	}	
	
}

reliable server function bool CheckForActivation()
{
	local Actor HitActor;
	
	foreach VisibleCollidingActors(class'Actor', HitActor, ActivationRadius, Location)
	{
		if(HitActor != HLW_PlayerController(Owner).Pawn)
		{
			if(HLW_Pawn(HitActor) != None)
			{
				Activated = true;
				
				HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).VoiceOver = ActivationSound;
				HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).PlayVoiceOver(HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).VoiceOver);
				//PlaySound(ActivationSound,,,, HLW_Pawn_Class(HLW_PlayerController(Owner).Pawn).Location);
				TrapEffect();
				
				return true;
			}
		}
	}	
	
	return false;	
}

defaultproperties
{
	ActivationSound=SoundCue'HLW_Package_Voices.Archer.Ability_BearTrap'
	TrapParticle=ParticleSystem'HLW_Package_Randolph.Farticles.BearTrapEffect'
	TrapSound=SoundCue'HLW_Package_Chris.SFX.Archer_Ability_TrapBear_Snap'
	
	StunDuration=2.0
	ActivationRadius=50
	EffectRadius=150
}