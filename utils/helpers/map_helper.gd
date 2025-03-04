## Utility class specifically for interacting with game map.
class_name MapHelper extends Node

static var instance: MapHelper

var map_data: MapData



##
static func place(entity: Entity, position: Vector2i, data: MapData = instance.map_data) -> void:
	instance.map_data.remove_entity(entity)
	entity.grid_position = position
	data.add_entity_to_tile_at_position(entity, position)



## Get a reference to the player entity.
static func get_player() -> Actor:
	if not instance:
		return null
	if not instance.map_data:
		return null
	
	return instance.map_data.player

## Get an array of all actors.
static func get_all_actors() -> Array[Actor]:
	var actors: Array[Actor] = instance.map_data.actors.duplicate()
	actors.make_read_only()
	return actors

## Return the first actor at a specific position.
static func get_actor_at_position(position: Vector2i) -> Actor:
	var actor: Actor = null
	var tile: Tile = instance.map_data.tile_data[position]
	tile.sort_by_render(true)
	
	for e: Entity in tile.entities:
		if e is Actor:
			actor = (e as Actor)
			break
	
	return actor

static func get_map_size() -> Vector2i:
	return instance.map_data.grid_definition.map_size

static func get_mouse_grid_position() -> Vector2i:
	var mouse_position:= instance.get_viewport().get_mouse_position()
	var grid_position:= instance.map_data.grid_definition.calculate_grid_coordinates(mouse_position)
	grid_position = instance.map_data.grid_definition.clamp_position(grid_position)
	
	return grid_position

### Enable or disable cursors.
#static func use_cursor(active: bool) -> void:
	#instance.map_data.is_cursor_active = active
	#if not active:
		#instance.map_data.cursor_rect = Rect2i(-1, -1, 0, 0)
	#
	#instance.map_data.changed.emit()
#
#static func set_cursor_is_in_range(in_range: bool) -> void:
	#instance.map_data.cursor_in_range = in_range
#
### Update the cursor location. Returns true if the position has changed.
#static func set_cursor_location(new_position: Vector2i, radius: int = 0) -> bool:
	#var current_position:= instance.map_data.cursor_rect.position
	#
	#instance.map_data.cursor_rect = Rect2i(
		#new_position - Vector2i.ONE * radius, 
		#Vector2i.ONE * (radius * 2 + 1)
	#)
	#
	#if current_position == new_position:
		#return false
	#
	#ActorHelper.instance.map_data.changed.emit()
	#return true

## Return the tile at the specific location.
static func get_tile_at_position(position: Vector2i) -> Tile:
	return instance.map_data.tile_data[position]

## Clamp a position to the map boundaries.
static func clamp_to_map_position(position: Vector2i) -> Vector2i:
	return instance.map_data.grid_definition.clamp_position(position)


func _ready() -> void:
	instance = self



