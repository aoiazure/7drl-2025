class_name Prefab extends TileMapLayer

enum Type {
	GENERIC = 0,
	RUINS,
	ARENA,
}

const ARENA_TILES:= "arena_tiles"

@export var type: Type

var data: Dictionary = {}

func _ready() -> void:
	if type == Type.ARENA:
		calculate_arena()

func calculate_arena() -> void:
	var _center:= get_used_rect().get_center()
	var _floor:= FloodFill.calculate_tilemap(self, TileLookup.FLOOR.keys())
	data[ARENA_TILES] = _floor 


