class_name EController extends Resource

static var Lookup: Dictionary[StringName, EController] = {
	"EDummyController": EDummyController.new(),
	"ECorpseController": ECorpseController.new(),
	
	"EAlertController": EAlertController.new(),
	"EMeleeController": EMeleeController.new(),
	
	"PMoveController": PMoveController.new(),
	
	"HitboxController": HitboxController.new(),
}



func get_action(_actor: Actor) -> EAction:
	return null

func on_set_active(_actor: Actor) -> void:
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
