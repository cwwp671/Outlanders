/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_GameReplicationInfo extends GameReplicationInfo;

var bool bMatchInProgress;

var int MatchTimer;

replication
	{
		if(bNetDirty)
			bMatchInProgress, MatchTimer;
	}


simulated event Timer()
{
	if(bMatchInProgress)
	{
		super.Timer();
		MatchTimer++;
	}
}

DefaultProperties
{
}
