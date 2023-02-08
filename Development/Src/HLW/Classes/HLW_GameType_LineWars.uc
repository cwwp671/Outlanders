/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */

class HLW_GameType_LineWars extends HLW_GameType;

var HLW_TeamInfo Teams[2];
var string TeamFactions[2];
var int TotalPlayers;

event InitGame(string Options, out string ErrorMessage)
{
	TeamFactions[0] = "Blue Team";
	TeamFactions[1] = "Yellow Team";

	super.InitGame(Options, ErrorMessage);
}

function PreBeginPlay()
{
	super.PreBeginPlay();

	CreateTeam(0, MakeColor(0, 101, 255));
	CreateTeam(1, MakeColor(243, 223, 0));
}

function CreateTeam(int index, Color teamColor)
{
	Teams[index] = Spawn(class'HLW_TeamInfo');
	Teams[index].TeamIndex = index;
	Teams[index].TeamColor = teamColor;
	Teams[index].Faction = TeamFactions[index];

	WorldInfo.GRI.SetTeam(index, Teams[index]);
}

function LogOut(Controller Exiting)
{
	local int exitingTeamIndex;
	local PlayerReplicationInfo HighScorer;
	local int otherTeamIndex;
	local int i;

	// Make sure match is in progress and there are players on the server
	if(HLW_GameReplicationInfo(WorldInfo.GRI).bMatchInProgress && NumPlayers > 0 && Exiting.PlayerReplicationInfo.Team != none)
	{
		exitingTeamIndex = Exiting.PlayerReplicationInfo.Team.TeamIndex;

		// Remove from team isn't called until the controller is destroyed, do it now so we can know if a team is empty
		WorldInfo.GRI.Teams[exitingTeamIndex].RemoveFromTeam(Exiting);

		if(WorldInfo.GRI.Teams[exitingTeamIndex].Size == 0)
		{
			// Find the high scorer of the other team
			// We only have two teams so do a check for index being 0
			if(exitingTeamIndex == 0)
			{
				otherTeamIndex = 1;
			}
			else
			{
				otherTeamIndex = 0;
			}

			for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
			{
				if(HighScorer == none && WorldInfo.GRI.PRIArray[i].Team != none && WorldInfo.GRI.PRIArray[i].Team.TeamIndex == otherTeamIndex)
				{
					HighScorer = WorldInfo.GRI.PRIArray[i];
				}
				else
				{
					if(WorldInfo.GRI.PRIArray[i].Team != none && WorldInfo.GRI.PRIArray[i].Team.TeamIndex == otherTeamIndex 
						&& HLW_PlayerReplicationInfo(WorldInfo.GRI.PRIArray[i]).HLW_Kills > HLW_PlayerReplicationInfo(HighScorer).HLW_Kills)
					{
						HighScorer = WorldInfo.GRI.PRIArray[i];
					}
				}
			}

			EndGame(HighScorer, "triggered");
		}
	}

	super.Logout(Exiting);
}

/** ChoosePlayerStart()
 *  Modified ChoosePlayerStart to use one of our custom player starts at random that is enabled
 *  
* Return the 'best' player start for this player to start from.  PlayerStarts are rated by RatePlayerStart().
* @param Player is the controller for whom we are choosing a playerstart
* @param InTeam specifies the Player's team (if the player hasn't joined a team yet)
* @returns NavigationPoint chosen as player start (usually a PlayerStart)
 */
function PlayerStart ChoosePlayerStart( Controller Player, optional byte InTeam )
{
	local HLW_PlayerStart P;
	local byte TeamIndex;
	local float randomIndex;
	local array<HLW_PlayerStart> EnabledPlayerStarts;

	// use InTeam if player doesn't have a team yet
	TeamIndex = ( (Player != None) && (Player.PlayerReplicationInfo != None) && (Player.PlayerReplicationInfo.Team != None) )
			? byte(Player.PlayerReplicationInfo.Team.TeamIndex)
			: InTeam;

	// Loop through all the HLW_PlayerStarts that are on the map
	foreach WorldInfo.AllNavigationPoints(class'HLW_PlayerStart', P)
	{
		// Make sure the player start is enabled. If the player start is disabled RatePlayerStart will return 5.0f
		if(P.TeamIndex == TeamIndex)
		{
			if(P.bEnabled)
			{
				// Add the player start to the local array
				EnabledPlayerStarts.AddItem(P);
			}
		}
	}

	// If we didn't find an HLW_Player start to use foward up to the super to find one.
	if (EnabledPlayerStarts.Length <= 0)
	{
		return super.ChoosePlayerStart(Player, InTeam);
	}

	// Get a random index
	randomIndex = RandRange(0, EnabledPlayerStarts.Length);

	// Return the player start at the random index
	return EnabledPlayerStarts[int(randomIndex)];
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

function ScoreKill(Controller Killer, Controller Other)
{
	if(Other.Pawn != none && Other.Pawn.IsA('HLW_Base_Center'))
	{
		Killer.PlayerReplicationInfo.Team.Score += 1;
	}

	super.ScoreKill(Killer, Other);
}

function bool CheckScore(PlayerReplicationInfo Scorer)
{
	if(Scorer.Team != none && Scorer.Team.Score >= GoalScore)
	{
		super.PreEndGame(Scorer, "teamscorelimit");
		return true;
	}

	return false;
}

function ShowEndGameScreen()
{
	local HLW_PlayerController HLW_PC;

	foreach WorldInfo.AllControllers(class'HLW_PlayerController', HLW_PC)
	{
		if(HLW_PC != none)
		{
			`log("LineWars::ShowEndGameScreen - Calling the ShowEndGameScreen function for " $HLW_PC);
			HLW_PC.ShowEndGameScreen();
		}
	}
}

auto state PendingMatch
{
	function CheckMatchStart()
	{
		local int i;
		local HLW_PlayerReplicationInfo PRI;

		if(GameReplicationInfo == none || GameReplicationInfo.PRIArray.Length < TotalPlayers)
		{
			return;
		}

		for(i = 0; i < GameReplicationInfo.PRIArray.Length; ++i)
		{
			PRI = HLW_PlayerReplicationInfo(GameReplicationInfo.PRIArray[i]);
			if(PRI != none)
			{
				if(PRI.Team == none || PRI.classSelection == 0)
				{
					return;
				}
			}
		}


		for(i = 0; i < WorldInfo.GRI.Teams.Length; i++)
		{
			if(WorldInfo.GRI.Teams[i].Size == 0)
			{
				return;
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
	TotalPlayers=2
	bDelayedStart=true
	bTeamGame=true
	bRestartLevel=false
}
