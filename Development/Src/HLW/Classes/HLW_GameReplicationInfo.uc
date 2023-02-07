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
