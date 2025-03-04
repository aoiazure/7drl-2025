## Utility class specifically for commonly used functions for Actors.
class_name ActorHelper extends Node

static var instance: ActorHelper

var map_data: MapData : 
	set(val):
		map_data = val
		map_data.actors_changed.connect(set_up_astar)

var astar: AStarGrid2D
var id_count: int = 0

static func get_movement_blocking_entity(position: Vector2i) -> Entity:
	var map: MapData = instance.map_data
	if not map.grid_definition.is_within_bounds(position):
		return null
	
	if not map.tile_data.has(position):
		return null
	
	var tile: Tile = map.tile_data[position]
	if tile.entities.is_empty():
		return null
	
	var entity: Entity = null
	for e: Entity in tile.entities:
		if e.blocks_movement:
			entity = e
			break
	
	return entity

## Returns an Actor at a specific grid position.[br]
## Returns null if there are none, or the actor is in the exclude array.
static func get_actor_at_position(position: Vector2i, exclude: Array[Actor] = []) -> Actor:
	var map:= instance.map_data
	if not map.grid_definition.is_within_bounds(position):
		return null
	
	var tile: Tile = map.tile_data[position]
	if tile.entities.is_empty():
		return null
	
	var actor: Actor = null
	for e: Entity in tile.entities:
		if e is Actor:
			if e in exclude:
				continue
			
			actor = e
			# Keep looking just in case it's a corpse.
			if actor.controller is not ECorpseController:
				break
	
	return actor


## Returns an Array[Vector2i].
static func get_navigation_path_to(from_position: Vector2i, to_position: Vector2i, 
		refresh: bool = false, allow_partial: bool = false) -> Array[Vector2i]:
	if refresh:
		instance.set_up_astar()
	
	return instance.astar.get_id_path(from_position, to_position, allow_partial)



func set_up_astar() -> void:
	astar = AStarGrid2D.new()
	astar.region = Rect2i(Vector2i.ZERO, map_data.grid_definition.map_size)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	astar.update()
	
	for coord: Vector2i in map_data.tile_data:
		var blocker:= get_movement_blocking_entity(coord)
		if blocker:
			if blocker is Actor:
				astar.set_point_weight_scale(coord, 3)
			else:
				astar.set_point_solid(coord)
		else:
			astar.set_point_solid(coord, not map_data.get_tile(coord).is_walkable())

func _ready() -> void:
	instance = self







