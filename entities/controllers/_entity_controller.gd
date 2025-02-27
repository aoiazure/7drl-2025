class_name EController extends Resource

static var Lookup: Dictionary[StringName, EController] = {
	"ECorpseController": ECorpseController.new(),
	
	"PMoveController": PMoveController.new(),
}



func get_action(_actor: Actor) -> EAction:
	return null

func on_set_active() -> void:
	pass

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = {
		"name": get_script().get_global_name()
	}
	return data

func deserialize(_data: Dictionary) -> void:
	pass
#endregion
