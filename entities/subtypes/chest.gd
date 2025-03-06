class_name Chest extends Entity

const FRAMES_CHEST:= preload("res://assets/sprites/chest_sprite_frames.tres")
const SCENE:= preload("res://entities/subtypes/chest.tscn")

@export var _sprite: AnimatedSprite2D

func configure(_items: Array[Item]) -> void:
	var inventory: Inventory = get_component_or_null(Components.INVENTORY)
	if not inventory:
		inventory = Inventory.create(_items)
		add_component(Components.INVENTORY, inventory)
		return
	
	for i: Item in _items:
		inventory.add(i)

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"type": "Campfire",
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion

func _ready() -> void:
	super()
	
	sprite = _sprite
	sprite.centered = false
	
	add_component(Components.GRAPHICS, Graphics.create(
		FRAMES_CHEST.resource_path, RenderOrder.ACTOR, Color.SADDLE_BROWN
	))
	
	self.blocks_movement = true
	self.blocks_vision = false


