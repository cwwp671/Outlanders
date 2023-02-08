/*
 * Author: Connor Pandolph
 * Co-Authors: Connor Hatch, Lukas Kuligowski, Paul Ouellette, Chris Logsdon
 * Game: Outlanders
 * Engine: Unreal Engine 3
 * Date: 2014
 */
 
class HLW_SeqEvent_Touch extends SequenceEvent;

event Activated()
{
}

DefaultProperties
{
	ObjName="HLW Touch"
	OutputLinks.Empty();
	OutputLinks(0)=(LinkDesc="Touch")
	OutputLinks(1)=(LinkDesc="UnTouch")
	VariableLinks.Empty()
	bAutoActivateOutputLinks=false
	bPlayerOnly=false
}
