/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_HUD_ChatWindow extends GFxMoviePlayer;

var bool bChatting;

function Init(optional LocalPlayer player)
{
	super.Init();
	Start();
	Advance(0);
	SetPause(false);

	AddFocusIgnoreKey('Escape');
	AddFocusIgnoreKey('Enter');
	AddFocusIgnoreKey('Tab');
	AddFocusIgnoreKey('T');
	AddFocusIgnoreKey('Y');
}

simulated function OpenWindow()
{
	if(!bMovieIsOpen)
	{
		Start();
		SetViewScaleMode(SM_ExactFit);
		//Advance(0);
		SetPause(false);
	}
}

function CloseWindow()
{
	SetPause(true);
	Close(false);
}

//function ToggleCursor(bool showCursor)
//{
//	if(showCursor)
//	{
//		bShowHardwareMouseCursor = true;
//	}
//	else
//	{
//		bShowHardwareMouseCursor = false;
//	}

//	if(!bChatting)
//	{
//		bCaptureInput = showCursor;
//		bIgnoreMouseInput = !showCursor;
//	}
//	else
//	{
//		bCaptureInput = true;
//		bIgnoreMouseInput = false;
//	}
//}

function DisplayCaptureInput()
{
	//`log("Capture input setting for this chat window : " $bCaptureInput);
}

function OnChatInputClick(int chatType)
{
	ClearCaptureKeys();
	AddCaptureKey('T');
	AddCaptureKey('Y');
	bChatting = true;

	SetTextInputFocus(chatType);
}

function string GetTextFromAs()
{
	return ActionScriptString("root.GetInputText");
}

function SetTextInputFocus(int colorIndex)
{
	ActionScriptVoid("root.OnUnrealEnableChat");
	bCaptureInput = true;
}

function SendMessageToAs(string message, int colorIndex)
{
	ActionScriptVoid("root.OnChatSend");
}

function OnChatSend(int chatType)
{
	local string message;
	local HLW_PlayerController HLW_PC;

	HLW_PC = HLW_PlayerController(GetPC());

	// message = Get message from AS text box
	message = GetTextFromAs();

	if(message != "")
	{
		HLW_PC.SendTextToServer(message,,,chatType);
	}

	bCaptureInput = false;
	bChatting = false;

	ClearCaptureKeys();
}

function UpdateChatLog(string message, int chatType)
{
	// Set the text in the Chat Area

	SendMessageToAs(message $"\n", chatType);
}

DefaultProperties
{
	MovieInfo=SwfMovie'HLW_Package_Paul.ChatWindow.ChatWindow'

	bIgnoreMouseInput=true
	bCaptureInput=false
	bMovieIsOpen=false

	bAllowFocus=true
	bAllowInput=true
	bOnlyOwnerFocusable=true
}
