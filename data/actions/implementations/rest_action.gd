class_name EARest extends EAction



func execute() -> EActionResult:
	var tile: Tile = MapHelper.get_tile_at_position(actor.grid_position)
	#if tile.has_item():
		#return EActionResult.new(true, EAPickup.new(actor))
	
	if actor == actor.map_data.player:
		Logger.log_message("%s rested." % actor.name)
	
	return EActionResult.new(true)


func undo() -> EActionResult:
	Logger.log_message("%s un-rested." % actor.name)
	return EActionResult.new(true)


