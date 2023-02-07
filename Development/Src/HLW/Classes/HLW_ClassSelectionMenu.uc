class HLW_ClassSelectionMenu extends GFxMoviePlayer;

var GFxClikWidget NumBluePlayersTextBox, NumYellowPlayersTextBox, JoinButton, SpectateCheckBox;

var bool bCalledFromSpectatorMode;

function Init(optional LocalPlayer player)
{
	super.Init(player);
	Start();
	Advance(0);

	AddFocusIgnoreKey('Escape');
	AddFocusIgnoreKey('Tab');
	AddFocusIgnoreKey('M');

	GetPC().PlayerInput.ResetInput();
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case ('txtNumBluePlayers'):
			NumBluePlayersTextBox = GFxClikWidget(Widget);
			break;
		case ('txtNumYellowPlayers'):
			NumYellowPlayersTextBox = GFxClikWidget(Widget);
			break;
		case ('btnJoinGame'):
			JoinButton = GFxClikWidget(Widget);
			break;
		case ('cbSpectate'):
			SpectateCheckBox = GFxClikWidget(Widget);
			break;
	}

	return true;
}

function SetClass(int classNumber, int teamIndex, bool bIsSpectator)
{
	HLW_PlayerController(GetPC()).SetPawnType(classNumber, teamIndex, bIsSpectator, bCalledFromSpectatorMode);

	GetPC().PlayerInput.ResetInput();
	HLW_PlayerController(GetPC()).ClearUpdateClassSelectionPlayerNumbersTimer();

	ClearCaptureKeys();
	Close(false);
}

simulated function OpenMenu()
{
	Start();
	Advance(0);

	JoinButton.SetString("label", "Switch Class");

	AddFocusIgnoreKey('Escape');
	AddFocusIgnoreKey('Tab');
	AddFocusIgnoreKey('M');

	GetPC().PlayerInput.ResetInput();
}

function OnClose()
{
	HLW_PlayerController(GetPC()).ClearUpdateClassSelectionPlayerNumbersTimer();

	bCalledFromSpectatorMode = false;

	super.OnClose();
}

simulated function UpdatePlayerNumbers(int bluePlayers, int yellowPlayers)
{
	if(NumBluePlayersTextBox != none && NumYellowPlayersTextBox != none)
	{
		NumBluePlayersTextBox.SetString("text", string(bluePlayers));
		NumYellowPlayersTextBox.SetString("text", string(yellowPlayers));	
	}
}

function UnrealInit(bool isTeam)
{
	ActionScriptVoid("root.UnrealInit");
}

DefaultProperties
{
	MovieInfo=SwfMovie'HLW_Package_Paul.SelectionMenu.SelectionScreen'

	WidgetBindings.Add((WidgetName=txtNumBluePlayers, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=txtNumYellowPlayers, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=btnJoinGame, WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName=cbSpectate, WidgetClass=class'GFxClikWidget'))
	

	bAllowFocus=true
	bAllowInput=true
	bShowHardwareMouseCursor=true
	bCaptureInput=true
	bCaptureMouseInput=true
}
