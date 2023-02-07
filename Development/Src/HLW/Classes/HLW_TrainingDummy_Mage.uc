class HLW_TrainingDummy_Mage extends HLW_TrainingDummy
ClassGroup(HeroLineWars)
placeable;

defaultproperties
{
	Health=225
	HealthMax=225
	
	VoiceCueDied=SoundCue'HLW_Package_Voices.Mage.Died'
	VoiceCueHurt=SoundCue'HLW_Package_Voices.Mage.Hurt'
	
	Begin Object Name=DummyMesh
        bHasPhysicsAssetInstance=true
        PhysicsAsset=PhysicsAsset'HLW_CONNOR_PAKAGE.Physics.3p_Mage_Base_Temp_Skele_Physics'
		AnimSets(0)=AnimSet'HLW_Package.Animations.3p_Mage_Animset'
		AnimTreeTemplate=AnimTree'HLW_Package.Animations.3p_Mage_Animtree'
		SkeletalMesh=SkeletalMesh'HLW_Package.models.Mage_Textured_SkeletalMesh'
    End Object
}