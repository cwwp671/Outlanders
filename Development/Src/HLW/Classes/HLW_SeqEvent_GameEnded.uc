/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_SeqEvent_GameEnded extends SequenceEvent;

/** The winner of the game. In Deathmatch, the player with the final kill; in other gametypes, the home base of the winning team */
var Actor Winner;
/** the "real" winner of the game - the actual player that won in FFA games or the TeamInfo of the team that won in a team game
 * yes, this variable name is bad - that's what happens when you have to fix up bad design afterwards ;)
 */
var Actor ActualWinner;

event Activated()
{
	local HLW_GameType Game;

	Game = HLW_GameType(GetWorldInfo().Game);

	if (Game != None)
	{
		Winner = Game.EndGameFocus;
		ActualWinner = Game.GameReplicationInfo.Winner;
		if (PlayerReplicationInfo(ActualWinner) != None)
		{
			// controllers are better for Kismet handling
			ActualWinner = Controller(ActualWinner.Owner);
		}
	}
}

defaultproperties
{
	ObjName="HLW Game Ended"
	bPlayerOnly=false
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Focus Actor",bWriteable=true,PropertyName=Winner)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Winning Player/Team",bWriteable=true,PropertyName=ActualWinner)
}
