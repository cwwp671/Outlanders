class HLW_Gfx_EscapeMenu extends GFxMoviePlayer;

function Init(optional LocalPlayer LocPlay)
{
	super.Init(LocPlay);

	Start();
	Advance(0);
	SetTimingMode(TM_Real);

	AddFocusIgnoreKey('Escape');
	AddFocusIgnoreKey('Tab');

	GetPC().PlayerInput.ResetInput();
}

function OnAsExitButtonClick()
{
	HLW_PlayerController(GetPC()).QuitGame();
}

function OnAsExitToMenuButtonClick()
{
	HLW_PlayerController(GetPC()).UnPossess();

	HLW_PlayerController(GetPC()).QuitToMenu();
}

function OpenMenu()
{
	Start();
	Advance(0);

	GetPC().PlayerInput.ResetInput();

	if(HLW_GameReplicationInfo(GetPC().WorldInfo.GRI).bMatchInProgress)
	{
		EnableSurrenderButton();
	}
	else
	{
		DisableSurrenderButton();
	}
}

function CloseMenu()
{
	GetPC().PlayerInput.ResetInput();
	Close(false);
}

function OnAsSurrenderButtonClick()
{
	// Check if player has already surrendered and this is a team game.
	if(!HLW_PlayerController(GetPC()).bHasVotedSurrender && GetPC().PlayerReplicationInfo.Team != none)
	{
		HLW_TeamInfo(GetPC().PlayerReplicationInfo.Team).AddSurrenderVote(HLW_PlayerController(GetPC()));
	}
	else
	{
		HLW_PlayerController(GetPC()).SendTextToServer(GetPC().PlayerReplicationInfo.PlayerName $" has tried to surrender in a Free For All. Ha Ha", false, true);
		HLW_PlayerController(GetPC()).bHasVotedSurrender = true;
	}
}

function DisableSurrenderButton()
{
	ActionScriptVoid("UnrealDisableSurrenderButton");
}

function EnableSurrenderButton()
{
	ActionScriptVoid("UnrealEnableSurrenderButton");
}

DefaultProperties
{
	MovieInfo=SwfMovie'HLW_Package_Paul.EscapeMenu.EscapeMenu'

	bAllowFocus=true
	bAllowInput=true
	bShowHardwareMouseCursor=true
	bIgnoreMouseInput=false
	bCaptureInput=true
	bCaptureMouseInput=true

	bForceFullViewport=true
}
