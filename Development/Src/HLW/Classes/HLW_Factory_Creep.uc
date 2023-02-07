class HLW_Factory_Creep extends Actor
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
var(Factory) const array<Route> routes;
var(Factory) const float spawnTimer;
var(Factory) const int maximumCreepCount;
var(Factory) const int MaxYSpawnOffset;
var(Factory) const int MaxXSpawnOffset;
var(Factory) const int teamIndex;
var(Factory) const HLW_Creep_Spawn_Volume topLaneVolume;
var(Factory) const HLW_Creep_Spawn_Volume botLaneVolume;

var int routeNumber;
var int zoneNumber;

reliable server function SpawnCreepTimer(int creepType, int creepLevel)
{
	local HLW_Pawn_Creep spawnedPawn;
	
	local HLW_AIController creepAIController;

	local vector offset;
	local vector SpawnLocation;
	
	//`log("SPAWNING - Factory");
	
	offset.Z = 0;
	
	if(zoneNumber == 1)
	{
		offset.X = rand(topLaneVolume.width) - (topLaneVolume.width / 2);
		offset.Y = rand(topLaneVolume.lengthTopVolume) - (topLaneVolume.lengthTopVolume / 2);
		
		SpawnLocation = topLaneVolume.Location + offset;
		
		routeNumber = rand(routes.Length / 2);
		
		zoneNumber = 2;
	}
	else if(zoneNumber == 2)
	{
		offset.X = rand(botLaneVolume.width) - (botLaneVolume.width / 2);
		offset.Y = rand(botLaneVolume.lengthBotVolume) - (topLaneVolume.lengthBotVolume / 2);
		
		SpawnLocation = botLaneVolume.Location + offset;
		
		routeNumber = rand(routes.Length / 2) + (routes.Length / 2);
		
		zoneNumber = 1;
	}
	
	
	
	//SpawnLocation = Location + offset;

	// Spawn the pawn using the pawn archetype
	switch(creepType)
	{
		case 1:
			SpawnedPawn = Spawn(smallCreepPawn.Class, Self,, SpawnLocation, Rotation, smallCreepPawn);
			break;
		case 2:
			SpawnedPawn = Spawn(bigCreepPawn.Class, Self,, SpawnLocation, Rotation, bigCreepPawn);
			break;
		case 3:
			SpawnedPawn = Spawn(fastCreepPawn.Class, Self,, SpawnLocation, Rotation, fastCreepPawn);
			break;
		case 4:
			SpawnedPawn = Spawn(mageCreepPawn.Class, Self,, SpawnLocation, Rotation, mageCreepPawn);
			break;
		case 5:
			SpawnedPawn = Spawn(archerCreepPawn.Class, Self,, SpawnLocation, Rotation, archerCreepPawn);
			break;
		case 6:
			SpawnedPawn = Spawn(healerCreepPawn.Class, Self,, SpawnLocation, Rotation, healerCreepPawn);
			break;
		case 7:
			SpawnedPawn = Spawn(bossCreepPawn.Class, Self,, SpawnLocation, Rotation, bossCreepPawn);
			break;
		default:
			break;
	}	


	if (SpawnedPawn != None)
	{
		// Restart the creep
		spawnedPawn.teamIndex = self.teamIndex;
		creepAIController = HLW_AIController(spawnedPawn.Controller);
		if (creepAIController != None)
		{
			creepAIController.Initialize();
		}
		spawnedPawn.creepLevel = creepLevel;
		spawnedPawn.Initialize();
	}
	
	//`log("Role: " @ spawnedPawn.Role);
}

defaultproperties
{
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
	
	routeNumber=0
	zoneNumber=1
}