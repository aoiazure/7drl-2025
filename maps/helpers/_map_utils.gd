class_name MapUtils

const MAX_DISTANCE: int = 99999
const NEIGHBOR_DIRECTIONS:= [
	Vector2i.UP, 
	Vector2i.DOWN, 
	Vector2i.LEFT, 
	Vector2i.RIGHT
]

## Given an X and Y, calculates and returns the corresponding integer index. You can use
## this function to convert 2D coordinates to a 1D array's indices.
## [br]
## [br]There are two cases where you need to convert coordinates like so:
## [br]1. We use it for Dijkstra's.
## [br]2. You can use it for performance by having an indexed array instead of a Dictionary.
static func as_index(cell_position: Vector2i, map_rect: Rect2i) -> int:
	return int((-map_rect.position.x + cell_position.x) + map_rect.size.x * (-map_rect.position.y + cell_position.y))

## Returns an array of all valid floor neighbor cells to a position.
static func get_valid_floor_neighbors(cell_position: Vector2i, map_cells: Array[Vector2i]) -> Array[Vector2i]:
	var a: Array[Vector2i] = []
	for dir: Vector2i in NEIGHBOR_DIRECTIONS:
		var new_position:= cell_position + dir
		if map_cells.has(new_position):
			a.append(new_position)
	
	return a

static func distance_to(from: Vector2i, to: Vector2i) -> int:
	return abs(to.x - from.x) + abs(to.y - from.y)

static func get_circle_points(origin: Vector2i, radius: int) -> Array[Vector2i]:
	var array: Array[Vector2i] = []
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius+1):
			if(x*x+y*y <= radius*radius):
				array.append(Vector2i(origin.x + x, origin.y + y))
	
	return array








