/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */

class HLW_MainMenu extends GFxMoviePlayer
	config(UI);

var HLW_OnlineGameSearch SearchSetting;

var OnlineGameInterface GameInterface;
var OnlineSubsystem OnlineSub;

var bool bResolutionChanged;

var bool bFOVChanged;

/** Volume config variables */
var config float MasterVolume, SFXVolume, VoiceVolume, MusicVolume, FOVAngle;

/** Volume Slider CLIK Widgets */
var GFxClikWidget MasterVolumeSlider, SFXVolumeSlider, VoiceVolumeSlider, MusicVolumeSlider;

/** Video Option CLIK Widgets */
var GFxClikWidget ResolutionDropDownMenu, ScreenModeDropDownMenu, VideoApplyButton, FOVSlider;

/** Control Option CLIK Widgets */
var GFxClikWidget InvertMouseCheckBox, MouseSensitivitySlider;

/** Keybind Option CLIK Widgets */
var GFxClikWidget KeybindScrollingList;

struct ServerSettings
{
	var string ServerName;
	var string Players;
	var string MapName;
	var int Ping;
};

var string KeyBindCommands[18];

function Init(optional LocalPlayer player)
{
	super.Init(player);
	Start();
	Advance(0);

	//SetAlignment(Align_TopLeft);
	SetViewScaleMode(SM_ExactFit);

	AddFocusIgnoreKey('Escape');
	AddFocusIgnoreKey('Tab');

	// Store a reference to the Online SubSystem
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();

	if(OnlineSub == none)
	{
		`warn("Online sub is NONE -- Init() in HLW_MainMenu");
		return;
	}

	// Get a reference to the game interface from the online sub
	GameInterface = OnlineSub.GameInterface;

	if(GameInterface == none)
	{
		`warn("GameInterface is NONE -- Init() in HLW_MainMenu");
	}

	MenuLoaded();

	SetAllAudioGroupVolumes();

	SetUpKeyBindArray();
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case ('sMaster'):
			MasterVolumeSlider = GFxClikWidget(Widget);
			MasterVolumeSlider.SetFloat("value", MasterVolume);
			break;
		case ('sSFX'):
			SFXVolumeSlider = GFxClikWidget(Widget);
			SFXVolumeSlider.SetFloat("value", SFXVolume);
			break;
		case ('sVoice'):
			VoiceVolumeSlider = GFxClikWidget(Widget);
			VoiceVolumeSlider.SetFloat("value", VoiceVolume);
			break;
		case ('sMusic'):
			MusicVolumeSlider = GFxClikWidget(Widget);
			MusicVolumeSlider.SetFloat("value", MusicVolume);
			break;
		case ('sFOV'):
			FOVSlider = GFxClikWidget(Widget);
			FOVSlider.AddEventListener('CLIK_valueChange', OnFOVSliderValueChange);			
			FOVSlider.SetFloat("value", FOVAngle);

			if(VideoApplyButton != none)
			{
				VideoApplyButton.SetBool("enabled", false);
			}
			break;
		case ('ddlResolution'):
			ResolutionDropDownMenu = GFxClikWidget(Widget);
			ResolutionDropDownMenu.AddEventListener('CLIK_listIndexChange', OnVideoOptionsDropDownValueChange);
			break;
		case ('ddlScreenMode'):
			ScreenModeDropDownMenu = GFxClikWidget(Widget);
			ScreenModeDropDownMenu.AddEventListener('CLIK_listIndexChange', OnVideoOptionsDropDownValueChange);
			break;
		case ('btnApply'):
			VideoApplyButton = GFxClikWidget(Widget);
			VideoApplyButton.AddEventListener('CLIK_buttonClick', OnVideoApplyClick);
			break;
		case ('sSensitivity'):
			MouseSensitivitySlider = GFxClikWidget(Widget);
			break;
		case ('cbInvertY'):
			InvertMouseCheckBox = GFxClikWidget(Widget);
			break;
		case ('keybindList'):
			KeybindScrollingList = GFxClikWidget(Widget);
			break;
	}

	return true;
}

function OnMasterVolumeValueChange(GFxClikWidget.EventData ev)
{
	SetAudioGroupVolume(ev._this.GetObject("target"), 'Master', MasterVolume);
}

function OnSFXVolumeValueChange(GFxClikWidget.EventData ev)
{
	SetAudioGroupVolume(ev._this.GetObject("target"), 'SFX', SFXVolume);
}

function OnVoiceVolumeValueChange(GFxClikWidget.EventData ev)
{
	SetAudioGroupVolume(ev._this.GetObject("target"), 'Voice', VoiceVolume);
}

function OnMusicVolumeValueChange(GFxClikWidget.EventData ev)
{
	SetAudioGroupVolume(ev._this.GetObject("target"), 'Music', MusicVolume);
}

function OnVideoOptionsDropDownValueChange(GFxClikWidget.EventData ev)
{
	bResolutionChanged = true;
	EnableApplyButton();
}

function OnFOVSliderValueChange(GFxClikWidget.EventData ev)
{
	FOVAngle = FOVSlider.GetFloat("value");

	GetPC().FOV(FOVAngle);

	bFOVChanged = true;

	EnableApplyButton();
}

function OnMouseSensitivityValueChange(GFxClikWidget.EventData ev)
{
	GetPC().PlayerInput.SetSensitivity(MouseSensitivitySlider.GetFloat("value"));
	GetPC().PlayerInput.SaveConfig();
}

function OnInvertYAxisClick(GFxClikWidget.EventData ev)
{
	GetPC().PlayerInput.InvertMouse();
}

function EnableApplyButton()
{
	if(VideoApplyButton != none)
	{
		if(!VideoApplyButton.GetBool("enabled"))
		{
			VideoApplyButton.SetBool("enabled", true);
		}
	}
}

function OnVideoApplyClick(GFxClikWidget.EventData ev)
{
	// Apply changes to vid options
	VideoApplyButton.SetBool("enabled", false);
	ApplyVideoChanges();
}

function ApplyVideoChanges()
{
	local int SelectedIndex;
	local string SelectedResoultion;
	local string SelectedScreenMode;
	local GFxObject DataProvider;
	local bool bIsFullScreen;
	local string windowMode;
	//local array<string> Resolution;

	if(bResolutionChanged)
	{
		SelectedIndex = ResolutionDropDownMenu.GetInt("selectedIndex");
		DataProvider = ResolutionDropDownMenu.GetObject("dataProvider");

		SelectedResoultion = DataProvider.GetElementString(SelectedIndex);
		SelectedIndex = ScreenModeDropDownMenu.GetInt("selectedIndex");

		DataProvider = ScreenModeDropDownMenu.GetObject("dataProvider");
		SelectedScreenMode = DataProvider.GetElementString(SelectedIndex);

		if("Fullscreen" ~= SelectedScreenMode)
		{
			windowMode = "f";
			bIsFullScreen = true;
		}
		else
		{
			windowMode = "w";
			bIsFullScreen = false;
		}

		

		GetPC().ConsoleCommand("Setres " $SelectedResoultion $windowMode);

		//Resolution = SplitString(SelectedResoultion, "x", true);
		//SetViewport(0, 0, int(Resolution[0]), int(Resolution[1]));

		//Close(false);
		//Start(false);

		GetPC().ConsoleCommand("Scale set Fullscreen " $bIsFullScreen);

		bResolutionChanged = false;
	}

	if(bFOVChanged)
	{
		SaveConfig();
		bFOVChanged = false;
	}
}

function OnAsOptionsMenuGoBack()
{
	SaveConfig();
}

function SetAllAudioGroupVolumes()
{
	GetPC().SetAudioGroupVolume('Master', MasterVolume * 0.01f);
	GetPC().SetAudioGroupVolume('SFX', SFXVolume * 0.01f);
	GetPC().SetAudioGroupVolume('Voice', VoiceVolume * 0.01f);
	GetPC().SetAudioGroupVolume('Music', MusicVolume * 0.01f);
}

function SetAudioGroupVolume(GFxObject slider, name GroupName, out float ConfigVar)
{
	local float volumeVal;

	ConfigVar = slider.GetFloat("value");

	volumeVal = ConfigVar * 0.01f;
	
	GetPC().SetAudioGroupVolume(GroupName, volumeVal);
}

function LoadTutorialLevel()
{
	GetPC().ConsoleCommand("open HLW_TutorialMap");
}

/**
 * Searches for Online games.
 */
function SearchOnlineGames()
{
	SearchSetting = new class'HLW.HLW_OnlineGameSearch';
	SearchSetting.bIsLanQuery = false;
	SearchSetting.MaxSearchResults = 50;

	// Cancel any searches that could already be running
	GameInterface.CancelFindOnlineGames();
	GameInterface.AddFindOnlineGamesCompleteDelegate(OnServerQueryComplete);
	
	if(!GameInterface.FindOnlineGames(0, SearchSetting))
	{
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnServerQueryComplete);
		`warn("MainMenu::SearchOnlineGames - There was an error finding games - Clearing delegate ");
	}
}

/**
 * Delegate that gets called when the server search is finished
 */
function OnServerQueryComplete(bool bWasSuccessful)
{
	local int i;
	local HLW_GameSettings gameSettings;
	local GFxObject DataProvider;
	local GFxObject RootMC;
	local GFxObject TempObj;

	RootMC = GetVariableObject("root.serverBrowser");

	DataProvider = CreateArray();
	
	if(bWasSuccessful && SearchSetting.Results.Length > 0)
	{
		//`log("MainMenu::OnServerQueryComplete - Query was successful");
		for(i=0; i < SearchSetting.Results.Length; i++)
		{
			gameSettings = HLW_GameSettings(SearchSetting.Results[i].GameSettings);

			TempObj = CreateObject("Object");
			TempObj.SetString("ServerName", gameSettings.getServerName());
			TempObj.SetString("MapName", gameSettings.getMapName());
			TempObj.SetString("Ping", string(gameSettings.PingInMs));
			TempObj.SetString("Players", string(gameSettings.NumPublicConnections - gameSettings.NumOpenPublicConnections) $"/" $string(gameSettings.NumPublicConnections));
			DataProvider.SetElementObject(i, TempObj);

			// Here is where we would get the settings from the server returned.
			//`log("MainMenu::OnServerQueryComplete Server Name " $gameSettings.getServerName() $" The index of the server is " $i $" The servers ping is " $gameSettings.PingInMs);
		}

		RootMC.SetObject("unrealServerList", DataProvider);
		UpdateServerList();
	}
	else
	{
		// Clear the delegate so it doesn't get called again
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnServerQueryComplete);
		//`log("MainMenu::OnServerQueryComplete - No results found! " $SearchSetting.Results.Length);
	}

	if (!SearchSetting.bIsSearchInProgress) // make sure we've searched for atleast 10 seconds
	{
		// No more searching clear out the delegates
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnServerQueryComplete);
	}
}

function MenuLoaded()
{
	ActionScriptVoid("root.UnrealTweenInMainMenu");
}


function OnAsCreateButtonClick()
{
	//`log("Create Clicked");
	//HLW_PlayerReplicationInfo(HLW_PlayerController(GetPC()).PlayerReplicationInfo).classSelection = 1;
	//ConsoleCommand("open HLW_Map?Listen=true?name=Listen Server");
	//HLW_GameType(HLW_PlayerController(GetPC()).WorldInfo.Game).CreateOnlineGame();
}

function OnAsServerBrowserLoaded()
{
	SearchOnlineGames();
}

function OnAsLanJoinGameButtonClick(string serverIp, string playerName)
{
	local string unrealPlayerName;

	unrealPlayerName = playerName != "" ? playerName : "Client" $HLW_PlayerController(GetPC()).PlayerReplicationInfo.PlayerID;

	HLW_PlayerController(GetPC()).ClientTravel(serverIp$"?name="$unrealPlayerName, TRAVEL_Absolute);
}

function OnAsQuitButtonClick()
{
	HLW_PlayerController(GetPC()).QuitGame();
}

function OnAsRefreshButtonClick()
{
	SearchOnlineGames();
}

function OnAsServerJoinButtonClick(int listItemIndex)
{
	// Set a delegate for join notification
	GameInterface.AddJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
	GameInterface.JoinOnlineGame(0, 'Game', SearchSetting.Results[listItemIndex]);
}

function UpdateServerList()
{
	ActionScriptVoid("root.UnrealUpdateServerList");
}

function OnAsOptionsLoaded()
{
	SetUpAsVideoOptions();
}

function SetUpAsVideoOptions()
{
	local int ResX;
	local int ResY;
	local string currentResolutionString;
	local string tempResolutionString;

	local GFxObject DataProvider;
	local string Resolutions;
	local array<string> ResolutionsArray;
	local int i;

	DataProvider = CreateObject("scaleform.clik.data.DataProvider");

	Resolutions = GetPC().ConsoleCommand("DUMPAVAILABLERESOLUTIONS", false);

	ParseStringIntoArray(Resolutions, ResolutionsArray, "\n", true);
	
	for(i = ResolutionsArray.Length - 1; i >= 0; i--)
	{
		if(i > 0 && ResolutionsArray[i] == ResolutionsArray[i - 1])
		{
			ResolutionsArray.Remove(i, 1);
		}
	}

	for(i = 0; i < ResolutionsArray.Length; i++)
	{
		DataProvider.SetElementString(i, ResolutionsArray[i]);
	}

	ResolutionDropDownMenu.SetObject("dataProvider", DataProvider);

	DataProvider = ResolutionDropDownMenu.GetObject("dataProvider");

	ResX = class'Engine'.static.GetEngine().GetSystemSettingInt("ResX");
	ResY = class'Engine'.static.GetEngine().GetSystemSettingInt("ResY");

	currentResolutionString = ResX $"x" $ResY;

	for(i = 0; i < ResolutionsArray.Length; i++)
	{
		tempResolutionString = DataProvider.GetElementString(i);
		if(currentResolutionString == tempResolutionString)
		{
			ResolutionDropDownMenu.SetInt("selectedIndex", i);
		}
	}

	DataProvider = CreateObject("scaleform.clik.data.DataProvider");

	DataProvider.SetElementString(0, "Fullscreen");
	DataProvider.SetElementString(1, "Window");

	ScreenModeDropDownMenu.SetObject("dataProvider", DataProvider);

	if(LocalPlayer(GetPC().Player).ViewportClient.IsFullScreenViewport())
	{
		ScreenModeDropDownMenu.SetInt("selectedIndex", 0);
	}
	else
	{
		ScreenModeDropDownMenu.SetInt("selectedIndex", 1);
	}
}

function SetUpAsAudioOptions()
{
	MasterVolumeSlider.AddEventListener('CLIK_valueChange', OnMasterVolumeValueChange);
	MasterVolumeSlider.SetFloat("value", MasterVolume);

	SFXVolumeSlider.AddEventListener('CLIK_valueChange', OnSFXVolumeValueChange);
	SFXVolumeSlider.SetFloat("value", SFXVolume);

	VoiceVolumeSlider.AddEventListener('CLIK_valueChange', OnVoiceVolumeValueChange);
	VoiceVolumeSlider.SetFloat("value", VoiceVolume);

	MusicVolumeSlider.AddEventListener('CLIK_valueChange', OnMusicVolumeValueChange);
	MusicVolumeSlider.SetFloat("value", MusicVolume);
}

function SetUpAsControlOptions()
{
	MouseSensitivitySlider.AddEventListener('CLIK_valueChange', OnMouseSensitivityValueChange);
	MouseSensitivitySlider.SetFloat("value", GetPC().PlayerInput.MouseSensitivity);

	InvertMouseCheckBox.AddEventListener('CLIK_buttonClick', OnInvertYAxisClick);
	InvertMouseCheckBox.SetBool("selected", GetPC().PlayerInput.bInvertMouse);
}

//function SetUpAsKeybindOptions()
//{
//	local GFxObject DataProvider;
//	local GFxObject TempObj;
//	local KeyBind TempKeyBind;
//	local string Command;
//	local array<KeyBind> CurrentBindings;
//	local int i;

//	CurrentBindings = GetPC().PlayerInput.Bindings;

//	DataProvider = CreateObject("scaleform.clik.data.DataProvider");

//	for(i = 0; i < 18; i++)
//	{
//		TempObj = CreateObject("Object");
//		Command = KeyBindCommands[i];
//		TempKeyBind = CurrentBindings.Find();

//		TempObj.SetString("Command", KeyBindCommands[1]);
//		TempObj.SetString("Name", TempKeyBind.Name);
//		DataProvider.SetElement(i, TempObj);
//	}

//	KeybindScrollingList.SetObject("dataProvider", DataProvider);
//}

function SetUpKeyBindArray()
{
	/** Movement **/
	KeyBindCommands[0] = "MoveForward";
	KeyBindCommands[1] = "MoveBackward";
	KeyBindCommands[2] = "StrafeLeft";
	KeyBindCommands[3] = "StrafeRight";

	/** Abilities **/
	KeyBindCommands[4] = "GBA_UpgradeAbility1";
	KeyBindCommands[5] = "GBA_UpgradeAbility2";
	KeyBindCommands[6] = "GBA_UpgradeAbility3";
	KeyBindCommands[7] = "GBA_UpgradeAbility4";

	KeyBindCommands[8] = "GBA_Ability1";
	KeyBindCommands[9] = "GBA_Ability2";
	KeyBindCommands[10] = "GBA_Ability3";
	KeyBindCommands[11] = "GBA_Ability4";

	/** Camera **/
	KeyBindCommands[12] = "GBA_SwitchCam";

	/** Weapon **/
	KeyBindCommands[13] = "GBA_PrevWeapon";
	KeyBindCommands[14] = "GBA_NextWeapon";

	/** Controls **/
	KeyBindCommands[15] = "GBA_Fire";
	KeyBindCommands[16] = "GBA_AltFire";
	KeyBindCommands[17] = "GBA_Jump";
}

function AsSetSelectedItem(GFxObject obj, GFxObject RootObj)
{
	RootObj.ActionScriptVoid("SetSelectedItem");
}

/**
 * Delegate that gets called when join game completes
 */

private function OnJoinGameComplete(name SessionName, bool bSuccessful)
{
	local HLW_GameSettings GameSettings;
	local string TravelURL;
	local Engine Eng;
	local PlayerController PC;

	if(bSuccessful == false)
	{
		//`log("MainMenu::OnJoinGameComplete - Join game failed!!");
		return;
	}

	GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);

	Eng = class'Engine'.static.GetEngine();
	PC = Eng.GamePlayers[0].Actor;

	class'GameEngine'.static.GetOnlineSubsystem().GameInterface.GetResolvedConnectString('Game', TravelURL);

	GameSettings = HLW_GameSettings(OnlineGameInterfaceImpl(class'GameEngine'.static.GetOnlineSubsystem().GameInterface).GameSettings);

	if(GameSettings != none && GameSettings.SteamServerId != "")
	{
		PC.ConsoleCommand("open " $ "steam." $ GameSettings.SteamServerId);
	}
	else
	{
		PC.ConsoleCommand("open "@TravelURL);
	}
}

DefaultProperties
{
	MovieInfo=SwfMovie'HLW_Package_Paul.MainMenu.MainMenu'

	WidgetBindings.Add((WidgetName=sMaster, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=sSFX, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=sVoice, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=sMusic, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=ddlResolution, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=ddlScreenMode, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=btnApply, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=sSensitivity, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=cbInvertY, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=sFOV, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=keybindList, WidgetClass=class'GFxClikWidget'))

	bAllowFocus=true
	bAllowInput=true
	bShowHardwareMouseCursor=true
	bCaptureInput=true
	bCaptureMouseInput=true
	//bForceFullViewport=false
}
