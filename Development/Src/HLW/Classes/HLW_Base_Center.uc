class HLW_Base_Center extends HLW_Base_Structure
	ClassGroup(HeroLineWars)
	placeable;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

function bool Died(Controller Killer, class<DamageType> DamageType, Vector HitLocation)
{
	WorldInfo.Game.Killed(Killer, Controller, self, DamageType);

	return super.Died(Killer, DamageType, HitLocation);
}

event Bump(Actor Other, PrimitiveComponent OtherComponent, Vector HitNormal)
{
	if(HLW_Pawn_Creep(Other) != none)
    {
        TakeDamage(HLW_Pawn_Creep(Other).BumpDamage, none, Location, vect(0,0,0), class'UTDmgType_LinkPlasma');
    }
    else
    {
        super.Bump(Other, OtherComponent, HitNormal);    
    }
}

simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(EventInstigator.PlayerReplicationInfo.Team.TeamIndex == self.TeamIndex)
	{
		return;
	}
	else
	{
		super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
		if(Health <= 0)
		{
			Died(EventInstigator, DamageType, HitLocation);
		}
	}
}

defaultproperties
{
	Health=100
	isGoal=true
	
	bBlockActors=false
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
            ModShadowFadeoutTime=0.25
            MinTimeBetweenFullUpdates=0.2
            AmbientGlow=(R=.01,G=.01,B=.01,A=1)
            AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
            bSynthesizeSHLight=TRUE
    End Object
    Components.Add(MyLightEnvironment)
	        //LightEnvironment=MyLightEnvironment
	
	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
        CastShadow=true
        bCastDynamicShadow=true
        bOwnerNoSee=false
        LightEnvironment=MyLightEnvironment
        BlockRigidBody=true
        CollideActors=true
        BlockZeroExtent=true
        SkeletalMesh=SkeletalMesh'HLW_Phil.Base.Crystal_Boned'
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
    End Object
    Mesh=InitialSkeletalMesh
    Components.Add(InitialSkeletalMesh)
}