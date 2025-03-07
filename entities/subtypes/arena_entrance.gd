class_name ArenaEntrance extends Entity

const TILE_DOOR_OPEN:= preload("res://assets/sprites/tiles/tile_door_open.tres")
const TILE_DOOR_CLOSED = preload("res://assets/sprites/tiles/tile_door_closed.tres")

func _ready() -> void:
	super()
	add_component(Components.GRAPHICS, Graphics.create(
		TILE_DOOR_OPEN.resource_path, RenderOrder.ACTOR, Color.ORANGE_RED
	))
	
	sprite = Sprite2D.new()
	sprite.centered = false
	sprite.texture = TILE_DOOR_OPEN
	add_child(sprite)
	
	self.blocks_movement = false
	self.blocks_vision = false
	
	MapSignalBus.arena_entrance_triggered.connect(
		func():
			self.blocks_movement = true
			self.blocks_vision = true
			
			sprite.texture = TILE_DOOR_CLOSED
			var graphics: Graphics = get_component_or_null(Components.GRAPHICS)
			graphics.texture = TILE_DOOR_CLOSED
			graphics.sprite_path = TILE_DOOR_CLOSED.resource_path
	)



#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"type": "ArenaEntrance",
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion


