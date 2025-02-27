## Generic class that represents characters, items, etc.
class_name Entity extends Node2D

signal grid_position_changed(old_position: Vector2i, new_position: Vector2i)

@export_group("References")
@export var sprite: AnimatedSprite2D

var entity_name: String = "Entity"
var entity_desc: String
## Entity location on the grid.
var grid_position: Vector2i : set = _set_grid_position

## Whether or not you can walk through this.
var blocks_movement: bool = false
## Whether or not you can see through this.
var blocks_vision: bool = false

## Dictionary containing all components.
var components: Dictionary[StringName, EComponent] = {}

## Visual component
var graphics: Graphics



var map_data: MapData

#region Save and Load
func serialize() -> Dictionary:
	# Serialize all components
	var c_data: String = "{"
	for i: int in range(components.size()):
		var component_name: StringName = components.keys()[i]
		var component: EComponent = components[component_name]
		var d: String = "\"%s\": %s" % [component_name, JSON.stringify(component.serialize())]
		c_data += d
		if i != (components.size() - 1):
			c_data += ","
	c_data += "}"
	
	# Serialize everything at once
	var data: Dictionary = {
		"entity_name": entity_name,
		"entity_desc": entity_desc,
		
		"grid_position": JSON.from_native(grid_position),
		
		"blocks_movement": blocks_movement,
		"blocks_vision": blocks_vision,
		
		"components": c_data,
		
		"graphics": graphics.serialize(),
	}
	
	return data

func deserialize(data: Dictionary) -> void:
	self.entity_name = data["entity_name"]
	self.entity_desc = data["entity_desc"]
	
	self.grid_position = JSON.to_native(data["grid_position"])
	self.blocks_movement = data["blocks_movement"]
	self.blocks_vision = data["blocks_vision"]
	# Components
	var json:= JSON.new()
	var err = json.parse(data["components"])
	if err:
		printt(json.get_error_line(), json.get_error_message())
		return
	
	var temp_components: Dictionary = json.data as Dictionary
	for i: int in range(temp_components.size()):
		var key: String = temp_components.keys()[i]
		
		var component: EComponent = EComponent.Lookup[key].duplicate(true)
		component.deserialize(temp_components[key])
		components[key] = component
	
	# Visuals
	self.graphics = Graphics.new()
	self.graphics.deserialize(data["graphics"])
	sprite.modulate = self.graphics.modulate
	sprite.sprite_frames = load(graphics.sprite_path)
	sprite.play()

#endregion

func _set_grid_position(val: Vector2i) -> void:
	var old_pos = grid_position
	grid_position = val
	grid_position_changed.emit(old_pos, val)







