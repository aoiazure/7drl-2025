extends EController



func get_action(_actor: Actor) -> EAction:
	return null

func on_set_active(_actor: Actor) -> void:
	pass

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
