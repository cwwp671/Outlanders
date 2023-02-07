class HLW_Projectile_InitialVolley extends HLW_Projectile_Volley;

simulated function PostBeginPlay()
{
	SetTimer(1.0f, false, 'Destroy');	
}

defaultproperties
{
}