/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_OnlineGameSearch extends OnlineGameSearch;

DefaultProperties
{
	// Expose game info to the UI
	GameSettingsClass=class'HLW.HLW_GameSettings'

	Properties(0)=(PropertyId=PROPERTY_HLW_SERVERNAME,Data=(Type=SDT_String))
	PropertyMappings(0)=(Id=PROPERTY_HLW_SERVERNAME,Name="HLW Server")

	Properties(1)=(PropertyId=PROPERTY_HLW_MAPNAME,Data=(Type=SDT_String))
	PropertyMappings(1)=(Id=PROPERTY_HLW_MAPNAME,Name="HLW_MapName")
}
