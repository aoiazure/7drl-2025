extends EController



func get_action(_actor: Actor) -> EAction:
	return null

func on_set_active() -> void:
	pass

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		
	}
	
	data.merge(new_data, true)
	return data

func deserialize(_data: Dictionary) -> void:
	pass
#endregion
