class HLW_HUD_Class_GFX extends GFxMoviePlayer;

var HLW_GameType game;
var GFxObject RootMC;

function Init(Optional LocalPlayer LocPlay)
{
	super.Init(LocPlay);
	RootMC = GetVariableObject("_root");		
}

//Connor P
//Updates All HUD components at once
simulated function CallUpdateHUD(HLW_GameReplicationInfo GRI, HLW_Pawn_Class ClassPawn)
{
	local HLW_PlayerReplicationInfo PRI;
	local string GameTime;
	local int TimeMinutes;
	local int TimeSecondsOfMinute;

	if (ClassPawn != none)
	{
		PRI = ClassPawn.GetPRI();
		CallUpdateHealth(ClassPawn.HealthMax, ClassPawn.Health);
	}
	
	if (PRI != none)
	{
		CallUpdateMana(PRI.ManaMax, PRI.Mana);
		CallUpdateExperience(PRI.ExperienceMax, PRI.Experience);
		CallUpdateFinances(PRI.Gold, PRI.Income);
		CallUpdateLevel(PRI.Level);
	}

	// GRI.Elapsed time gives us only seconds. Math it for a 0:00 format
	TimeMinutes = GRI.ElapsedTime / 60;
	TimeSecondsOfMinute = GRI.ElapsedTime - (TimeMinutes * 60);
	GameTime = string(TimeMinutes)$":"$string(TimeSecondsOfMinute / 10)$string(TimeSecondsOfMinute - ((TimeSecondsOfMinute / 10) * 10));

	CallUpdateTime(GameTime);
}

simulated function CallUpdateHealth(float MaxHealth, float CurrentHealth)
{
	ActionScriptVoid("_root.UpdateHealth");
}

simulated function CallUpdateMana(float MaxMana, float CurrentMana)
{
	ActionScriptVoid("_root.UpdateMana");
}

simulated function CallUpdateExperience(float MaxExperience, float CurrentExperience)
{
	ActionScriptVoid("_root.UpdateExperience");
}

simulated function CallUpdateFinances(float TotalGold, float Income)
{
	ActionScriptVoid("_root.UpdateFinances");
}

simulated function CallUpdateLevel(float CurrentLevel)
{
	ActionScriptVoid("_root.UpdateLevel");
}

simulated function CallUpdateTime(string GameTime)
{
	ActionScriptVoid("_root.UpdateTime");
}

function bool Start(optional bool StartPaused = false)
{	
	Super.Start(StartPaused);
        Advance(0);
	return TRUE;
}

defaultproperties
{
	bAllowInput=false
	bAllowFocus=FALSE
	bCaptureInput=false
}