class HLW_Creep_Spawn_Volume extends Volume
	ClassGroup(HeroLineWars)
	HideCategories(Attachment, Collision, Physics, Debug, Object)
	Placeable;

var const int lengthTopVolume;
var const int lengthBotVolume;
var int width;


defaultproperties
{
	lengthTopVolume=3000;
	lengthBotVolume=1800;
	width=1500;
}