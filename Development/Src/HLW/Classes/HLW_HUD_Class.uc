/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_HUD_Class extends HUD;

//var HLW_HUD_Creep_GFX CreepMovie;
//var int creepNumber;

var HLW_HUD_Class_GFX HudMovie;
var class<HLW_HUD_Class_GFX> HudMovieClass;
var HLW_HUD_Ability_GFX AbilityComponentHUD;
var HLW_HUD_Character_GFX CharacterComponentHUD;
var HLW_HUD_Timer_GFX GameTimerComponentHUD;
var HLW_HUD_HealthMana_GFX HealthAndManaComponentHUD;
var HLW_HUD_Finance_GFX FinanceComponentHUD;

var HLW_HUD_ChatWindow ChatWindowComponentHUD;
var class<HLW_HUD_ChatWindow> ChatWindowClass;

var Texture2D DefaultTexture;

var string PreMatchBeginText;

struct ScreenIndicator
{
	var MaterialInstanceConstant MaterialInstanceConstant;
	var Vector2D Offset;
	var float Opacity;
	var bool bCanDraw;
	var bool DeleteMe;
};

struct DamageText
{
	var string Text;
	var Vector2D Position;
	var Color Color;
	var Vector2D Size;
	var float LifeTime;
	var float LifeCounter;
};

var array<DamageText> DamageMessages;
//var DamageText DamageMessages[10];

var ScreenIndicator Indicator;

//var array<ScreenIndicator> ScreenIndicators;

function PushDamageMessage(string DamageAmount, Color MessageColor)
{
	local DamageText DamageMessage;
	//local byte i;
	DamageMessage.Text = DamageAmount;
	DamageMessage.Position.X = 0.0;
	DamageMessage.Position.Y = 0.0;
	DamageMessage.Color = MessageColor;
	DamageMessage.LifeTime = 2.0;
	DamageMessage.LifeCounter = 0.0;
	
	//ArrayCount(DamageMessages);
	//
	//for(i = 0; i < ArrayCount(DamageMessages); i++)
	//{
		//
	//}

	DamageMessages.AddItem(DamageMessage);
	//DamageMessages.Add(DamageMessage);
	`log("HUD Add Damage Message");
	
}

simulated event PostBeginPlay()
{
	//CreepMovie = new class'HLW_HUD_Creep_GFX';
	//CreepMovie.SetTimingMode(TM_Real);
	//CreepMovie.game = HLW_GameType(WorldInfo.Game); // Give the Movie player a reference to do things.
	
	AbilityComponentHUD = new class'HLW_HUD_Ability_GFX';
	AbilityComponentHUD.SetTimingMode(TM_Real);
	AbilityComponentHUD.Start();
	
	CharacterComponentHUD = new class'HLW_HUD_Character_GFX';
	CharacterComponentHUD.SetTimingMode(TM_Real);
	CharacterComponentHUD.Start();
	
	GameTimerComponentHUD = new class'HLW_HUD_Timer_GFX';
	GameTimerComponentHUD.SetTimingMode(TM_Real);
	GameTimerComponentHUD.Start();
	
	HealthAndManaComponentHUD = new class'HLW_HUD_HealthMana_GFX';
	HealthAndManaComponentHUD.SetTimingMode(TM_Real);
	HealthAndManaComponentHUD.Start();
	
	//FinanceComponentHUD = new class'HLW_HUD_Finance_GFX';
	//FinanceComponentHUD.SetTimingMode(TM_Real);
	//FinanceComponentHUD.Start();

	ChatWindowComponentHUD = new ChatWindowClass;
	ChatWindowComponentHUD.SetTimingMode(TM_Real);
	ChatWindowComponentHUD.Init();
}

function AddPostRenderedActor(Actor A)
{
	// Remove post render call for UTPawns as we don't want the name bubbles showing
	if (HLW_Pawn_Class(A) != None)
	{
		return;
	}

	Super.AddPostRenderedActor(A);
}

simulated function PostRender()
{
	DrawNames();
	DrawIndicators();
	DrawHealth();
	//DrawDamageMessages();
	LastHUDRenderTime = WorldInfo.TimeSeconds;

	if(PreMatchBeginText != "")
	{
		DrawPreMatchBeginText();
	}
	
	super.PostRender();
}

simulated function DrawPreMatchBeginText()
{
	local Vector2D TextSize;

	Canvas.DrawColor = WhiteColor;
	Canvas.Font = class'Engine'.static.GetLargeFont();
	Canvas.TextSize(PreMatchBeginText, TextSize.X, TextSize.Y);

	Canvas.SetPos(Canvas.ClipX * 0.5f - (TextSize.X * 0.5f), Canvas.ClipY * 0.1f);
	Canvas.DrawText(PreMatchBeginText);
}

simulated function DrawIndicators()
{
	local HLW_Pawn_Class HLW_PC;
	local Vector IndicatorLocation, PawnDirection, CameraDirection, CameraLocation;
	local Rotator CameraRotation;
	local float PointerSize;
	local LinearColor TeamColor, FFAColor, ClassIcon, HealthColor;
	
	PointerSize = Canvas.ClipX * 0.083f;
	
	if(PlayerOwner != None)
	{
		if(PlayerOwner.Pawn != None)
		{
			ForEach DynamicActors(class'HLW_Pawn_Class', HLW_PC)
			{
				if (HLW_PC.GetPRI() != HLW_Pawn_Class(PlayerOwner.Pawn).GetPRI())
				{
					//`log("Found Other Actor");
					Indicator.MaterialInstanceConstant = new () class'MaterialInstanceConstant';
	
					Indicator.MaterialInstanceConstant.SetParent(Material'HLW_mapProps.guimaterials.PlayerMarker');

					//`log("PRI Material:"@Indicator.MaterialInstanceConstant);
	
					if(HLW_PC.GetPRI() != none && HLW_PC.GetPRI().Team != None)
					{
						if(HLW_PC.GetPRI().Team.TeamIndex == HLW_Pawn_Class(PlayerOwner.Pawn).GetPRI().Team.TeamIndex)
						{
							TeamColor = HLW_PC.CurrentTeamColor;
							//`log("Same Team index:"@HLW_Pawn_Class(PlayerOwner.Pawn).GetPRI().Team.TeamIndex);
							//`log("PRI: Team Color-R:"@TeamColor.R@"G:"@TeamColor.G@"B:"@TeamColor.B@"A:"@TeamColor.A);
							Indicator.MaterialInstanceConstant.SetVectorParameterValue('PlayerColor', TeamColor);
						}
						else
						{
							//`log("NOT SAME TEAM"@HLW_PC.GetPRI().Team.TeamIndex);
							continue;
						}
					}
					else
					{
						//`log("PRI: FFA");
						//`log("Team is not set");
						continue;
						FFAColor.R = 1;
						FFAColor.G = 0;
						FFAColor.B = 0;
		
						Indicator.MaterialInstanceConstant.SetVectorParameterValue('PlayerColor', FFAColor);
					}
	
					//`log("PRI Class:"@HLW_PlayerReplicationInfo(HLW_PC.PlayerReplicationInfo).classSelection);
	
	
	
					if(HLW_Pawn_Class_Mage(HLW_PC) != None)
					{
						//`log("PRI: Mage");
						ClassIcon.R = 0.75;
						ClassIcon.G = 0.75;
						ClassIcon.B = 0;
					}
					else if(HLW_Pawn_Class_Archer(HLW_PC) != None)
					{
						//`log("PRI: Archer");
						ClassIcon.R = 0.25;
						ClassIcon.G = 0.25;
						ClassIcon.B = 0;
					}
					else if(HLW_Pawn_Class_Warrior(HLW_PC) != None)
					{
						//`log("PRI: Warrior");
						ClassIcon.R = 0.25;
						ClassIcon.G = 0.75;
						ClassIcon.B = 0;
					}
					else if(HLW_Pawn_Class_Barbarian(HLW_PC) != None)
					{
						//`log("PRI: Warrior");
						ClassIcon.R = 0.75;
						ClassIcon.G = 0.25;
						ClassIcon.B = 0;
					}
			
					Indicator.MaterialInstanceConstant.SetVectorParameterValue('IconOffset', ClassIcon);
					
					HealthColor.G = float(HLW_PC.GetPRI().HLW_Health) / float(HLW_PC.GetPRI().HLW_HealthMax); //% Of Health Left
					HealthColor.R = 1.0f - (float(HLW_PC.GetPRI().HLW_Health) / float(HLW_PC.GetPRI().HLW_HealthMax)); //% Of Health Missing
					HealthColor.B = 0;
					
					//`log("Health: R:"@HealthColor.R@"G:"@HealthColor.G@"B:"@HealthColor.B@"A:"@HealthColor.A);
					
					Indicator.MaterialInstanceConstant.SetVectorParameterValue('PlayerHealth', HealthColor);
					
					PawnDirection = Normal(HLW_PC.Location - PlayerOwner.Pawn.Location);
					PlayerOwner.GetPlayerViewPoint(CameraLocation, CameraRotation);
					CameraDirection = Vector(CameraRotation);
					
					// Check if the pawn is in front of me
					if (PawnDirection dot CameraDirection >= 0.f)
					{
						IndicatorLocation = HLW_PC.Location;
						IndicatorLocation.Z += HLW_PC.GetCollisionHeight();
						IndicatorLocation = Canvas.Project(IndicatorLocation);
						
						//`log("DRAWING INDICATOR:"@IndicatorLocation);
						//`log("Indicator Material:"@Indicator.MaterialInstanceConstant);
						Canvas.SetPos(IndicatorLocation.X - (PointerSize * 0.5f), IndicatorLocation.Y - (PointerSize * 0.5f) - 33.0f, IndicatorLocation.Z);
						Canvas.DrawMaterialTile(Indicator.MaterialInstanceConstant, PointerSize, PointerSize, 0.0f, 0.0f, 1.0f, 1.0f);
					}
				}
				else
				{
					//`log("It's me!!! I think:"@HLW_Pawn_Class(PlayerOwner.Pawn).GetPRI().classSelection);	
				}	
			}
		}
	}
}

simulated function DrawNames()
{
	local Vector TextLocation;
	local Vector2D TextSize;
	local HLW_Pawn_Class HLW_PC;
	
	if(PlayerOwner != None && PlayerOwner.Pawn != None)
	{
		//For Each Player
		ForEach DynamicActors(class'HLW_Pawn_Class', HLW_PC)
		{
			//If Player Isn't You & Is Still Online & Is Visible To You & Is Within 500 Units Distance Of You
			if (HLW_PC != PlayerOwner.Pawn && HLW_PC.GetPRI() != None && WorldInfo.TimeSeconds - HLW_PC.LastRenderTime < 0.1f && VSize(PlayerOwner.Pawn.Location - HLW_PC.Location) < 750)
			{
				if(HLW_PC.bDrawNamePlate && HLW_PC.Opacity != 0)
				{
					TextLocation = HLW_PC.Location; //Get Pawn 3D Location
					TextLocation.Z += HLW_PC.GetCollisionHeight() + 5; //Set Z Above Player
					TextLocation = Canvas.Project(TextLocation); //Convert Player 3D Location Into 2D Location
					Canvas.TextSize(HLW_PC.GetPRI().PlayerName, TextSize.X, TextSize.Y); //Find Visual Size Of String
					Canvas.SetPos(TextLocation.X - (TextSize.X / 2.0f), TextLocation.Y - (TextSize.Y / 2.0f), TextLocation.Z); //Set Text Location (Centered)

					
					Canvas.DrawColor.G = 255; //Green Text
					
					Canvas.DrawText(HLW_PC.GetPRI().PlayerName); //Draws Text
				}
			}
		}
	}	
}

function DrawDamageMessages()
{
	local byte i;
	local Vector2D TextSize;
	
	if(DamageMessages.Length == 0)
	{
		return;	
	}
	
	for(i = 0; i < DamageMessages.Length; i++)
	{
		//`log("Drawing DamageMessages["$i$"]:"@DamageMessages[i].Text);
		`log("1");
		DamageMessages[i].LifeCounter += WorldInfo.DeltaSeconds;
		`log("2");
		DamageMessages[i].Position.Y -= ((Canvas.ClipY * 0.5f) / DamageMessages[i].LifeTime) * WorldInfo.DeltaSeconds; //DamageMessages[i].LifeCounter * 5;
		
		//`log("Drawing DamageMessages["$i$"]:"@DamageMessages[i].Position.Y);
		`log("3");
		Canvas.Font = class'Engine'.static.GetLargeFont();
		`log("4");
		Canvas.TextSize(DamageMessages[i].Text, TextSize.X, TextSize.Y);
		`log("5");
		Canvas.SetPos(Canvas.ClipX * 0.4f - (TextSize.X * 0.5f), Canvas.ClipY * 0.5f + DamageMessages[i].Position.Y);
		`log("6");
		//Canvas.SetPos(DamageMessages[i].Position.X, DamageMessages[i].Position.Y);
		Canvas.DrawColor = WhiteColor;//DamageMessages[i].Color;
		`log("7");
		Canvas.DrawText(DamageMessages[i].Text);
		`log("8");
		if(DamageMessages[i].LifeCounter >= DamageMessages[i].LifeTime)
		{
			`log("9");
			DamageMessages.RemoveItem(DamageMessages[i]);
			//DamageMessages.Remove(DamageMessages[i]);	
		}
	}
}

simulated function DrawHealth()
{
	local Vector IndicatorLocation;
	local HLW_Pawn_Class HLW_PC;
	local HLW_Pawn_Creep HLW_Creep;
	local float HealthPercent;
	local float BarSize;
	
	BarSize = Canvas.ClipX * 0.05f;
	
	if(PlayerOwner != None && PlayerOwner.Pawn != None)
	{
		//For Each Player
		ForEach DynamicActors(class'HLW_Pawn_Class', HLW_PC)
		{
			//If Player Isn't You & Is Still Online & Is Visible To You & Is Within 500 Units Distance Of You
			if (HLW_PC != PlayerOwner.Pawn && HLW_PC.GetPRI() != None && WorldInfo.TimeSeconds - HLW_PC.LastRenderTime < 0.1f && VSize(PlayerOwner.Pawn.Location - HLW_PC.Location) < 750)
			{
				if(HLW_PC.bDrawNamePlate && HLW_PC.Opacity != 0)
				{
					IndicatorLocation = HLW_PC.Location;
					IndicatorLocation.Z += HLW_PC.GetCollisionHeight();
					IndicatorLocation = Canvas.Project(IndicatorLocation);
				
					Indicator.MaterialInstanceConstant = new () class'MaterialInstanceConstant';
	
					Indicator.MaterialInstanceConstant.SetParent(Material'HLW_mapProps.guimaterials.HPBar');

					HealthPercent = float(HLW_PC.GetPRI().HLW_Health) / float(HLW_PC.GetPRI().HLW_HealthMax);
					
					Indicator.MaterialInstanceConstant.SetScalarParameterValue('HP', HealthPercent);
					
					Canvas.SetPos(IndicatorLocation.X - (BarSize * 0.5f), IndicatorLocation.Y - (BarSize * 0.5f) - 15, IndicatorLocation.Z);
					Canvas.DrawMaterialTile(Indicator.MaterialInstanceConstant, BarSize, BarSize, 0.0f, 0.0f, 1.0f, 1.0f);
				}
			}
		}
		
		ForEach DynamicActors(class'HLW_Pawn_Creep', HLW_Creep)
		{
			if(WorldInfo.TimeSeconds - HLW_Creep.LastRenderTime < 0.1f && VSize(PlayerOwner.Pawn.Location - HLW_Creep.Location) < 750 && !HLW_Creep.bIsDead)
			{
				IndicatorLocation = HLW_Creep.Location;
				IndicatorLocation.Z += HLW_Creep.GetCollisionHeight();
				IndicatorLocation = Canvas.Project(IndicatorLocation);
				
				Indicator.MaterialInstanceConstant = new () class'MaterialInstanceConstant';
	
				Indicator.MaterialInstanceConstant.SetParent(Material'HLW_mapProps.guimaterials.HPBar');

				HealthPercent = float(HLW_Creep.Health) / float(HLW_Creep.HealthMax);
					
				Indicator.MaterialInstanceConstant.SetScalarParameterValue('HP', HealthPercent);
					
				Canvas.SetPos(IndicatorLocation.X - (BarSize * 0.5f), IndicatorLocation.Y - (BarSize * 0.5f) - 15, IndicatorLocation.Z);
				Canvas.DrawMaterialTile(Indicator.MaterialInstanceConstant, BarSize, BarSize, 0.0f, 0.0f, 1.0f, 1.0f);
			}
		}
	}	
}

simulated function DrawHUD()
{
	//if(PlayerOwner != None && PlayerOwner.Pawn != None)
	//{
		//if(PlayerOwner.Pawn != None)
		//if(HLW_Pawn_Class(PlayerOwner.Pawn).bHasDied)
		//{
			//AbilityComponentHUD.Close();
			//CharacterComponentHUD.Close();
			//GameTimerComponentHUD.Close();
			//HealthAndManaComponentHUD.Close();
			//FinanceComponentHUD.Close();
		//}
	//}
	
	super.DrawHUD();	
}

function CloseAllComponents()
{
	AbilityComponentHUD.Close(false);
	CharacterComponentHUD.Close(false);
	GameTimerComponentHUD.Close(false);
	HealthAndManaComponentHUD.Close(false);
	//FinanceComponentHUD.Close(false);
	ChatWindowComponentHUD.Close(false);
}

exec function OpenHUD()
{
	//if (!CreepMovie.bMovieIsOpen)
	//{
		//CreepMovie.Start();
	//}
	//
	//getCreepNumber();
	//
	//CreepMovie.SetPause(false);
	//PlayerOwner.SetCinematicMode(true, false, false, false, true, false);
}

exec function CloseHUD()
{
	//CreepMovie.SetPause(true);
	//CreepMovie.Close(false);
	//PlayerOwner.SetCinematicMode(false, false, false, false, true, false);
}

function getCreepNumber()
{
	//creepNumber = CreepMovie.getGFXCreepNumber();
	//HLW_PlayerController(PlayerOwner).setCreepNumber(creepNumber);
}

function float GetAngle(Vector PointB, Vector PointC)
{
	// Check if angle can easily be determined if it is up or down
	if (PointB.X == PointC.X)
	{
		return (PointB.Y < PointC.Y) ? Pi : 0.f;
	}

	// Check if angle can easily be determined if it is left or right
	if (PointB.Y == PointC.Y)
	{
		return (PointB.X < PointC.X) ? (Pi * 1.5f) : (Pi * 0.5f);
	}

	return (2.f * Pi) - atan2(PointB.X - PointC.X, PointB.Y - PointC.Y);
}

event Destroyed()
{
	if(ChatWindowComponentHUD != none)
	{
		ChatWindowComponentHUD.Close(true);
	}

	if(AbilityComponentHUD != none)
	{
		AbilityComponentHUD.Close(true);
	}

	if(CharacterComponentHUD != none)
	{
		CharacterComponentHUD.Close(true);
	}

	if(GameTimerComponentHUD != none)
	{
		GameTimerComponentHUD.Close(true);
	}

	if(HealthAndManaComponentHUD != none)
	{
		HealthAndManaComponentHUD.Close(true);
	}

	//if(FinanceComponentHUD != none)
	//{
	//	FinanceComponentHUD.Close(true);
	//}

	super.Destroyed();
}

defaultproperties
{
	ChatWindowClass=class'HLW.HLW_HUD_ChatWindow'
}