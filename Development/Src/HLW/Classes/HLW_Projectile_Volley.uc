class HLW_Projectile_Volley extends HLW_Projectile;

var SoundCue ImpactCue;
var SoundCue FleshImpact;

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if(Owner != None)
	{
		if(Owner.Owner != None)
		{	
			if(Other != HLW_PlayerController(Owner.Owner).Pawn)
			{
				PlaySound(FleshImpact,,,, HitLocation);
				super.ProcessTouch(Other, HitLocation, HitNormal);	
			}
		}
	}
}

simulated function HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	if(Owner != None && Owner.Owner != None)
	{
		PlaySound(ImpactCue,,,, self.Location);
	}
	
	bRotationFollowsVelocity=false;
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
}

defaultproperties
{
	LifeSpan=+0002.000000
	ImpactCue=SoundCue'HLW_Package_Randolph.Sounds.ArrowImpact_Sound'
	FleshImpact=SoundCue'HLW_Package_Randolph.Sounds.FleshImpact_Sound'
	
	Begin Object Class=StaticMeshComponent Name=BaseMesh
        StaticMesh=StaticMesh'HLW_Package_Randolph.models.Dat_Arrow'
		Scale=0.4
        Rotation=(Yaw=32768,Roll=0,Pitch=0)
    End object
    Components.Add(BaseMesh)
    
    Begin Object Class=ParticleSystemComponent Name=Trail
    	Template=ParticleSystem'HLW_AndrewParticles.Particles.FX_ArrowRibbon'
    End Object
    Components.Add(Trail)
}