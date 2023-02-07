class HLW_TeamInfo extends TeamInfo;

var repnotify Color HLW_TeamColor;
var string Faction;
var int SurrenderCounter;
var int NumPlayers;

replication
	{
		if(bNetInitial)
			HLW_TeamColor;
		if(bNetDirty)
			SurrenderCounter, NumPlayers;
	}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'TeamIndex')
	{
		if (WorldInfo.GRI != None)
		{
			// register this TeamInfo instance now
			WorldInfo.GRI.SetTeam(TeamIndex, self);
		}
	}
	else if(VarName == 'HLW_TeamColor')
	{
		TeamColor = HLW_TeamColor;
	}
	else
	{ 
		Super.ReplicatedEvent(VarName);
	}
}

function bool AddToTeam(Controller Other)
{
	NumPlayers++;

	return super.AddToTeam(Other);
}

simulated function AddSurrenderVote(HLW_PlayerController HLW_PC)
{
	SurrenderCounter++;
	HLW_PC.IncrementSurrenderCounter(1);
	HLW_PC.bHasVotedSurrender = true;
	
	if(SurrenderCounter > (NumPlayers * 0.5))
	{
		ClearTimer('SurrenderFailed');
		HLW_PC.CloseEscapeMenu();
		HLW_PC.ServerEndGame();
		return ;
	}
	else
	{

		HLW_PC.SendTextToServer(HLW_PC.PlayerReplicationInfo.PlayerName $" has voted to surrender.", true, true);
		SetTimer(10.0f, false, 'SurrenderFailed');
	}
}

simulated function SurrenderFailed()
{
	local HLW_PlayerController HLW_PC;

	foreach DynamicActors(class'HLW.HLW_PlayerController', HLW_PC)
	{
		if(HLW_PC.PlayerReplicationInfo != none && HLW_PC.PlayerReplicationInfo.Team != none)
		{
			if(HLW_PC.PlayerReplicationInfo.Team.TeamIndex == TeamIndex)
			{
				HLW_PC.bHasVotedSurrender = false;

				if(SurrenderCounter != 0)
				{
					SurrenderCounter = 0;
					HLW_PC.IncrementSurrenderCounter(0);
					HLW_PC.SendTextToServer("Vote for surrender has failed.", false, true);

				}
			}
		}
	}
}

function string GetFaction()
{
	return Faction;
}

DefaultProperties
{
}
