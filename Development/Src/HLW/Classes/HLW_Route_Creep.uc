/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_Route_Creep extends Actor
	ClassGroup(HeroLineWars)
	HideCategories(Attachment, Collision, Physics, Debug, Object)
	Placeable;

defaultproperties
{
	bEdShouldSnap=true
	bStatic=true
	bNoDelete=true
	bCollideWhenPlacing=true

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.Flag1'
		HiddenGame=true
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
}