class_name Consumable extends EComponent

static var Index: Dictionary[StringName, Consumable] = {
	Items.HEALTH_FLASK: HealthFlask.new(),
	Items.MANA_FLASK: ManaFlask.new(),
}

## Use the item's ability.
## Subclasses call this method to cause the desired effect.
func activate(_item_action: ItemAction) -> EActionResult:
	var error:= "Item [%s] effect is unimplemented." % entity.entity_name.capitalize()
	Logger.error(error, true)
	return EActionResult.new(false, null, error)



## Handles fully removing/decrementing and despawning an item after its use.
func consume(consumer: Actor) -> void:
	var inventory: Inventory = (entity as Item).inventory_container
	var stackable: Stackable = entity.get_component_or_null(Components.STACKABLE)
	if stackable:
		stackable.remove_stack(1)
		if stackable.stack > 0 and inventory:
			inventory.emit_changed()
			return
	
	if inventory:
		inventory.remove(entity)
	## Remove from world
	else:
		var tile: Tile = consumer.map_data.get_tile(entity.position)
		tile.remove_entity(entity)
		entity.queue_free()

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"name": get_script().get_global_name(),
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion



