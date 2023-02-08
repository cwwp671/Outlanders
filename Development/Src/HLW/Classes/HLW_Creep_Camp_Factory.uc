/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Creep_Camp_Factory extends Actor
	ClassGroup(HeroLineWars)
	HideCategories(Attachment, Collision, Physics, Debug, Object)
	Placeable;
	
var(Factory) const HLW_Pawn_Creep_Small smallCreepPawn;
var(Factory) const HLW_Pawn_Creep_Big bigCreepPawn;
var(Factory) const HLW_Pawn_Creep_Fast fastCreepPawn;
var(Factory) const HLW_Pawn_Creep_Mage mageCreepPawn;
var(Factory) const HLW_Pawn_Creep_Archer archerCreepPawn;
var(Factory) const HLW_Pawn_Creep_Healer healerCreepPawn;
var(Factory) const HLW_Pawn_Creep_Boss BossCreepPawn;
var(Factory) const HLW_TrainingDummy DummyPawn;
var(Factory) const int ID;
var(Factory) const float spawnTimer;
var(Factory) const Array<int> CampMembers;

var int sizeOfCamp;


var int numberOfCreepsAlive;
var int respawnTimer;
var bool campCleared;

event PostBeginPlay()
{
	local int i;
	for(i = 0; i < campMembers.Length; i++)
	{
		if(campMembers[i] != 0)
		{
			sizeOfCamp++;
		}
	}
	campCleared = true;
	SpawnCamp();
}


function CreepDied()
{
	numberOfCreepsAlive--;
	if(numberOfCreepsAlive <= 0)
	{
		campCleared = true;
		SetTimer(respawnTimer, false, 'SpawnCamp');
	}
}

function SpawnCamp()
{
	local int i;
	local vector spawnLocation;
	
	spawnLocation = Location;
	spawnLocation.X -= 150;

	if(campCleared)
	{
		numberOfCreepsAlive = CampMembers.Length;
		for(i = 0; i < campMembers.Length; i++)
		{
			if(campMembers[i] != 0)
			{
				SpawnCreeps(campMembers[i], 1, spawnLocation);
			}
			
			if((i == 2) || (i == 5))
			{
				spawnLocation.X -= 300;
				spawnLocation.Y += 150;
			}
			else
			{
				spawnLocation.X += 150;
			}
		}
		campCleared = false;
	}
	else
	{
		//`log("Got into spawn without camp being cleared");
	}
}

reliable server function SpawnCreeps(int creepType, int creepLevel, vector spawnLocation)
{
	local HLW_Pawn_Creep spawnedPawn;
	
	local HLW_AIController_Camp creepAIController;
	

	switch(creepType)
	{
		case 1:
			SpawnedPawn = Spawn(smallCreepPawn.Class, Self,, spawnLocation, Rotation, smallCreepPawn);
			break;
		case 2:
			SpawnedPawn = Spawn(bigCreepPawn.Class, Self,, spawnLocation, Rotation, bigCreepPawn);
			break;
		case 3:
			SpawnedPawn = Spawn(fastCreepPawn.Class, Self,, spawnLocation, Rotation, fastCreepPawn);
			break;
		case 4:
			SpawnedPawn = Spawn(mageCreepPawn.Class, Self,, spawnLocation, Rotation, mageCreepPawn);
			break;
		case 5:
			SpawnedPawn = Spawn(archerCreepPawn.Class, Self,, spawnLocation, Rotation, archerCreepPawn);
			break;
		case 6:
			SpawnedPawn = Spawn(healerCreepPawn.Class, Self,, spawnLocation, Rotation, healerCreepPawn);
			break;
		case 7:
			SpawnedPawn = Spawn(bossCreepPawn.Class, Self,, spawnLocation, Rotation, bossCreepPawn);
			break;
		case 8:
			SpawnedPawn = Spawn(DummyPawn.Class, Self,, spawnLocation, Rotation, DummyPawn);
		default:
			break;
	}	


	if (SpawnedPawn != None)
	{
		// Restart the creep
		creepAIController = HLW_AIController_Camp(spawnedPawn.Controller);
		if (creepAIController != None)
		{
			creepAIController.Initialize();
			creepAIController.groupID = ID;
			creepAIController.groupSize = sizeOfCamp;
		}
		spawnedPawn.creepLevel = creepLevel;
		spawnedPawn.Initialize();
	}
	
	//`log("Role: " @ spawnedPawn.Role);
	
}

defaultproperties
{
	respawnTimer=20
		
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.Ambientcreatures'
		HiddenGame=false
		HiddenEditor=false
		AlwaysLoadOnClient=false
		AlwaysLoadOnServer=false
		SpriteCategoryName="Pawns"
	End Object
	Components.Add(Sprite)

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=50.f
		CollisionHeight=50.f
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bEdShouldSnap=true
	bStatic=false
	bNoDelete=true
	bCollideWhenPlacing=true
}