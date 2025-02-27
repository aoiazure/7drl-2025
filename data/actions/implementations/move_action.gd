class_name EAMove extends EAWithDirection

var old_position: Vector2i

func execute() -> EActionResult:
	old_position = actor.grid_position
	var new_position:= actor.grid_position + direction
	var success: bool = EntityActionHandler.try_move(actor, new_position)
	var result:= EActionResult.new(success)
	
	if not result.succeeded:
		result.error_message = "You cannot move there."
	
	return result


func undo() -> EActionResult:
	var result:= EntityActionHandler.try_move(actor, old_position)
	return EActionResult.new(result)



