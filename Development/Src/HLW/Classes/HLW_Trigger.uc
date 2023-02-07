/**
 * Original Author: Paul Ouellette
 * 
 * A trigger that contains delegates we can bind to for any events an actor can have. 
 * Currently only the touch and untouch events are being used.
 * 
 * I made this a placeable actor to
 * be able to play around with the collision cylinder in the editor.
 */

class HLW_Trigger extends Actor
	placeable
	ClassGroup(HLW_Trigger);

// Reference to the cylinder component used as the collision component
var() editconst const CylinderComponent	CollisionCylinderComponent;

/**
 * The touch event gets called when another actor touches this trigger. It then calls the function associated
 * with the delegate.
 */
simulated event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	if(Other == none)
	{
		return;
	}
	// Forward on to the delegate function
	OnTouch(Other, OtherComp, HitLocation, HitNormal);
}

/**
 * The touch event gets called when another actor leaves this trigger, or stops touching it. It then calls the function associated
 * with the delegate.
 */
simulated event UnTouch(Actor Other)
{
	if(Other == none)
	{
		return;
	}

	// Forward on to the delegate function
	OnUnTouch(Other);
}

/**
 * The delegate function to associate with the touch event
 */
simulated delegate OnTouch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal);


/**
 * The delegate function to associate with the untouch event
 */
simulated delegate OnUnTouch(Actor Other);

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Trigger'
		HiddenGame=False
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Triggers"
	End Object
	Components.Add(Sprite)

	Begin Object Class=CylinderComponent Name=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
		CollisionRadius=512.f
		CollisionHeight=128.f
		BlockNonZeroExtent=true
		BlockZeroExtent=false
		BlockActors=false
		CollideActors=true
		AlwaysCheckCollision=true
		HiddenGame=true
		HiddenEditor=false
		bAlwaysRenderIfSelected=true
	End Object
	CollisionComponent=CollisionCylinder
	CollisionCylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	CollisionType=COLLIDE_TouchAll

	bHidden=true
	bCollideActors=true
	bCollideWorld=false
	bNoEncroachCheck=false

	bStatic=false
	bNoDelete=false
}
