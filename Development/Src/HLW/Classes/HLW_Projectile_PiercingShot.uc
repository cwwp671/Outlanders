class HLW_Projectile_PiercingShot extends HLW_Projectile;

var array<Actor> ActorsHit;
var bool bHitWall;

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if (Other != Instigator && AddToActorsHit(Other))
	{
		if(!bHitWall)
		{
			`log("Damage"@Damage);
			Other.TakeDamage(Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		}
	}
}

simulated event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	bRotationFollowsVelocity=false;
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	Damage = 0;
	bHitWall = true;
}

//Adds Hit Actor To Array (Prevents Hitting An Actor More Than Once Per Attack)
simulated function bool AddToActorsHit(Actor HitActor)
{
   local int index;

   for (index = 0; index < ActorsHit.Length; index++)
   {
      if (ActorsHit[index] == HitActor)
      {
         return false;
      }
   }

   ActorsHit.AddItem(HitActor);
   return true;
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=ArrowMesh
        StaticMesh=StaticMesh'HLW_Package_Randolph.models.Archer_Arrow'
		//Scale=0.4
		Scale3D=(X=0.8,Y=0.8,Z=0.8)
        Rotation=(Yaw=32768,Roll=0,Pitch=0)
    End Object
    Components.Add(ArrowMesh)
	
	MyDamageType=class'HLW_DamageType_Physical'
	Speed=3000
	MomentumTransfer=50000
	bHitWall=false
}