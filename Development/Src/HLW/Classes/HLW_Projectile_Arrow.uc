class HLW_Projectile_Arrow extends HLW_Projectile;

var ParticleSystemComponent	TrailEffects;
var() ParticleSystem TrailParticle;

var StaticMeshComponent MeshComp;
var SoundCue ImpactCue;
var SoundCue FleshImpact;
var array<Actor> ActorsHit; 
var repnotify int hitCount; 
var float upAmount;
var bool hit;

replication
{
	if (bNetDirty)
		hitCount;
}

simulated event ReplicatedEvent(name VarName)
{
    if ( VarName == 'hitCount')
    {
        ClientSetHitCount(hitCount);
        return;
    }
}

simulated function ClientSetHitCount(int HitCountIN)
{
	hitCount = HitCountIN;	
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();	
	Acceleration.Z = WorldInfo.WorldGravityZ;
	//TrailEffects = new class'ParticleSystemComponent';
	//TrailEffects.SetTemplate(TrailParticle);
	//TrailEffects.SetAbsolute(false, false, false);
	//AttachComponent(TrailEffects);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local Name BoneHit;
	
    if ( !hit && Other != Instigator && !hasntAlreadyHit(Other))
    {
    	ActorsHit.AddItem(Other);
    	if(InstigatorController != None)
    	{
    		if(HLW_Pawn_Class_Archer(InstigatorController.Pawn) != None) //HEADSHOT CODE
    		{
    			Damage = HLW_Ability_HeadShot(HLW_PlayerController(InstigatorController).GetAbility(0)).GetArrowDamage(Damage, Other, HitLocation, HitNormal);
			}
        }
        
		Other.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
        hitCount--;
        
        PlaySound(FleshImpact,,,, HitLocation);
        
		if(hitCount == 0)
		{
			if(HLW_Pawn_Class(Other) != None)
			{
				BoneHit = HLW_Pawn_Class(Other).ThirdPerson.FindClosestBone(HitLocation);
				//MeshComp.SetScale(2);
				DetachComponent(MeshComp);
				HLW_Pawn_Class(Other).ThirdPerson.AttachComponent(MeshComp, BoneHit,,Rotator(HitNormal));
			}
        	//Explode(HitLocation, HitNormal); 
        	TrailEffects.DeactivateSystem();
			Damage = 0;
			DamageRadius = 0;
			SetTimer(10, false, 'Destroy');
		}
    }
}

simulated function bool hasntAlreadyHit(Actor Other)
{
	local int i;
	for(i = 0; i < ActorsHit.Length; i++)
	{
		if(ActorsHit[i] == Other)
			return true; 
	}
	
	return false; 
}

simulated event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	PlaySound(ImpactCue,,,, self.Location);
	bRotationFollowsVelocity=false;
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	hit = true;
	Damage = 0;
}
defaultproperties
{
	ImpactCue=SoundCue'HLW_Package_Randolph.Sounds.ArrowImpact_Sound'
	FleshImpact=SoundCue'HLW_Package_Randolph.Sounds.FleshImpact_Sound'
	
	MyDamageType=class'HLW_DamageType_Physical' //Damage Type (Gets Rid Of Warnings + Needed For Future Damage Resistances)
	
	begin object class=StaticMeshComponent Name=BaseMesh
        StaticMesh=StaticMesh'HLW_Package_Randolph.models.Dat_Arrow'
		Scale=0.4
        Rotation=(Yaw=32768,Roll=0,Pitch=0)
    end object
	MeshComp=BaseMesh
    Components.Add(BaseMesh)
    
    Begin Object Class=ParticleSystemComponent Name=Trail
    	Template=ParticleSystem'HLW_Package_Randolph.Farticles.Particle_Arrow_Trail'//ParticleSystem'HLW_AndrewParticles.Particles.FX_ArrowRibbon'
    End Object
    TrailEffects=Trail
    Components.Add(Trail)
    
    TrailParticle=ParticleSystem'GDC_Materials.Effects.P_SwordTrail_01'
    
    hitCount = 1; 
    Speed=50//Speed=1500
    Damage=0
	bRotationFollowsVelocity=true
    hit=false
    upAmount=-0.75f
    MomentumTransfer=10
    MaxSpeed=0
}