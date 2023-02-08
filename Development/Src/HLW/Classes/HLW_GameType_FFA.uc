/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */

class HLW_GameType_FFA extends HLW_GameType;

var int NumPlayersToStart;

function LogOut(Controller Exiting)
{
	super.Logout(Exiting);

	if(NumPlayers == 1)
	{
		super.PreEndGame(WorldInfo.GRI.PRIArray[0], "lastman");
	}
}

function StartHumans()
{
	local HLW_PlayerController HLW_PC;

	foreach WorldInfo.AllControllers(class'HLW_PlayerController', HLW_PC)
	{
		if(HLW_PC.Pawn == none)
		{
			if(bGameEnded)
			{
				return;
			}
			else if(HLW_PC.CanRestartPlayer())
			{
				RestartPlayer(HLW_PC);
			}
		}
	}
}

function bool CheckScore(PlayerReplicationInfo Scorer)
{
	if(HLW_PlayerReplicationInfo(Scorer).HLW_Kills >= GoalScore)
	{
		super.PreEndGame(Scorer, "FragLimit");

		return true;
	}

	return false;
}

function TimeLimitOver()
{
	local int i;
	local PlayerReplicationInfo winner;

	for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
	{
		if(winner == none)
		{
			winner = WorldInfo.GRI.PRIArray[i];
		}
		else
		{
			if(HLW_PlayerReplicationInfo(WorldInfo.GRI.PRIArray[i]).HLW_Kills > HLW_PlayerReplicationInfo(winner).HLW_Kills)
			{
				winner = WorldInfo.GRI.PRIArray[i];
			}
		}
	}

	super.PreEndGame(winner, "TimeLimit");
}

auto state PendingMatch
{
	function RestartPlayer(Controller NewPlayer)
	{
		CheckMatchStart();
	}

	function CheckMatchStart()
	{
		local int i;
		local HLW_PlayerReplicationInfo PRI;

		if(GameReplicationInfo == none || GameReplicationInfo.PRIArray.Length < NumPlayersToStart)
		{
			return;
		}

		for(i = 0; i < GameReplicationInfo.PRIArray.Length; ++i)
		{
			PRI = HLW_PlayerReplicationInfo(GameReplicationInfo.PRIArray[i]);
			if(PRI != none)
			{
				if(PRI.classSelection == 0)
				{
					return;
				}
			}
		}

		GotoState('MatchInProgress');

		StartMatch();
	}
}

state MatchInProgress
{
	function RestartPlayer(Controller NewPlayer)
	{
		super.RestartPlayer(NewPlayer);
	}
}

DefaultProperties
{
	NumPlayersToStart=1
	InitialUpgradePoints=3
}
