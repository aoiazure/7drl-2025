class_name FloodFill extends MapUtils



## Returns an array whose keys are the tile positions that are all connected to one another.
static func calculate(
				map_data: MapData, _start_pos: Vector2i, _tile_name: String) -> Array[Vector2i]:
	_tile_name = _tile_name.to_lower()
	
	var queue: Array[Vector2i] = [_start_pos]
	var visited: Array[Vector2i] = []
	var result: Array[Vector2i] = []
	while not queue.is_empty():
		var current_pos: Vector2i = queue.pop_back()
		visited.append(current_pos)
		result.append(current_pos)
		
		for dir: Vector2i in NEIGHBOR_DIRECTIONS:
			var new_position: Vector2i = current_pos + dir
			var next_tile:= map_data.get_tile(new_position)
			if not next_tile:
				continue
			if next_tile.definition.name.to_lower() == _tile_name:
				if not visited.has(new_position):
					queue.append(new_position)
	
	return result

## Returns an array of all valid floor neighbor cells to a position.
static func get_valid_floor_neighbors(cell_position: Vector2i, map_cells: Array[Vector2i]) -> Array[Vector2i]:
	var a: Array[Vector2i] = []
	for dir: Vector2i in NEIGHBOR_DIRECTIONS:
		var new_position:= cell_position + dir
		if map_cells.has(new_position):
			a.append(new_position)
	
	return a




