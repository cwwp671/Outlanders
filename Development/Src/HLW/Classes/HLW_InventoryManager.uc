class HLW_InventoryManager extends InventoryManager;

var bool bNextWeapon;
var int HUDIndex;

enum TrapType
{
	HLW_POISON,
	HLW_EXPLOSIVE,
	HLW_BEAR
};

//UP ON MOUSEWHEEL
simulated function PrevWeapon()
{
	if(HLW_Pawn_Class_Mage(Instigator) != None)
	{
		if(HLW_Spell_Weapon(HLW_Pawn_Class_Mage(Instigator).Weapon).bCanSwitchWeapon)
		{
			HLW_Spell_Weapon(HLW_Pawn_Class_Mage(Instigator).Weapon).bCanSwitchWeapon = false;
			bNextWeapon = false;
			super.PrevWeapon();
		}
	}
	else if(HLW_Pawn_Class_Archer(Instigator) != None)
	{
		//HUDIndex--;
		//if(HUDIndex < 0)
			//HUDIndex = 2;
			
		HUDIndex = HLW_Ability_Trap(HLW_PlayerController(HLW_Pawn_Class_Archer(Instigator).Controller).GetAbility(3)).TrapIndex;
		HUDIndex--;
		if(HUDIndex < 0)
			HUDIndex = 2;
			
		HLW_Ability_Trap(HLW_PlayerController(HLW_Pawn_Class_Archer(Instigator).Controller).GetAbility(3)).SetTrap(HUDIndex);
		ServerSetTrap(HUDIndex);
		HLW_HUD_Archer(HLW_PlayerController(HLW_Pawn_Class_Archer(Instigator).Controller).myHUD).PowerComponentHUD.CallUpdateUp(HUDIndex);
		HLW_Pawn_Class_Archer(Instigator).SwitchTrap(HUDIndex);
	}
	else
	{
		bNextWeapon = false;
		super.PrevWeapon();
	}
}

reliable server function ServerSetTrap(int Index)
{
	//`log("B4 Trap:"@ HLW_Ability_Trap(HLW_PlayerController(HLW_Pawn_Class_Archer(Instigator).Controller).GetAbility(3)).GetTrapName());
	HLW_Ability_Trap(HLW_PlayerController(HLW_Pawn_Class_Archer(Instigator).Controller).GetAbility(3)).SetTrap(Index);
	//`log("After Trap:"@ HLW_Ability_Trap(HLW_PlayerController(HLW_Pawn_Class_Archer(Instigator).Controller).GetAbility(3)).GetTrapName());
}

//DOWN ON MOUSEWHEEL
simulated function NextWeapon()
{
	if(HLW_Pawn_Class_Mage(Instigator) != None)
	{
		if(HLW_Spell_Weapon(HLW_Pawn_Class_Mage(Instigator).Weapon).bCanSwitchWeapon)
		{
			HLW_Spell_Weapon(HLW_Pawn_Class_Mage(Instigator).Weapon).bCanSwitchWeapon = false;
			bNextWeapon = true;
			super.NextWeapon();
		}
	}
	else if(HLW_Pawn_Class_Archer(Instigator) != None)
	{
		//HUDIndex++;
		
		HUDIndex = HLW_Ability_Trap(HLW_PlayerController(HLW_Pawn_Class_Archer(Instigator).Controller).GetAbility(3)).TrapIndex;
		HUDIndex++;
		if(HUDIndex > 2)
			HUDIndex = 0;
			
		HLW_Ability_Trap(HLW_PlayerController(HLW_Pawn_Class_Archer(Instigator).Controller).GetAbility(3)).SetTrap(HUDIndex);
		ServerSetTrap(HUDIndex);
		HLW_HUD_Archer(HLW_PlayerController(HLW_Pawn_Class_Archer(Instigator).Controller).myHUD).PowerComponentHUD.CallUpdateDown(HUDIndex);
		HLW_Pawn_Class_Archer(Instigator).SwitchTrap(HUDIndex);
	}
	else
	{
		bNextWeapon = true;
		super.NextWeapon();
	}
}



reliable client function SetCurrentWeapon(Weapon DesiredWeapon)
{
	super.SetCurrentWeapon(DesiredWeapon);
	
	if(HLW_Pawn_Class_Mage(Instigator) != None && HLW_Spell_Weapon(DesiredWeapon) != None)
	{
		if(bNextWeapon)
		{
			HLW_HUD_Mage(HLW_PlayerController(HLW_Pawn_Class_Mage(Instigator).Controller).myHUD).SpellSelectorComponentHUD.CallUpdateDown(HLW_Spell_Weapon(DesiredWeapon).indexHUD);
		}
		else
		{
			HLW_HUD_Mage(HLW_PlayerController(HLW_Pawn_Class_Mage(Instigator).Controller).myHUD).SpellSelectorComponentHUD.CallUpdateUp(HLW_Spell_Weapon(DesiredWeapon).indexHUD);
		}
	}

}

defaultproperties
{
	HUDIndex=0
	PendingFire(0) = 0
	PendingFire(1) = 0
	PendingFire(2) = 0
	PendingFire(3) = 0
	PendingFire(4) = 0
	PendingFire(5) = 0
	PendingFire(6) = 0
	PendingFire(7) = 0
	PendingFire(8) = 0
	PendingFire(9) = 0
	PendingFire(10) = 0
}