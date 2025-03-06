class_name ManaFlask extends Consumable



## Use the item's ability.
## Subclasses call this method to cause the desired effect.
func activate(item_action: ItemAction) -> EActionResult:
	var mana: Mana = item_action.actor.get_component_or_null(Components.MANA)
	if not mana:
		return EActionResult.new(false, null, "You don't have a Mana component to heal.")
	
	if mana.cur_mana == mana.max_mana:
		return EActionResult.new(false, null, "You're already at full mana.")
	
	mana.recover(3)
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


