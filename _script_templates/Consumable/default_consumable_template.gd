class_name _CLASS_ extends Consumable



## Use the item's ability.
## Subclasses call this method to cause the desired effect.
func activate(_item_action: ItemAction) -> EActionResult:
	var error:= "Item [%s] effect is unimplemented." % entity.name.capitalize()
	Logger.error(error, true)
	return EActionResult.new(false, null, error)



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

