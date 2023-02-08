/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */

class HLW_UpgradableParameter extends Object;

// These determine how this parameter will change when it upgrades
enum HLW_UpgradeTypes
{
	HLW_UT_AddPercentOfCurrent, // CurrentValue += (Factor * CurrentValue)
	HLW_UT_AddPercentOfBase,    // CurrentValue += (Factor * BaseValue)
	HLW_UT_AddFixedValue,       // CurrentValue += Factor
	HLW_UT_Multiply,            // CurrentValue *= Factor
	HLW_UT_Divide,              // CurrentValue /= Factor
	HLW_UT_None                 // CurrentValue = BaseValue
};

var protectedwrite float CurrentValue; // Most of the time, this is what you want to access for use with abilities.
var(Parameter) float BaseValue;
var(Parameter) float Factor; // This will have different uses depending on what this parameter's UpgradeType is (see comments on the enum).
var(Parameter) HLW_UpgradeTypes UpgradeType; // How this parameter will change as it upgrades
var(Parameter) int LevelFrequency; // How many levels to wait before upgrading. (Example: if 3, this parameter will only upgrade every 3 levels)

// Does the logic of upgrading the parameter.
// Level can be the ability level or even the player level
simulated function Upgrade(int Level)
{
	if (Level == 1) // If we are just now reaching level 1...
	{
		CurrentValue = BaseValue; // Initialize our values
	}
	else if (LevelFrequency == 0 || (LevelFrequency > 0 && Level % LevelFrequency == 0)) // If enough levels have passed...
	{
		// Adjust the CurrentValue based on our UpgradeType
		switch (UpgradeType)
		{
		case HLW_UT_AddPercentOfCurrent:
			CurrentValue += (Factor * CurrentValue);
			break;
		case HLW_UT_AddPercentOfBase:
			CurrentValue += (Factor * BaseValue);
			break;
		case HLW_UT_AddFixedValue:
			CurrentValue += Factor;
			break;
		case HLW_UT_Multiply:
			CurrentValue *= Factor;
			break;
		case HLW_UT_Divide:
			if (Factor == 0)
			{
				`warn("TRYING TO DIVIDE BY ZERO IN " $ self $ " YOU STUPID!");
				break;
			}
			else
				CurrentValue /= Factor;
			break;
		case HLW_UT_None:
			CurrentValue = BaseValue; // If none, don't change from the base
			break;
		default:
			`warn("Unrecognized HLW_UpgradeType: "$UpgradeType$" in class: "$self);
			break;
		}
	}
}

DefaultProperties
{
	LevelFrequency=1 // Default to upgrade every level
}
