## Utility class specifically for handling and processing of ubiquitous actions on Entities.
class_name EntityActionHandler extends Node

static var instance: EntityActionHandler

var map_data: MapData



static func try_move(entity: Entity, new_position: Vector2i) -> bool:
	var map: MapData = instance.map_data
	if not map.grid_definition.is_within_bounds(new_position):
		return false
	
	if not map.tile_data.has(new_position):
		return false
	
	var new_tile: Tile = map.tile_data[new_position]
	if not new_tile.is_walkable():
		return false
	
	map.remove_entity(entity)
	
	entity.grid_position = new_position
	map.add_entity_to_tile_at_position(entity, entity.grid_position) 
	
	ActorHelper.instance.set_up_astar()
	return true



func _ready() -> void:
	instance = self


