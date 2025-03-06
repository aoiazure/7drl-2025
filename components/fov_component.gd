## Component used to represent an Entity's field of view.
class_name Fov extends EComponent

signal updated

const multipliers = [
	[1, 0, 0, -1, -1, 0, 0, 1],
	[0, 1, -1, 0, 0, -1, 1, 0],
	[0, 1, 1, 0, 0, -1, -1, 0],
	[1, 0, 0, 1, -1, 0, 0, -1]
]

## How far we can see
var vision_radius: int = 1

var all_tiles_seen: Array = []
var tiles_currently_visible: Array[Vector2i] :
	get:
		return _fov

var _fov: Array[Vector2i] = []
var _thread: Thread

static func create(radius: int) -> Fov:
	var fov:= Fov.new()
	fov.vision_radius = radius
	fov._thread = Thread.new()
	
	return fov

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"vision_radius": vision_radius,
		"all_tiles_seen": all_tiles_seen,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	vision_radius = data["vision_radius"]
	all_tiles_seen = data["all_tiles_seen"]
	_thread = Thread.new()
#endregion



func update_fov(map_data: MapData, origin: Vector2i, radius: int = vision_radius) -> void:
	#_run_update_thread(map_data, origin, radius)
	
	if not _thread.is_started():
		_thread.start(_run_update_thread.bind(map_data, origin, radius))
	if not _thread.is_alive():
		_thread.wait_to_finish()

func _run_update_thread(map_data: MapData, origin: Vector2i, radius: int = vision_radius) -> void:
	_clear_fov()
	
	_fov = [origin]
	for i in 8:
		_cast_light(
			map_data, origin.x, origin.y,
			radius, 1, 1.0, 0.0, 
			multipliers[0][i], multipliers[1][i], multipliers[2][i], multipliers[3][i]
		)
	
	for vec: Vector2i in _fov:
		if not all_tiles_seen.has(vec):
			all_tiles_seen.append(vec)
	
	updated.emit()



func _clear_fov() -> void:
	_fov.clear()


func _cast_light(
		map_data: MapData, x: int, y: int,
		radius: int, row: int, start_slope: float, end_slope: float, 
		xx: int, xy: int, yx: int, yy: int) -> void:
	
	if start_slope < end_slope:
		return
	
	var next_start_slope: float = start_slope
	
	for i in range(row, radius + 1):
		var blocked: bool = false
		var dy: int = -i
		for dx in range(-i, 1):
			var l_slope: float = (dx - 0.5) / (dy + 0.5)
			var r_slope: float = (dx + 0.5) / (dy - 0.5)
			if start_slope < r_slope:
				continue
			elif end_slope > l_slope:
				break
			var sax: int = dx * xx + dy * xy
			var say: int = dx * yx + dy * yy
			if ((say < 0 and absi(sax) > x) or (say < 0 and absi(say) > y)):
				continue
			var ax: int = x + sax
			var ay: int = y + say
			if ax >= map_data.grid_definition.map_size.x or ay >= map_data.grid_definition.map_size.y:
				continue
			
			var radius2: int = radius * radius
			var current_tile: Tile = map_data.get_tile_xy(ax, ay)
			# Tile doesn't exist so banish it
			if not current_tile:
				continue
			
			# If this is in view
			if (dx * dx + dy * dy) < radius2:
				_fov.append(Vector2i(ax, ay))
			
			if blocked:
				# If it's opaque
				if not current_tile.is_transparent():
					next_start_slope = r_slope
					continue
				# It's see through
				else:
					blocked = false
					start_slope = next_start_slope
			
			elif not current_tile.is_transparent():
				blocked = true
				next_start_slope = r_slope
				_cast_light(map_data, x, y, radius, i + 1, start_slope, l_slope, xx, xy, yx, yy)
		if blocked:
			break




#func update_fov() -> void:
	#var pos: Vector2i= entity.grid_position
	#var map: MapData = entity.map_data
	#var rect:= Rect2i(Vector2i.ZERO, map.grid_definition.map_size)
	#
	##var distance_map: Dictionary[Vector2i, int] = Dijkstra.calculate(pos, [pos], map.tile_data.keys(), rect)
	#
	### Run bresenham to the furthest cells of the map, which here are the edges. 
	#
	## North edge
	#for x in rect.size.x:
		#var coords:= Vector2i(x, 0)
		#var line_cells: Array[Vector2i]= Geometry2D.bresenham_line(pos, coords)
	## South edge
	#for x in rect.size.x:
		#var coords:= Vector2i(x, rect.size.y - 1)
	#
	#pass

