## Generic class that represents characters, items, etc.
class_name Entity extends Node2D

signal grid_position_changed(old_position: Vector2i, new_position: Vector2i)

@export_group("References")
@export_group("")

@export var entity_name: String = "Entity"
@export var entity_desc: String

## Whether or not you can walk through this.
@export var blocks_movement: bool = false
## Whether or not you can see through this.
@export var blocks_vision: bool = false

## Used to keep actors in order.
var id: int = -1
## Entity location on the grid.
var grid_position: Vector2i : set = _set_grid_position
## Dictionary containing all components.
var components: Dictionary[StringName, EComponent] = {}

## Visual component
var sprite

var map_data: MapData

func set_entity_name(_name: String) -> Entity:
	entity_name = _name
	return self

func set_description(_desc: String) -> Entity:
	entity_desc = _desc
	return self

func add_component(_name: StringName, _component: EComponent) -> Entity:
	if not components.has(_name):
		_component.entity = self
		components[_name] = _component
	
	return self

func has_component(_name: StringName) -> bool:
	return components.has(_name)

func get_component_or_null(_name: StringName) -> EComponent:
	if not components.has(_name):
		return null
	
	return components[_name]

func remove_component(_name: StringName) -> void:
	components.erase(_name)

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
		"id": id,
		"entity_name": entity_name,
		"entity_desc": entity_desc,
		
		"grid_position": JSON.from_native(grid_position),
		
		"blocks_movement": blocks_movement,
		"blocks_vision": blocks_vision,
		
		"components": c_data,
	}
	
	return data

func deserialize(data: Dictionary) -> void:
	self.id = data["id"]
	
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
		
		if key == Components.GRAPHICS:
			# Visuals
			var graphics: Graphics = Graphics.new()
			graphics.deserialize(temp_components[key])
			
			if graphics.texture is SpriteFrames:
				sprite = AnimatedSprite2D.new()
				sprite.centered = false
				sprite.modulate = graphics.modulate
				sprite.sprite_frames = graphics.texture
				add_child(sprite)
				sprite.play()
			elif graphics.texture is Texture2D:
				sprite = Sprite2D.new()
				sprite.centered = false
				sprite.modulate = graphics.modulate
				sprite.texture = graphics.texture
				add_child(sprite)
			
			add_component(Components.GRAPHICS, graphics)
		elif key == Components.CONSUMABLE:
			var consumable_data: Dictionary = temp_components[key]
			var consumable: Consumable = Consumable.Index[consumable_data["name"]].duplicate(true)
			consumable.deserialize(consumable_data)
			add_component(key, consumable)
		elif key == Components.EQUIPPABLE:
			var equippable_data: Dictionary = temp_components[key]
			var equippable: Equippable = Equippable.Index[equippable_data["name"]].duplicate(true)
			equippable.deserialize(equippable_data)
			add_component(key, equippable)
		else:
			var component: EComponent = EComponent.Lookup[key].duplicate(true)
			component.deserialize(temp_components[key])
			add_component(key, component)

#endregion

func _ready() -> void:
	if id == -1:
		self.id = Time.get_ticks_msec()

func _set_grid_position(val: Vector2i) -> void:
	var old_pos = grid_position
	grid_position = val
	grid_position_changed.emit(old_pos, val)
	
	if not is_inside_tree():
		return
	
	global_position = map_data.grid_definition.calculate_map_position_centered(val)





