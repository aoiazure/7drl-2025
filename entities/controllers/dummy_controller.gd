class_name EDummyController extends EController



func get_action(actor: Actor) -> EAction:
	return EARest.new(actor)

func on_set_active(_actor: Actor) -> void:
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

