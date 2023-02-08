/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Pawn_Class_Mage extends HLW_Pawn_Class
placeable;

var name ShootSocket;
var bool bCanHitReaction;
var StaticMeshComponent BronomiconHipMesh;
var StaticMeshComponent BronomiconHandMesh;
var int CurrentWeaponIndex;
var name BookSocket;
var name BookHandSocket;
var repnotify LinearColor CurrentSpellColor;
var repnotify float CurrentSpellPower;

replication
{
    if(bNetDirty)
        CurrentSpellColor, CurrentSpellPower;
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'CurrentSpellColor')
    {
    	ClientSetMaterialVector(ThirdPerson, 0, 'MageSpellColor', CurrentSpellColor);
    	return;
    }
    if ( VarName == 'CurrentSpellPower')
    {
    	ClientSetMaterialScalar(ThirdPerson, 0, 'MageSpellPower', CurrentSpellPower);
    	return;
    }
    
    super.ReplicatedEvent(VarName);
}

reliable client function ClientSetTeamColor(LinearColor NewTeamColor)
{
	super.ClientSetTeamColor(NewTeamColor);
	
	ClientSetMaterialVector(ThirdPerson, 0, 'MageCloakColor', NewTeamColor);
	ClientSetMaterialVector(Mesh, 0, 'TeamColor', NewTeamColor);
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	Mesh.SetAnimTreeTemplate(AnimTree'HLW_Package.Animations.1p_arms_mage_animtree');
	AttachComponent(ThirdPerson);
	
	//Might be a better way to do this, but for now
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_mapProps.Materials.MageMaterialMaster'); 
	ThirdPerson.SetMaterial(0, MatInst); 
	
	MatInst = new(None) Class'MaterialInstanceConstant';
	MatInst.SetParent(Material'HLW_Package_Lukas.Materials.Lambert_Param');
	Mesh.SetMaterial(0, MatInst);
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        CustomAnim = AnimNodePlayCustomAnim(Mesh.FindAnimNode('CustomAnimation'));
    }
    
    if (SkelComp == ThirdPerson)
    {
    	CustomAnimTP_Upper = AnimNodePlayCustomAnim(ThirdPerson.FindAnimNode('CustomUpperAnimation'));
    	CustomAnimTP_Lower = AnimNodePlayCustomAnim(ThirdPerson.FindAnimNode('CustomLowerAnimation'));
    	ThirdPerson.AttachComponentToSocket(BronomiconHipMesh, BookSocket);
    	BronomiconHandMesh.SetHidden(true);
    	ThirdPerson.AttachComponentToSocket(BronomiconHandMesh, BookHandSocket);
    }
}

reliable client function ClientAnimNodeBlend(AnimNodeBlend BlendThis, float Target, float Time)
{
	super.ClientAnimNodeBlend(BlendThis, Target, Time);
	if(Target == 1)
	{
		BronomiconHipMesh.SetHidden(true);
		BronomiconHandMesh.SetHidden(false);
	}
}

simulated function TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(Role < ROLE_Authority)
	{
		if(bCanHitReaction)
		{
			HitReaction();
		}
	}
	
	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

simulated function HitReaction()
{
	PlayAnimTP_Upper('CustimAnimTP', 'Mage_Upper_Hit_1', 1.0, 0.05, 0.05, false, true);
	
	bCanHitReaction = false;
	SetTimer(1.5f, false, 'ResetHitReaction');	
}

simulated function ResetHitReaction()
{
	bCanHitReaction = true;	
}

simulated function Tick(float DeltaTime)
{
	
	super.Tick(DeltaTime);	
}

simulated function PlayerInitialized()
{
	super.PlayerInitialized();
	
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(1, "Meteor", 2);
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(2, "Frost", 2);
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(3, "Thunder", 2);
	HLW_HUD_Class(HLW_PlayerController(Controller).myHUD).AbilityComponentHUD.CallCreateAbility(4, "Amplify", 2);
}

simulated function AddDefaultInventory()
{	
	super.AddDefaultInventory();
	
	switch(GetPRI().WeaponIndex)
	{
		case 0:
			InvManager.CreateInventory(class'HLW_Spell_Fire'); 
			InvManager.CreateInventory(class'HLW_Spell_Frost');
			InvManager.CreateInventory(class'HLW_Spell_Lightning'); 
			break;
			
		case 1:
			InvManager.CreateInventory(class'HLW_Spell_Frost');
			InvManager.CreateInventory(class'HLW_Spell_Lightning');
			InvManager.CreateInventory(class'HLW_Spell_Fire'); 
			break;
			
		case 2:
			InvManager.CreateInventory(class'HLW_Spell_Lightning');
			InvManager.CreateInventory(class'HLW_Spell_Fire'); 
			InvManager.CreateInventory(class'HLW_Spell_Frost');
			break;	
	}
    
}
simulated function SetActiveWeapon(Weapon NextWeapon)
{
	super.SetActiveWeapon(NextWeapon);
}
simulated function AbilityEndingAim(HLW_Ability Ability)
{
    super.AbilityEndingAim(Ability);
    //SwitchBook();
}

simulated function AbilityBeingCast(HLW_Ability Ability)
{
    super.AbilityBeingCast(Ability);
    
    SetTimer(0.75f, false, 'SwitchBook');
}

simulated function SwitchBook()
{
	BronomiconHipMesh.SetHidden(false);
	BronomiconHandMesh.SetHidden(true);
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{	
	return super.Died(Killer, damageType, HitLocation);	
}

DefaultProperties
{
	VoiceCueDied=SoundCue'HLW_Package_Voices.Mage.Died'
	//VoiceCueIdle=SoundCue'HLW_Package_Voices.Mage.Idle'
	VoiceCueLevelUp=SoundCue'HLW_Package_Voices.Mage.LevelUp'
	VoiceCueHurt=SoundCue'HLW_Package_Voices.Mage.Hurt'
	VoiceCueKill=SoundCue'HLW_Package_Voices.Mage.KilledPlayer'
	
	Begin Object Name=ArmsMesh
		SkeletalMesh=SkeletalMesh'HLW_Package_Dan.models.mage1stPerson'
		Translation=(X=0.0, Y=0.0, Z=-30.0)
	End Object
	
	Begin Object Name=ThirdPersonMesh
		bHasPhysicsAssetInstance=true
		AnimSets(0)=AnimSet'HLW_Package.Animations.3p_Mage_Animset'
		AnimTreeTemplate=AnimTree'HLW_Package.Animations.3p_Mage_Animtree'
		PhysicsAsset=PhysicsAsset'HLW_CONNOR_PAKAGE.Physics.3p_Mage_Base_Temp_Skele_Physics'
		SkeletalMesh=SkeletalMesh'HLW_Package.models.Mage_Textured_SkeletalMesh'
	End Object
	
	Begin Object class=StaticMeshComponent Name=BookMesh
		StaticMesh=StaticMesh'HLW_Package_Lukas.Bronomicon.Bronomicon'
		bAcceptsDecals=false
		Scale=1.5f
	End Object
	BronomiconHipMesh=BookMesh
	
	Begin Object class=StaticMeshComponent Name=BookOpenMesh
		StaticMesh=StaticMesh'HLW_Package_Lukas.Bronomicon.Bronomicon_Open'
		bAcceptsDecals=false
		Scale=1.5f
	End Object
	BronomiconHandMesh=BookOpenMesh
	
	ShootSocket=Mage_Finger
	BookSocket=BookJoint
	BookHandSocket=BookHandJoint
	bCanHitReaction=true
	
	BasePhysicalPower=0.0
	BaseMagicalPower=45.0
	BasePhysicalDefense=0.0
	BaseMagicalDefense=0.0
	BaseCooldownReduction=0.0
	BaseMovementSpeed=350
	BaseAttackSpeed=1.0
	BaseHealth=225
	BaseHealthMax=225
	BaseMana=250
	BaseManaMax=250
	BaseHP5=6.75
	BaseMP5=12.00
	BaseResistance=0.0

	ManaIncreaseOnLevelPercentage=0.25
	HealthIncreaseOnLevelPercentage=0.25
	PhysicalPowerIncreaseOnLevelPercentage=0.0
	MagicalPowerIncreaseOnLevelPercentage=0.42
	HP5IncreaseOnLevelPercentage=0.24
	MP5IncreaseOnLevelPercentage=0.24
	
	HeadBone=Character1_Head
	
	AbilityClasses(0)=class'HLW_Ability_Attunement' // PASSIVE
	AbilityClasses(1)=class'HLW_Ability_MeteorStrike' // 1
	AbilityClasses(2)=class'HLW_Ability_FrostShield' // 2
	AbilityClasses(3)=class'HLW_Ability_PulsingThunder' // 3
	AbilityClasses(4)=class'HLW_Ability_AmplifyAbility' // 4 (Ultimate)
	
	CurrentSpellColor=(R=0,G=0,B=0,A=0)
	CurrentTeamColor=(R=0,G=0,B=0,A=0)
	CurrentSpellPower=0
}
