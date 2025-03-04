class_name EAPickUpItem extends EAction



func execute() -> EActionResult:
	var tile: Tile = actor.map_data.get_tile(actor.grid_position)
	var item: Item = tile.get_first_item()
	if not item:
		return EActionResult.new(false, null, "There is no item here to pick up.")
	
	var inventory: Inventory = actor.get_component_or_null(Components.INVENTORY)
	if not inventory:
		return EActionResult.new(false, null, "You have no inventory to put this in.")
	
	var result: bool = inventory.add(item)
	if not result:
		return EActionResult.new(false, null, "You have no space left to put this in.")
	
	# Remove it from the world
	tile.remove_entity(item)
	# Log it
	if actor.is_player:
		Logger.log("You picked up the %s." % item.entity_name)
	
	return EActionResult.new(true)

func undo() -> EActionResult:
	return null



func _init(_actor: Actor) -> void:
	actor = _actor

