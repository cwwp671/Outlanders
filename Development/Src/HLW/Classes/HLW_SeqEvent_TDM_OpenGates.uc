class HLW_SeqEvent_TDM_OpenGates extends SequenceEvent;

event Activated()
{
	
}

DefaultProperties
{
	MaxTriggerCount=0
	ObjName="HLW TDM Open Gates"
	ObjCategory="Physics"
	// Set when activated through code.
	OutputLinks(0)=(LinkDesc="Activated")
	OutputLinks(1)=(LinkDesc="Open Finished")
	bPlayerOnly=false
	VariableLinks.Empty()
}
