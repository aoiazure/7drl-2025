class_name Dijkstra extends MapUtils



## Returns a Dictionary whose keys are the position 
## and whose values are the Manhattan distance from goal positions.
static func calculate(
				_start_pos: Vector2i, goal_cells: Array[Vector2i], 
				map_cells: Array[Vector2i], map_rect: Rect2i, maximum_radius: int = -1) -> Dictionary[Vector2i, int]:
	
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
		## Note: looping only the map cells naturally skips impassable wall cells.
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
				## or don't, if we are capping size.
				if (maximum_radius > 0) and (lowest_neighbor_value + 1) > maximum_radius:
					continue
				
				array[as_index(cell_position, map_rect)] = lowest_neighbor_value + 1
				change_was_made = true
		
		# end of while loop
		pass
	
	var result: Dictionary[Vector2i, int] = {}
	
	for cell_position: Vector2i in map_cells:
		result[cell_position] = array[as_index(cell_position, map_rect)]
	
	return result


