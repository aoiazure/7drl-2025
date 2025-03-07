class_name ECorpseController extends EController

const CORPSE_SPRITE:= preload("res://assets/sprites/corpse_sprite.tres")

func get_action(_actor: Actor) -> EAction:
	return null

func on_set_active(actor: Actor) -> void:
	actor.blocks_movement = false
	actor.sprite.queue_free()
	
	var sprite = Sprite2D.new()
	sprite.centered = false
	sprite.modulate = Color.DARK_RED
	sprite.texture = CORPSE_SPRITE
	actor.add_child(sprite)
	actor.sprite = sprite
	
	var graphics:= actor.get_component_or_null(Components.GRAPHICS)
	if graphics:
		graphics.deserialize(Graphics.create(
			CORPSE_SPRITE.resource_path, RenderOrder.CORPSE, Color.DARK_RED
		).serialize())
	
	actor.sprite.z_index = -10
	actor.died.emit(actor)

#region Saving and Loading
func serialize() -> Dictionary:
	return super()

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion
