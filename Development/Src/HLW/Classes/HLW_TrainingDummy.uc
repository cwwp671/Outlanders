class HLW_TrainingDummy extends HLW_Pawn_Creep
ClassGroup(HeroLineWars)
placeable;

var(Voice) SoundCue VoiceCueDied;
var(Voice) SoundCue VoiceCueHurt;
var(Voice) AudioComponent VoiceComponent;
var(Voice) repnotify SoundCue VoiceOver;

var bool bCanHurtSound;

replication 
{
    if(bNetDirty)
        VoiceOver;
}

simulated function ReplicatedEvent(name VarName)
{
	if(VarName == 'VoiceOver')
	{
		PlayVoiceOver(VoiceOver);
		return;
	}	
}

simulated function PostBeginPlay()
{
	newFactory = HLW_Creep_Camp_Factory(Owner);
	Factory = HLW_Factory_Creep(Owner);
	SpawnDefaultController();
	
	startLocation = Location;
}

simulated function TakeDamage (int Damage, Controller EventInstigator, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{	
	if(bCanHurtSound)
	{
		VoiceOver = VoiceCueHurt;
		PlayVoiceOver(VoiceOver);
		bCanHurtSound = false;
		SetTimer(2.0f, false, 'ResetHurtVO');
	}
	
	super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

simulated function PlayDyingSound()
{
	super.PlayDyingSound();
	
	VoiceOver = VoiceCueDied;
	PlayVoiceOver(VoiceOver);
}

unreliable server function ResetHurtVO()
{
	bCanHurtSound = true;	
}

simulated function PlayVoiceOver(SoundCue NewSound)
{
	VoiceOver = NewSound;
	VoiceComponent.Stop();
	VoiceComponent.SoundCue = VoiceOver;
	
	if(NewSound != None)
	{
		VoiceComponent.Play();
		SetTimer(VoiceComponent.SoundCue.Duration, false, 'ResetVoiceOver');
	}	
}

simulated function ResetVoiceOver()
{
	VoiceOver=None;
	PlayVoiceOver(VoiceOver);	
}

defaultproperties
{
	GroundSpeed=350
	
	bCanHurtSound=true
	
	Begin Object Class=SkeletalMeshComponent Name=DummyMesh
        CastShadow=true
        bCastDynamicShadow=true
        bOwnerNoSee=false
        BlockRigidBody=true
        CollideActors=true
        BlockZeroExtent=true
        bHasPhysicsAssetInstance=true
    End Object
    Mesh=DummyMesh
    Components.Add(DummyMesh)

	Begin Object Name=CollisionCylinder
		CollisionHeight=+0060.000000
		CollisionRadius=+0020.000000
	End Object
	
	Begin Object Class=AudioComponent Name=VoiceComponentObject
		bUseOwnerLocation=true
	End Object
	VoiceComponent=VoiceComponentObject
	Components.Add(VoiceComponentObject)
}