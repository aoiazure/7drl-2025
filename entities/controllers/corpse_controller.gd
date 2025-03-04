class_name ECorpseController extends EController



func get_action(_actor: Actor) -> EAction:
	return null

func on_set_active(actor: Actor) -> void:
	actor.blocks_movement = false
	actor.sprite.stop()
	
	actor.died.emit(actor)

#region Saving and Loading
func serialize() -> Dictionary:
	return super()

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion
