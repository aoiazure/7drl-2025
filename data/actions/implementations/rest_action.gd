class_name EARest extends EAction



func execute() -> EActionResult:
	var tile: Tile = MapHelper.get_tile_at_position(actor.grid_position)
	if tile.has_item():
		return EActionResult.new(true, EAPickUpItem.new(actor))
	
	if actor == actor.map_data.player:
		Logger.log("%s rested." % actor.entity_name)
		MapSignalBus.player_in_fire_check_requested.emit(actor.grid_position)
		actor.fov_updated.emit(actor.get_component_or_null(Components.FOV))
	
	var stamina: Stamina = actor.get_component_or_null(Components.STAMINA)
	if stamina:
		if stamina.cur_stamina < stamina.max_stamina:
			stamina.increment_recovery(actor, 2)
	
	return EActionResult.new(true)


func undo() -> EActionResult:
	Logger.log("%s un-rested." % actor.entity_name)
	return EActionResult.new(true)


