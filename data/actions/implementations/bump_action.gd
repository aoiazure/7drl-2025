## Action that changes based on what you 'bump' into;
## i.e. anything you walk into voluntarily.
class_name EABumpAction extends EAWithDirection



func execute() -> EActionResult:
	var new_position: Vector2i = actor.grid_position + direction
	var blocker: Entity = ActorHelper.get_movement_blocking_entity(new_position)
	# No block, so just move
	if not blocker:
		return EActionResult.new(true, EAMove.new(actor, direction))
	
	# An actor's blocking, so beat them up
	#if blocker is Actor:
		#return EActionResult.new(true, EAMeleeAttack.new(actor, new_position))
	
	# A different entity is blocking.
	return EActionResult.new(false, null, "You cannot move there.")



func undo() -> EActionResult:
	return null




