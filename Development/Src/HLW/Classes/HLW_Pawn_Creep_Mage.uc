class HLW_Pawn_Creep_Mage extends HLW_Pawn_Creep
	ClassGroup(HeroLineWars)
	placeable;

var bool hasteCooldown;
var float hasteRange;
var float hasteCD;
var HLW_Pawn_Creep hasteTarget;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	CylinderComponent.SetCylinderSize(35.0 * Mesh.Scale3D.X, 40.0 * Mesh.Scale3D.Y);
}

function FindHasteTarget()
{
	local HLW_AIController AIC;
	
	hasteTarget = none;
	
    foreach DynamicActors(class'HLW_AIController', AIC)
    {
        if(AIC.Pawn != none && AIC.IsInState('Attacking'))
        {
        	if(VSize(Location - AIC.Pawn.Location) < hasteRange)
        	{
				hasteTarget = HLW_Pawn_Creep(AIC.Pawn);
            }
        }
    }
	
	if(hasteTarget != none)
	{
		if(!hasteTarget.isHasted)
		{
			Haste(-0.5f, 3.f);
		}
	}
}

function Haste(float ASpeedMod, float MSpeedMod)
{
	if(hasteTarget != none && !hasteCooldown)
	{
		//`log("Hasting: " @ hasteTarget);
		hasteTarget.AttackSpeed += hasteTarget.baseAttackSpeed * ASpeedMod;
		hasteTarget.GroundSpeed += hasteTarget.baseGroundSpeed * MSpeedMod;
		SetTimer(hasteCD, false, 'ResetHasteCooldown');
		hasteCooldown = true;
		
		HLW_AIController(hasteTarget.Controller).GotoState('Attacking');
	}
}

function ResetHasteCooldown()
{
	hasteCooldown = false;
	hasteTarget.AttackSpeed = hasteTarget.baseAttackSpeed;
	hasteTarget.GroundSpeed = hasteTarget.baseGroundSpeed;
}

function Attack(Pawn target)
{
	local HLW_Projectile_Fire MyProjectile;

	if (!IsStunned())
	{
		MyProjectile = spawn(class'HLW_Projectile_Fire', self,, Location);
		MyProjectile.Init(normal(target.Location - Location));
	}
}

defaultproperties
{
	hasteCD=15.0
	hasteRange=1024
	
	GroundSpeed=175.0
	attackRange=1024
	attackSpeed=1f
	Health=400
	HealthMax=400
	minGold=10
	maxGold=15
	bumpDamage=10
	
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
        bHasPhysicsAssetInstance=true
        PhysicsAsset=PhysicsAsset'HLW_Package_Creeps.PhysicsAsset.Creep_Goblin_Physics'
		AnimSets(0)=AnimSet'HLW_Package_Creeps.AnimSet.Creep_Goblin_Anims'
        AnimTreeTemplate=AnimTree'HLW_Package_Creeps.AnimTree.Creep_Goblin_AnimTree'
        SkeletalMesh=SkeletalMesh'HLW_Package_Creeps.SkeletalMesh.Creep_Goblin'
        //AnimSets(0)=AnimSet'HLW_Package.Animations.raptor_animset'
        //AnimTreeTemplate=AnimTree'HLW_Package.Animations.raptor_animtree'
        Scale3D=(X=2.0,Y=2.0,Z=2.0)
    End Object
    Mesh=InitialSkeletalMesh
    Components.Add(InitialSkeletalMesh)
    
	Begin Object Name=CollisionCylinder
	CollisionRadius=+0035.000000
	CollisionHeight=+0040.000000
	End Object	
}