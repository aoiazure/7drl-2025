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
		#queue_redraw()

func calculate_arena() -> void:
	var _center:= get_used_rect().get_center()
	var valid_tiles:= TileLookup.FLOOR.keys().duplicate()
	valid_tiles.append_array([TileLookup.ARENA_BOSS_SPAWN, TileLookup.ARENA_TRIGGER])
	
	var _floor:= FloodFill.calculate_tilemap(self, _center, valid_tiles)
	data[ARENA_TILES] = _floor
	
	# Set up dijkstra
	#var center_positions: Array[Vector2i] = []
	#var arena_rect:= get_used_rect()
	#var center:= arena_rect.get_center()
	#if arena_rect.size.x % 2 == 0:
		#center -= Vector2i.ONE
		### top left of center
		#center_positions.append(center)
		### top right of center
		#center_positions.append(center + Vector2i.RIGHT)
		### bottom left of center
		#center_positions.append(center + Vector2i.DOWN)
		### bottom right of center
		#center_positions.append(center + Vector2i.ONE)
	#else:
		#center_positions.append(center)
	#
	#var _dijkstra = Dijkstra.calculate(
		#center_positions.front(), center_positions, _floor, arena_rect, -1
	#)
	#
	#data["dijkstra"] = _dijkstra

#func _draw() -> void:
	#var font:= load("res://assets/theming/fonts/monogram-extended.ttf")
	#var dijkstra: Dictionary = data["dijkstra"]
	#for vec: Vector2i in data[ARENA_TILES]:
		#draw_rect(Rect2i(vec * 8, Vector2i.ONE * 8), Color.RED, false)
		#if dijkstra.has(vec):
			#var dist: int = dijkstra[vec]
			#draw_string(font, vec * 8 + Vector2i.DOWN * 8, str(dist), 0, -1, 8, Color.GREEN)


