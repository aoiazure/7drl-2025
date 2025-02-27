class_name Dijkstra

const MAX_DISTANCE: int = 99999
const NEIGHBOR_DIRECTIONS:= [
	Vector2i.UP, 
	Vector2i.DOWN, 
	Vector2i.LEFT, 
	Vector2i.RIGHT
]

static func calculate(_start_pos: Vector2i, goal_cells: Array[Vector2i], 
				map_cells: Array[Vector2i], map_rect: Rect2i) -> Dictionary[Vector2i, int]:
	## To get a Dijkstra map, you start with an integer array representing your map,
	var array: Array[int] = []
	array.resize(as_index(map_rect.size, map_rect))
	array.fill(MAX_DISTANCE)
	## with some set of goal cells set to zero and all the rest set to a very high number.
	for goal: Vector2i in goal_cells:
		array[as_index(goal, map_rect)] = 0
	
	## Repeat the process below until no changes are made. 
	## The resulting grid of numbers represents the number of steps that
	## it will take to get from any given tile to the nearest goal.
	var change_was_made: bool = true
	while change_was_made:
		# This will be flipped if any change was made
		change_was_made = false
		
		## Iterate through the map's "floor" cells -- skip the impassable wall cells.
		# Note: looping only the map cells naturally skips impassable wall cells.
		for cell_position: Vector2i in map_cells:
			## If any floor tile has a value greater than 1 regarding to its lowest-value floor neighbour 
			## (in a cardinal direction; a cell next to the one we are checking),
			var neighbors:= get_valid_floor_neighbors(cell_position, map_cells)
			var own_value: int = array[as_index(cell_position, map_rect)]
			var lowest_neighbor_value: int = MAX_DISTANCE
			for neighbor_position: Vector2i in neighbors:
				var value: int = array[as_index(neighbor_position, map_rect)]
				if value < lowest_neighbor_value:
					lowest_neighbor_value = value
			## set it to be exactly 1 greater than its lowest value neighbor.
			if own_value > (lowest_neighbor_value + 1):
				array[as_index(cell_position, map_rect)] = lowest_neighbor_value + 1
				change_was_made = true
		
		# end of while loop
		pass
	
	var result: Dictionary[Vector2i, int] = {}
	
	for cell_position: Vector2i in map_cells:
		result[cell_position] = array[as_index(cell_position, map_rect)]
	
	return result

# Given an X and Y, calculates and returns the corresponding integer index. You can use
# this function to convert 2D coordinates to a 1D array's indices.
#
# There are two cases where you need to convert coordinates like so:
# 1. We use it for Dijkstra's.
# 2. You can use it for performance by having an indexed array instead of a Dictionary.
static func as_index(cell_position: Vector2i, map_rect: Rect2i) -> int:
	return int((-map_rect.position.x + cell_position.x) + map_rect.size.x * (-map_rect.position.y + cell_position.y))

# Returns an array of all valid floor neighbor cells to a position.
static func get_valid_floor_neighbors(cell_position: Vector2i, map_cells: Array[Vector2i]) -> Array[Vector2i]:
	var a: Array[Vector2i] = []
	for dir: Vector2i in NEIGHBOR_DIRECTIONS:
		var new_position:= cell_position + dir
		if map_cells.has(new_position):
			a.append(new_position)
	
	return a
