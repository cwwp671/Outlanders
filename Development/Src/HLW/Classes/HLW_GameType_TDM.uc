/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_GameType_TDM extends HLW_GameType_LineWars;

var bool bTriggeredStartTimer;
var bool bWaitingForGates;
var int MatchStartTimer;

function ScoreKill(Controller Killer, Controller Other)
{
	if(Other != none && Other.Pawn.IsA('HLW_Pawn_Class'))
	{
		if(Killer != none)
		{
			Killer.PlayerReplicationInfo.Team.Score += 1;
		}
	}

	super.ScoreKill(Killer, Other);
}

function PreStartMatch()
{
	MatchStartTimer = 30;
	bWaitingForGates = true;
}

function OpenGates()
{
	TriggerGlobalEventClass(class'HLW.HLW_SeqEvent_TDM_OpenGates', self);

	bWaitingForGates = false;

	AllClientsSetPreMatchText("");

	super.StartMatch();
}

function TimeLimitOver()
{
	local int i;
	local TeamInfo WinningTeam;
	local PlayerReplicationInfo HighScorer;

	if(Teams[0] != none)
	{
		for (i = 0; i < 2; i++)
		{
			if(WinningTeam == none)
			{
				WinningTeam = Teams[i];
			}
			else
			{
				if(Teams[i].Score > WinningTeam.Score)
				{
					WinningTeam = Teams[i];
				}
			}
		}
	}

	for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
	{
		if(HighScorer == none && WorldInfo.GRI.PRIArray[i].Team == WinningTeam)
		{
			HighScorer = WorldInfo.GRI.PRIArray[i];
		}
		else
		{
			if(WorldInfo.GRI.PRIArray[i].Team == WinningTeam 
				&& HLW_PlayerReplicationInfo(WorldInfo.GRI.PRIArray[i]).HLW_Kills > HLW_PlayerReplicationInfo(HighScorer).HLW_Kills)
			{
				HighScorer = WorldInfo.GRI.PRIArray[i];
			}
		}
	}

	super.PreEndGame(HighScorer, "TimeLimit");
}

function AllClientsSetPreMatchText(string TextToDraw)
{
	local HLW_PlayerController HLW_PC;

	foreach WorldInfo.AllControllers(class'HLW.HLW_PlayerController', HLW_PC)
	{
		if(HLW_PC != none)
		{
			HLW_PC.SetHudPreMatchText(TextToDraw);
		}
	}
}

auto state PendingMatch
{
	function Timer()
	{
		if(NumPlayers == 0)
		{
			return;
		}

		AllClientsSetPreMatchText("Waiting for other players to join...");

		if(!bTriggeredStartTimer)
		{
			
			CheckMatchStart();
		}
	}

	function CheckMatchStart()
	{
		local int i;

		for(i = 0; i < WorldInfo.GRI.Teams.Length; i++)
		{
			if(WorldInfo.GRI.Teams[i].Size == 0)
			{
				return;
			}
		}

		GotoState('MatchInProgress');

		PreStartMatch();
		bTriggeredStartTimer = true;
	}
}

state MatchInProgress
{
	function Timer()
	{
		if(bWaitingForGates)
		{
			AllClientsSetPreMatchText("The match will start in " $MatchStartTimer);

			if(MatchStartTimer == 0)
			{
				OpenGates();
				return;
			}
			MatchStartTimer--;
		}
		
	}
}

DefaultProperties
{
	InitialUpgradePoints=3
}
