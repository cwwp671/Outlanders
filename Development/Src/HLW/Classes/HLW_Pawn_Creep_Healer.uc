class HLW_Pawn_Creep_Healer extends HLW_Pawn_Creep
	ClassGroup(HeroLineWars)
	placeable;
	
var bool canHeal;
var int healAmount;
var float healRange;
var float healCD;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	CylinderComponent.SetCylinderSize(35.0 * Mesh.Scale3D.X, 40.0 * Mesh.Scale3D.Y);
}

function FindHealTarget()
{
	local HLW_AIController AIC;
	local Pawn healTarget;
	
    foreach DynamicActors(class'HLW_AIController', AIC)
    {
        if(AIC.Pawn != none)
        {
        	if(VSize(Location - AIC.Pawn.Location) < healRange)
        	{
				healTarget = AIC.Pawn;
            }
        }
    }

	if(healTarget.Health < healTarget.HealthMax - healAmount)
	{
		Heal(healTarget);
	}
}

function Heal(Pawn Other)
{
	
	if(Other != none && canHeal)
	{
		canHeal = false;
		SetTimer(healCD, true, 'HealCooldown');
		Other.Health += healAmount;
		//`log("Trying to heal! Heal Amount: " @ healAmount);
		//`log("Other's health: " @ Other.Health);
		Clamp(Other.Health, 1, Other.HealthMax);
	}	
}

function HealCooldown()
{
	canHeal = true;
}

function Attack(Pawn target)
{
	local HLW_Projectile_Frost MyProjectile;
	
	if (!IsStunned())
	{
		MyProjectile = spawn(class'HLW_Projectile_Frost', self,, Location);
		MyProjectile.Init(normal(target.Location - Location));
	}
}

defaultproperties
{
	canHeal=true
	healAmount=7
	healRange=1024
	healCD=15.0
	
	GroundSpeed=175.0
	attackRange=1024
	attackSpeed=0.2f
	Health=15
	HealthMax=300
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
        PhysicsAsset=PhysicsAsset'HLW_Package_Creeps.PhysicsAsset.Creep_Raptor_Physics'
		AnimSets(0)=AnimSet'HLW_Package_Creeps.AnimSet.Creep_Raptor_AnimSet'
        AnimTreeTemplate=AnimTree'HLW_Package_Creeps.AnimTree.Creep_Raptor_AnimTree'
        SkeletalMesh=SkeletalMesh'HLW_Package_Creeps.SkeletalMesh.Creep_Raptor'
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