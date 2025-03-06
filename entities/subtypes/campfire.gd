class_name Campfire extends Entity

const SCENE:= preload("res://entities/subtypes/campfire.tscn")
const TILE_CAMPFIRE = "res://assets/sprites/tiles/tile_campfire.tres"

@export var _sprite: Sprite2D

## Whether this campfire can still be used.
var is_active: bool = true :
	set(val):
		is_active = val
		if not sprite:
			return 
		
		if is_active:
			sprite.self_modulate = Color.ORANGE_RED
		else:
			sprite.self_modulate = Color.PALE_VIOLET_RED



func _ready() -> void:
	super()
	
	sprite = _sprite
	sprite.centered = false
	
	add_component(Components.GRAPHICS, Graphics.create(
		TILE_CAMPFIRE, RenderOrder.ACTOR, Color.ORANGE_RED
	))
	
	self.blocks_movement = true
	self.blocks_vision = false



#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"type": "Campfire",
		"is_active": is_active,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.is_active = data["is_active"]
#endregion
