class HLW_GameSettings extends UDKGameSettingsCommon;
`include(HLW_OnlineConstants.uci)

// The unique id of the steam game server, for use with steam sockets
var databinding string SteamServerId;

/**
 * Builds a URL string out of the properties/contexts and databindings of this object
 */
function BuildURL(out string OutURL)
{
	local int SettingIdx;
	local name PropertyName;

	OutURL = "";

	// Append properties marked with the databinding keyword to the URL
	AppendDataBindingsToURL(OutURL);

	// add all properties
	for(SettingIdx = 0; SettingIdx < Properties.Length; SettingIdx++)
	{
		PropertyName = GetPropertyName(Properties[SettingIdx].PropertyId);
		if(PropertyName != '')
		{
			switch(Properties[SettingIdx].PropertyId)
			{
			default: 
				OutURL $= "?" $ PropertyName $ "=" $GetPropertyAsString(Properties[SettingIdx].PropertyId);
				break;
			}
		}
	}
}

function setServerName(string serverName)
{
	SetStringProperty(PROPERTY_HLW_SERVERNAME, serverName);
}

function setMapName(string mapName)
{
	SetStringProperty(PROPERTY_HLW_MAPNAME, mapName);
}

function string getServerName()
{
	return GetPropertyAsString(PROPERTY_HLW_SERVERNAME);
}

function string getMapName()
{
	return GetPropertyAsString(PROPERTY_HLW_MAPNAME);
}

DefaultProperties
{
	// Property mappings
	Properties(0)=(PropertyId=PROPERTY_HLW_SERVERNAME,Data=(Type=SDT_String),AdvertisementType=ODAT_OnlineService)
	PropertyMappings(0)=(Id=PROPERTY_HLW_SERVERNAME,Name="HLW Server")

	Properties(1)=(PropertyId=PROPERTY_HLW_MAPNAME,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(1)=(Id=PROPERTY_HLW_MAPNAME,Name="HLW_MapName")
}
