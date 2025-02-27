## Utility class specifically for commonly used functions for Actors.
class_name ActorHelper extends Node

static var instance: ActorHelper

var map_data: MapData : 
	set(val):
		map_data = val
		#set_up_astar()

var astar_grid: AStarGrid2D


static func get_movement_blocking_entity(position: Vector2i) -> Entity:
	var map: MapData = instance.map_data
	if not map.grid_definition.is_within_bounds(position):
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


static func get_actor_at_position(position: Vector2i) -> Actor:
	var map:= instance.map_data
	if not map.grid_definition.is_within_bounds(position):
		return null
	
	var tile: Tile = map.tile_data[position]
	if tile.entities.is_empty():
		return null
	
	var actor: Actor = null
	for e: Entity in tile.entities:
		if e is Actor:
			actor = e
			# Keep looking just in case it's a corpse.
			if actor.controller is not ECorpseController:
				break
	
	return actor


static func get_navigation_path_to(from_position: Vector2i, to_position: Vector2i, refresh: bool = false) -> Array[Vector2i]:
	if refresh:
		instance.set_up_astar()
	
	return instance.astar_grid.get_id_path(from_position, to_position)




func set_up_astar() -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(Vector2i.ZERO, map_data.grid_definition.map_size)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	astar_grid.update()
	
	for coord: Vector2i in map_data.data:
		var blocker:= get_movement_blocking_entity(coord)
		if blocker:
			if blocker is Actor:
				astar_grid.set_point_weight_scale(coord, 3)
			else:
				astar_grid.set_point_solid(coord)

func _ready() -> void:
	instance = self







