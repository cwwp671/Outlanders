class HLW_Camera extends Camera
	config(UI);

var config float FOVAngle;

//Static Variables
var float Dist;
var float TargetFOV;
var float TargetZ;
var float Z;
var float TargetOffset;
var float Offset;
var float pival;
var rotator Rot;

const AspectRatio16x10 = 1.6;

function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	//Local Variables
	local vector            Loc, Pos, HitLocation, HitNormal;
	local Actor             HitActor;
	local CameraActor       CamActor;
	local bool              bDoNotApplyModifiers;
	//local TPOV              OrigPOV;

	//Previous POV
	//OrigPOV = OutVT.POV;

	// Default FOV on ViewTarget
	if(FOVAngle == 0.0)
	{
		OutVT.POV.FOV = DefaultFOV;
	}
	else
	{
		OutVT.POV.FOV = FOVAngle;
	}

	// Viewing through a CameraActor
	CamActor = CameraActor(OutVT.Target);
	
	if( CamActor != None )
	{
		CamActor.GetCameraView(DeltaTime, OutVT.POV);

		// Grab aspect ratio from the CameraActor.
		bConstrainAspectRatio = bConstrainAspectRatio || CamActor.bConstrainAspectRatio;
		OutVT.AspectRatio = CamActor.AspectRatio;

		// See if the CameraActor wants to override the PostProcess settings used.
		CamOverridePostProcessAlpha = CamActor.CamOverridePostProcessAlpha;
		CamPostProcessSettings = CamActor.CamOverridePostProcess;
	}
	else
	{
		// Give Pawn Viewtarget a chance to dictate the camera position.
		// If Pawn doesn't override the camera view, then we proceed with our own defaults
		if( Pawn(OutVT.Target) == None || !Pawn(OutVT.Target).CalcCamera(DeltaTime, OutVT.POV.Location, OutVT.POV.Rotation, OutVT.POV.FOV) )
		{
			// don't apply modifiers when using these debug camera modes. 
			bDoNotApplyModifiers = TRUE;

			switch(CameraStyle)
			{
				//case 'Fixed' : // No update, keeps previous view
					//OutVT.POV = OrigPOV;
				//break;

				case 'ThirdPerson' : //Enters here as long as CameraStyle is still set to ThirdPerson
				case 'FreeCam' :
				case 'ShoulderCam' : // Over the shoulder view
					Loc = OutVT.Target.Location; // Setting the camera location and rotation to the viewtarget's

					if (CameraStyle == 'ThirdPerson')
					{
						FreeCamDistance = 256;
						TargetZ = 50;
						TargetFOV = DefaultFOV;
						TargetOffset = 0;
						Rot = PCOwner.Rotation;
					}

					if (CameraStyle == 'ShoulderCam')
					{
						Rot = PCOwner.Rotation;
						FreeCamDistance = 64;
						TargetFOV = 60.f;
						TargetZ = 32;
						TargetOffset = 32;
					}

					//OutVT.Target.GetActorEyesViewPoint(Loc, Rot);

					if(CameraStyle == 'FreeCam')
					{
						Rot = PCOwner.Rotation;
					}

					Loc += FreeCamOffset >> Rot;
					Loc.Z += Z; // Setting the Z coordinate offset for shoulder view

					//Linear interpolation algorithm. This is the "smoothing," so the camera doesn't jump between zoom levels
					if (Dist != FreeCamDistance)
					{
						Dist = Lerp(Dist,FreeCamDistance,0.15); //Increment Dist towards FreeCamDistance, which is where you want your camera to be. Increments a percentage of the distance between them according to the third term, in this case, 0.15 or 15%
					}
					if (Z != TargetZ)
					{
						Z = Lerp(Z,TargetZ,0.1);
					}
					if (DefaultFOV != TargetFOV)
					{
						DefaultFOV = Lerp(DefaultFOV,TargetFOV,0.1);
					}
					if (Offset != TargetOffset)
					{
						Offset = Lerp(Offset,TargetOffset,0.1);
					}

					Pos = Loc - Vector(Rot) * Dist; /*Instead of using FreeCamDistance here, which would cause the camera to jump by the entire increment, we use Dist, which increments in small steps to the desired value of FreeCamDistance using the Lerp function above*/
					// Setting the XY camera offset for shoulder view
					Pos.X += Offset*sin(-Rot.Yaw*pival*2/65536);
					Pos.Y += Offset*cos(Rot.Yaw*pival*2/65536);
					// @fixme, respect BlockingVolume.bBlockCamera=false

					//This determines if the camera will pass through a mesh by tracing a path to the view target.
					HitActor = Trace(HitLocation, HitNormal, Pos, Loc, FALSE, vect(12,12,12));
					//This is where the location and rotation of the camera are actually set
					OutVT.POV.Location = (HitActor == None) ? Pos : HitLocation;
					OutVT.POV.Rotation = Rot;
				break; //This is where our code leaves the switch-case statement, preventing it from executing the commands intended for the FirstPerson case.

				case 'FirstPerson' : // Simple first person, view through viewtarget's 'eyes'
				Dist = 0;
				default : OutVT.Target.GetActorEyesViewPoint(OutVT.POV.Location, OutVT.POV.Rotation);
				break;
			}
		}
	}

	if( !bDoNotApplyModifiers )
	{
		// Apply camera modifiers at the end (view shakes for example)
		ApplyCameraModifiers(DeltaTime, OutVT.POV);
	}
	//`log( WorldInfo.TimeSeconds  @ GetFuncName() @ OutVT.Target @ OutVT.POV.Location @ OutVT.POV.Rotation @ OutVT.POV.FOV );
}

function SetDesiredRotation(rotator rotIN)
{
	Rot = rotIN; 
}

defaultproperties
{
	DefaultAspectRatio=AspectRatio16x10
	FreeCamDistance = 512.f
	pival = 3.14159;
	DefaultFOV=120.f
}
