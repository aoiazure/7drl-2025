class_name ECorpseController extends EController

func get_action(_actor: Actor) -> EAction:
	return null

#region Saving and Loading
func serialize() -> Dictionary:
	return super()

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion
