class_name HealthFlask extends Consumable



## Use the item's ability.
## Subclasses call this method to cause the desired effect.
func activate(item_action: ItemAction) -> EActionResult:
	print("called")
	var fighter: Fighter = item_action.actor.get_component_or_null(Components.FIGHTER)
	if not fighter:
		return EActionResult.new(false, null, "You don't have a Fighter component to heal.")
	
	if fighter.cur_health == fighter.max_health:
		return EActionResult.new(false, null, "You're already at full health.")
	
	if item_action.actor.is_player:
		Logger.log("You drank the health flask.")
	
	fighter.heal(4)
	consume(item_action.actor)
	return EActionResult.new(true)



#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion


