class_name EAMove extends EAWithDirection

var old_position: Vector2i

func execute() -> EActionResult:
	old_position = actor.grid_position
	var new_position:= actor.grid_position + direction
	var success: bool = EntityActionHandler.try_move(actor, new_position)
	
	if not success:
		return EActionResult.new(false, null, "You cannot move there.")
	
	var stamina: Stamina = actor.get_component_or_null(Components.STAMINA)
	if stamina:
		if stamina.cur_stamina < stamina.max_stamina:
			stamina.increment_recovery(actor, 1)
	
	return EActionResult.new(true)


func undo() -> EActionResult:
	var result:= EntityActionHandler.try_move(actor, old_position)
	return EActionResult.new(result)



