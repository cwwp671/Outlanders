class HLW_PlayerReplicationInfo extends PlayerReplicationInfo;

var int classSelection;

var(Character) int UpgradePoints;
var(Character) int WeaponIndex;
var(Experience) int Level;
var(Experience) repnotify int Experience;
var(Experience) repnotify int ExperienceMax;
var(Experience) float ExperienceMaxScaleRate; // Percentage of ExperienceMax to increase ExperienceMax by upon level up
var(Finances) repnotify int Gold;
var(Finances) repnotify int Income;
var(Character) int Assists;
var(Character) int HLW_Kills;
var(Stats) float MovementSpeed;
var(Stats) float AttackSpeed;
var(Stats) float PhysicalPower;
var(Stats) float MagicalPower;
var(Stats) float PhysicalDefense;
var(Stats) float MagicalDefense;
var(Stats) float CooldownReduction;
var(Stats) float Resistance;
var(Stats) float HP5;
var(Stats) float MP5;
var(Stats) repnotify int Mana;
var(Stats) repnotify int ManaMax;
var(HUD) int DamageTaken;
var(HUD) bool bCanDrawDamage;

var(HUD) int TotalDamageTaken; // For Stats Screens
var(HUD) int TotalDamageDone; // For Stats Screens

var int HLW_HealthMax;
var int HLW_Health;
var bool bStatsSet;
//CJL Need to make Creep Kills var
var int SelectedCreep;

var repnotify HLW_Ability Abilities[5];
var bool bAbilitiesInitialized;

struct ScreenIndicator
{
	var MaterialInstanceConstant MaterialInstanceConstant;
	var Vector2D Offset;
	var float Opacity;
	var bool bCanDraw;
	var bool DeleteMe;
};

var repnotify ScreenIndicator Indicator;
//var repnotify ScreenIndicator RepIndicator;


replication
{
	if(bNetDirty)
		Indicator, Level, HLW_Kills, classSelection, Gold, Assists, HLW_HealthMax, HLW_Health, DamageTaken, TotalDamageDone, TotalDamageTaken;
	
	if (bNetDirty && bNetOwner)
		Abilities, UpgradePoints,
		Experience, ExperienceMax, Income, MovementSpeed, AttackSpeed,
		PhysicalPower, MagicalPower, PhysicalDefense, MagicalDefense, CooldownReduction, Resistance, HP5, MP5, Mana, ManaMax,
		bCanDrawDamage, bStatsSet, WeaponIndex,
		 //Character
		SelectedCreep;//, HLW_Health, HLW_HealthMax;
}

simulated event ReplicatedEvent(name VarName)
{
	local int i;

	if(VarName == 'Indicator')
	{
		//ClientSetIndicator(Indicator);	
	}

	if (Role < ROLE_Authority && bNetOwner)
	{
		if ( VarName == 'Abilities')
		{
			//`log("    ");
			//`log("HLW PRI Abilities replicated to client " @ Role);
			//`log("Abilities on client are: ");
			for (i = 0; i < 5; i++)
			{
				//`log("HLW PRI Client Abilities at " @ i @ ":" @ Abilities[i]);
			}
			
			if(Abilities[0] != none)
			{
				if(Abilities[4].AbilityLevel < 1)
				{
					HLW_PlayerController(Owner).SpendUpgradePoint(4); //Unlock ultimate at level 1
				}
			}
		}
		else if ( VarName == 'Experience' || VarName == 'ExperienceMax')
		{
			HLW_HUD_Class(HLW_PlayerController(Owner).myHUD).CharacterComponentHUD.CallUpdateExperience(ExperienceMax, Experience);
			HLW_HUD_Class(HLW_PlayerController(Owner).myHUD).CharacterComponentHUD.CallUpdateLevel(Level);
			return;
		}
		else if (VarName == 'Gold' || VarName == 'Income')
		{
			//HLW_HUD_Class(HLW_PlayerController(Owner).myHUD).FinanceComponentHUD.CallUpdateGold(Gold);
			//HLW_HUD_Class(HLW_PlayerController(Owner).myHUD).FinanceComponentHUD.CallUpdateIncome(Income);
			return;
		}
		else
		{
			Super.ReplicatedEvent(VarName);
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

function Reset()
{
	local int i;

	super.Reset();

	Level = default.Level;
	Experience = default.Experience;
	ExperienceMax = default.ExperienceMax;
	ExperienceMaxScaleRate = default.ExperienceMaxScaleRate;
	Gold = default.Gold;
	Income = default.Income;
	MovementSpeed = default.MovementSpeed;
	AttackSpeed = default.AttackSpeed;
	PhysicalPower = default.PhysicalPower;
	MagicalPower = default.MagicalPower;
	PhysicalDefense = default.PhysicalDefense;
	MagicalDefense = default.MagicalDefense;
	CooldownReduction = default.CooldownReduction;
	Resistance = default.Resistance;
	HP5 = default.HP5;
	MP5 = default.MP5;
	Mana = default.Mana;
	ManaMax = default.ManaMax;
	HLW_HealthMax = default.HLW_HealthMax;
	HLW_Kills = default.HLW_Kills;
	Assists = default.Assists;
	bStatsSet = default.bStatsSet;
	DamageTaken = default.DamageTaken;
	bCanDrawDamage = default.bCanDrawDamage;
	SelectedCreep = default.SelectedCreep;
	bAbilitiesInitialized = default.bAbilitiesInitialized;
	UpgradePoints = default.UpgradePoints;

	if(Abilities[0] != none)
	{
		for (i = 0; i < 5; i++)
		{
			Abilities[i].Destroy();
		}
	}
}

function CopyProperties(PlayerReplicationInfo PRI)
{
	HLW_PlayerReplicationInfo(PRI).HLW_Kills = HLW_Kills;
	HLW_PlayerReplicationInfo(PRI).Assists = Assists;
	
	super.CopyProperties(PRI);
}

simulated function SetSelectedCreep(int NewValue)
{
	SelectedCreep = NewValue;
	
	if (Role < ROLE_Authority)
		ServerSetSelectedCreep(NewValue);
}

reliable server function ServerSetSelectedCreep(int NewValue)
{
	if (Role == ROLE_Authority)
		SetSelectedCreep(NewValue);
}

simulated function SetMovementSpeed(float NewAmount)
{
	MovementSpeed =  FMax(0.0, NewAmount);

	if (Role < ROLE_Authority)
		ServerSetMovementSpeed(NewAmount);
}

simulated function SetAttackSpeed(float NewAmount)
{
	AttackSpeed = FMax(0.0, NewAmount);

	if (Role < ROLE_Authority)
		ServerSetAttackSpeed(NewAmount);
}

simulated function SetPhysicalPower(float NewAmount)
{
	PhysicalPower = FMax(0.0, NewAmount);

	if (Role < ROLE_Authority)
		ServerSetPhysicalPower(NewAmount);
}

simulated function SetMagicalPower(float NewAmount)
{
	MagicalPower = FMax(0.0, NewAmount);

	if (Role < ROLE_Authority)
		ServerSetMagicalPower(NewAmount);
}

simulated function SetPhysicalDefense(float NewAmount)
{
	PhysicalDefense = FClamp(NewAmount, -1.0, 1.0);

	if (Role < ROLE_Authority)
		ServerSetPhysicalDefense(NewAmount);
}

simulated function SetMagicalDefense(float NewAmount)
{
	MagicalDefense = FClamp(NewAmount, -1.0, 1.0);

	if (Role < ROLE_Authority)
		ServerSetMagicalDefense(NewAmount);
}

simulated function SetCooldownReduction(float NewAmount)
{
	CooldownReduction = FMax(0.0, NewAmount);

	if (Role < ROLE_Authority)
		ServerSetCooldownReduction(NewAmount);
}

simulated function SetResistance(float NewAmount)
{
	Resistance = FMax(0.0, NewAmount);

	if (Role < ROLE_Authority)
		ServerSetResistance(NewAmount);
}

simulated function SetMana(int NewAmount)
{
	Mana = NewAmount > ManaMax ? ManaMax : NewAmount < 0 ? 0 : NewAmount;

	if (Role < ROLE_Authority)
		ServerSetMana(NewAmount);
}

simulated function SetManaMax(int NewAmount)
{
	ManaMax = Max(0, NewAmount);

	if (ManaMax < Mana)
		Mana = ManaMax;

	if (Role < ROLE_Authority)
		ServerSetManaMax(NewAmount);
}

simulated function SetHealth(int NewAmount)
{
	HLW_Health = NewAmount > HLW_HealthMax ? HLW_HealthMax : NewAmount < 0 ? 0 : NewAmount;
	
	if (Role < ROLE_Authority)
		ServerSetHealth(NewAmount);
}

simulated function SetMP5(float NewAmount)
{
	MP5 = FMax(0.0, NewAmount);

	if (Role < ROLE_Authority)
		ServerSetMP5(NewAmount);

}

simulated function SetHP5(float NewAmount)
{
	HP5 = FMax(0.0, NewAmount);

	if (Role < ROLE_Authority)
		ServerSetHP5(NewAmount);
}

simulated function SetGold(int NewAmount)
{
	Gold = Max(0, NewAmount);

	if (Role < ROLE_Authority)
		ServerSetGold(NewAmount);
}

simulated function SetIncome(int NewAmount)
{
	Income = Max(0, NewAmount);

	if (Role < ROLE_Authority)
		ServerSetIncome(NewAmount);
}

simulated function SetExperience(int NewAmount)
{
	local int earlyStop; // for the safenesses
	earlyStop = 0;

	Experience = Max(0, NewAmount);

	while (Experience >= ExperienceMax && earlyStop < 25)
	{
		LevelUp();
		earlyStop++;
	}

	if (Role < ROLE_Authority)
		ServerSetExperience(NewAmount);
}

simulated function SetDamageTaken(int NewAmount)
{
	DamageTaken = NewAmount;//Max(0, NewAmount);

	if (Role < ROLE_Authority)
		ServerSetDamageTaken(NewAmount);	
}

simulated function SetDraw(bool NewBool)
{
	bCanDrawDamage = NewBool;
	
	if (Role < ROLE_Authority)
		ServerSetDraw(NewBool);	
}

// CJL Should probably make this to set to a specific amount like the other functions, instead of ++
simulated function SetKills()
{
	local HLW_Pawn_Class ClassOwner;

	if(Role == ROLE_Authority)
	{
		ClassOwner = HLW_Pawn_Class(Controller(Owner).Pawn);

		if(ClassOwner != none)
		{
			ClassOwner.VoiceOver = ClassOwner.VoiceCueKill;
			ClassOwner.PlayVoiceOver(ClassOwner.VoiceOver);
		}
	}
	
	HLW_Kills++;
	
	if(Role < ROLE_Authority)
		ServerSetKills();	
}

// CJL Should probably make this to set to a specific amount like the other functions, instead of ++
simulated function SetAssists()
{
	Assists++;

	if(Role < ROLE_Authority)
		ServerSetAssists();
}

simulated function SetIndicator()
{
	local LinearColor TeamColor, FFAColor, ClassIcon;
	Indicator.MaterialInstanceConstant = new () class'MaterialInstanceConstant';
	
	Indicator.MaterialInstanceConstant.SetParent(Material'HLW_mapProps.guimaterials.PlayerMarker');

	//`log("PRI Material:"@Indicator.MaterialInstanceConstant);
	
	if(Team != None)
	{
		//`log("PRI: Team Isn't None");
		TeamColor = ColorToLinearColor(Team.TeamColor);
		Indicator.MaterialInstanceConstant.SetVectorParameterValue('PlayerColor', TeamColor);
	}
	else
	{
		//`log("PRI: FFA");
		
		FFAColor.R = 1;
		FFAColor.G = 0;
		FFAColor.B = 0;
		
		Indicator.MaterialInstanceConstant.SetVectorParameterValue('PlayerColor', FFAColor);
	}
	
	//`log("PRI Class:"@classSelection);
	
	switch(classSelection)
	{
		case 1:
			//`log("PRI: Mage");
			ClassIcon.R = 0.75;
			ClassIcon.G = 0.75;
			ClassIcon.B = 0;
			break;
		case 2:
			//`log("PRI: Archer");
			ClassIcon.R = 0.25;
			ClassIcon.G = 0.25;
			ClassIcon.B = 0;
			break;
		case 3:
			//`log("PRI: Warrior");
			ClassIcon.R = 0.25;
			ClassIcon.G = 0.75;
			ClassIcon.B = 0;
			break;
		
	}

	Indicator.MaterialInstanceConstant.SetVectorParameterValue('IconOffset', ClassIcon);
	
	if(Role < ROLE_Authority)
		ServerSetIndicator();
}
simulated function SetWeaponIndex(int NewIndex)
{
	WeaponIndex = NewIndex;	

	if (Role < ROLE_Authority)
		ServerSetWeaponIndex(NewIndex);
}

reliable client function ClientSetIndicator(ScreenIndicator IN_Indicator)
{
	//`log("PRI IN_Indicator:"@IN_Indicator.MaterialInstanceConstant);
	//`log("PRI Indicator:"@Indicator.MaterialInstanceConstant);
	Indicator = IN_Indicator;
	//`log("PRI OUT_Indicator:"@Indicator.MaterialInstanceConstant);
}

simulated function SetIndicatorOpacity(float InOpacity)
{
	Indicator.Opacity = InOpacity;
	
	if(Role < ROLE_Authority)
		ServerSetIndicatorOpacity(InOpacity);
}

function LevelUp()
{
	Level++; // Increase level
	UpgradePoints++; // Award upgrade points
	Experience = Max(0,  Experience - ExperienceMax); // Account for overflow XP
	ExperienceMax += (ExperienceMax * ExperienceMaxScaleRate); // Set new XP requirement for next level
	IncreaseStats(); // Increase stats
	
	// If we have an Owner and Pawn, notify them that they have leveled up
	if (Controller(Owner) != none && HLW_Pawn_Class(Controller(Owner).Pawn) != none)
	{
		HLW_Pawn_Class(Controller(Owner).Pawn).LeveledUp();
	}

	if (Role < ROLE_Authority && WorldInfo.NetMode != NM_Standalone)
	{
		ServerLevelUp();
	}
	else
	{
		ClientLevelUp();
	}
}

reliable client function ClientLevelUp()
{
	HLW_PlayerController(Owner).SpendUpgradePoint(4); //Upgrade ultimate on level up
}

simulated function IncreaseStats(optional float Scalar = 1.0f)
{
	local int ManaIncrease, HealthIncrease;
	local float PhysPowIncrease, MagPowIncrease, HP5Increase, MP5Increase;

	local HLW_Pawn_Class ClassOwner;
	
	ClassOwner = HLW_Pawn_Class(Controller(Owner).Pawn);

	if (Role < ROLE_Authority)
	{
		ServerIncreaseStats();
	}
	else
	{
		if (ClassOwner != none)
		{
			ClassOwner.ExpReward = ((ClassOwner.BaseExpReward * Level) + ((ClassOwner.BaseExpReward * Level) / Level)) / 2;

			ManaIncrease = ClassOwner.ManaIncreaseOnLevelPercentage * ClassOwner.BaseManaMax;
			HealthIncrease = ClassOwner.HealthIncreaseOnLevelPercentage * ClassOwner.BaseHealthMax;
			PhysPowIncrease = ClassOwner.PhysicalPowerIncreaseOnLevelPercentage * ClassOwner.BasePhysicalPower;
			MagPowIncrease = ClassOwner.MagicalPowerIncreaseOnLevelPercentage * ClassOwner.BaseMagicalPower;
			HP5Increase = ClassOwner.HP5IncreaseOnLevelPercentage * ClassOwner.BaseHP5;
			MP5Increase = ClassOwner.MP5IncreaseOnLevelPercentage * ClassOwner.BaseMP5;

			SetManaMax(ManaMax + (ManaIncrease * Scalar));
			SetMana(Mana + (ManaIncrease * Scalar));
			SetHealthMax(HLW_HealthMax + (HealthIncrease * Scalar));
			ClassOwner.Health += (HealthIncrease * Scalar);
			SetPhysicalPower(PhysicalPower + (PhysPowIncrease * Scalar));
			SetMagicalPower(MagicalPower + (MagPowIncrease * Scalar));
			SetHP5(HP5 + (HP5Increase * Scalar));
			SetMP5(MP5 + (MP5Increase * Scalar));

			//`log("New Mana: " @ ManaMax);
			//`log("New Health: " @ HLW_HealthMax);
			//`log("New PhysPower: " @ PhysicalPower);
			//`log("New MagPower: " @ MagicalPower);
			//`log("New HP5: " @ HP5);
			//`log("New MP5: " @ MP5);
		}
	}
}

simulated function SetHealthMax(int NewAmount)
{
	local HLW_Pawn_Class ClassOwner;

	HLW_HealthMax = Max(0, NewAmount);

	ClassOwner = HLW_Pawn_Class(Controller(Owner).Pawn);
	if (ClassOwner != none)
	{
		ClassOwner.HealthMax = HLW_HealthMax;
	}

	if (Role < ROLE_Authority)
		ServerSetHealthMax(NewAmount);
}

simulated function SetUpgradePoints(int NewAmount)
{
	UpgradePoints = Max(0, NewAmount);

	if (Role < ROLE_Authority)
		ServerSetUpgradePoints(NewAmount);
}

simulated function IncreaseTotalDamageDone(int Increment)
{
	TotalDamageDone += Increment;

	if(Role < ROLE_Authority)
	{
		ServerIncreaseTotalDamageDone(Increment);
	}
}

simulated function IncreaseTotalDamageTaken(int Increment)
{
	TotalDamageTaken += Increment;

	if(Role < ROLE_Authority)
	{
		ServerIncreaseTotalDamageTaken(Increment);
	}
}

reliable server function ServerIncreaseTotalDamageDone(int Increment)
{
	if(Role == ROLE_Authority)
	{
		IncreaseTotalDamageDone(Increment);
	}
}

reliable server function ServerIncreaseTotalDamageTaken(int Increment)
{
	if(Role == ROLE_Authority)
	{
		IncreaseTotalDamageTaken(Increment);
	}
}

reliable server function ServerIncreaseStats()
{
	if (Role == ROLE_Authority)
		IncreaseStats();
}

reliable server function ServerSetUpgradePoints(int NewAmount)
{
	if (Role == ROLE_Authority)
		SetUpgradePoints(NewAmount);
}

reliable server function ServerSetHealthMax(int NewAmount)
{
	if (Role == ROLE_Authority)
		SetHealthMax(NewAmount);
}

reliable server function ServerSetMovementSpeed(float NewAmount)
{
	if (Role == ROLE_Authority)
		SetMovementSpeed(NewAmount);
}

reliable server function ServerSetAttackSpeed(float NewAmount)
{
	if (Role == ROLE_Authority)
		SetAttackSpeed(NewAmount);
}

reliable server function ServerSetPhysicalPower(float NewAmount)
{
	if (Role == ROLE_Authority)
		SetPhysicalPower(NewAmount);
}

reliable server function ServerSetMagicalPower(float NewAmount)
{
	if (Role == ROLE_Authority)
		SetMagicalPower(NewAmount);
}

reliable server function ServerSetPhysicalDefense(float NewAmount)
{
	if (Role == ROLE_Authority)
		SetPhysicalDefense(NewAmount);
}

reliable server function ServerSetMagicalDefense(float NewAmount)
{
	if (Role == ROLE_Authority)
		SetMagicalDefense(NewAmount);
}

reliable server function ServerSetCooldownReduction(float NewAmount)
{
	if (Role == ROLE_Authority)
		SetCooldownReduction(NewAmount);
}

reliable server function ServerSetResistance(float NewAmount)
{
	if (Role == ROLE_Authority)
		SetResistance(NewAmount);
}

// CJL See about moving mana into Pawn, and having it work like Health
reliable server function ServerSetMana(int NewAmount)
{
	if (Role == ROLE_Authority)
		SetMana(NewAmount);
}

reliable server function ServerSetManaMax(int NewAmount)
{
	if (Role == ROLE_Authority)
		SetManaMax(NewAmount);
}

reliable server function ServerSetHealth(int NewAmount)
{
	if(Role == ROLE_Authority)
		SetHealth(NewAmount);	
}

reliable server function ServerSetMP5(float NewAmount)
{
	if (Role == ROLE_Authority)
		SetMP5(NewAmount);
}

reliable server function ServerSetHP5(float NewAmount)
{
	if (Role == ROLE_Authority)
		SetHP5(NewAmount);
}

reliable server function ServerSetGold(int NewAmount)
{
	if (Role == ROLE_Authority)
		SetGold(NewAmount);
}

reliable server function ServerSetIncome(int NewAmount)
{
	if (Role == ROLE_Authority)
		SetIncome(NewAmount);
}

reliable server function ServerSetExperience(int NewAmount)
{
	if (Role == ROLE_Authority)
		SetExperience(NewAmount);
}

reliable server function ServerSetDamageTaken(int NewAmount)
{
	if(Role == ROLE_Authority)
		SetDamageTaken(NewAmount);	
}

reliable server function ServerSetDraw(bool NewBool)
{
	if (Role == ROLE_Authority)
		SetDraw(NewBool);	
}

reliable server function ServerLevelUp()
{
	if (Role == ROLE_Authority)
		LevelUp();
}

reliable server function ServerSetKills()
{
	if (Role == ROLE_Authority)
		SetKills();
}

reliable server function ServerSetAssists()
{
	if (Role == ROLE_Authority)
		SetAssists();
}

reliable server function ServerSetIndicator()
{
	if(Role == ROLE_Authority)
		SetIndicator();
}

reliable server function ServerSetWeaponIndex(int NewIndex)
{
	if (Role == ROLE_Authority)
		SetWeaponIndex(NewIndex);
}

reliable server function ServerSetIndicatorOpacity(float InOpacity)
{
	if(Role == ROLE_Authority)
		SetIndicatorOpacity(InOpacity);
}

DefaultProperties
{
	NetUpdateFrequency=5
	classSelection=0

	Level=1
	Experience=0
	ExperienceMax=500
	ExperienceMaxScaleRate=0.2f // Upon level up: ExperienceMax += (ExperienceMax * ExperienceMaxScaleRate)
	Gold=150
	Income=10
	MovementSpeed=300.0f
	AttackSpeed=10.0f
	PhysicalPower=50.0f // OutgoingPhysicalDamage = BaseDamage + (PhysicalPower * 0.1)
	MagicalPower=50.0f // OutgoingMagicalDamage = BaseDamage + (MagicalPower * 0.1)
	PhysicalDefense=0.1f // IncomingPhysicalDamage -= (PhysicalDefense * 0.1)
	MagicalDefense=0.1f // IncomingMagicalDamage -= (MagicalDefense * 0.1)
	CooldownReduction=0.1f // CooldownTime -= (CooldownTime * CooldownReduction)
	Resistance=0.1f
	HP5=5 // Amount of Health restored over 5 seconds. Pawns will handle the division based on regen rate
	MP5=5 // Amount of Mana restored over 5 seconds. Pawns will handle the division based on regen rate
	Mana=300
	ManaMax=300
	HLW_HealthMax=300
	HLW_Kills=0
	Assists=0
	UpgradePoints=1

	bStatsSet=false
	bAbilitiesInitialized=false
}
