## Utility class specifically for handling and processing of ubiquitous actions on Entities.
class_name EntityActionHandler extends Node

static var instance: EntityActionHandler

var map_data: MapData



static func try_move(entity: Entity, new_position: Vector2i) -> bool:
	var map: MapData = instance.map_data
	if not map.grid_definition.is_within_bounds(new_position):
		return false
	
	var new_tile: Tile = map.tile_data[new_position]
	if not new_tile.is_walkable():
		return false
	
	var cur_position: Vector2i = entity.grid_position
	var old_tile: Tile = map.tile_data[cur_position]
	old_tile.entities.erase(entity)
	
	entity.grid_position = new_position
	new_tile.entities.append(entity)
	
	return true



func _ready() -> void:
	instance = self


