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
