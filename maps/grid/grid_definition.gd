class_name GridDefinition extends Resource

## Size of the entire map, in cell count.
@export var map_size: Vector2i
## Size of the cells, in pixels.
@export var cell_size: Vector2i = Vector2i.ONE


## Half of ``cell_size``.
## We will use this to calculate the center of a grid cell in pixels, on the screen.
## That's how we can place units in the center of a cell.
var _half_cell_size: Vector2i = cell_size / 2

## Returns the position of a cell's center in pixels.
## We'll place units and have them move through cells using this function.
func calculate_map_position(grid_position: Vector2i) -> Vector2i:
	return grid_position * cell_size

## Returns the position of a cell's center in pixels.
## We'll place units and have them move through cells using this function.
func calculate_map_position_centered(grid_position: Vector2i) -> Vector2i:
	return grid_position * cell_size + _half_cell_size


## Returns the coordinates of the cell on the grid given a position on the map.
## This is the complementary of `calculate_map_position()` above.
## When designing a level, you'll place units visually in the editor. We'll use this function to find
## the grid coordinates they're placed on, and call `calculate_map_position()` to snap them to the
## cell's center.
func calculate_grid_coordinates(map_position: Vector2i) -> Vector2i:
	return map_position / cell_size


## Returns true if the `cell_coordinates` are within the grid.
## This method and the following one allow us to ensure the cursor or units can never go past the
## map's limit.
func is_within_bounds(cell_coordinates: Vector2i) -> bool:
	var out:= cell_coordinates.x >= 0 and cell_coordinates.x < map_size.x
	return out and cell_coordinates.y >= 0 and cell_coordinates.y < map_size.y


## Makes the `grid_position` fit within the grid's bounds.
## This is a clamp function designed specifically for our grid coordinates.
## The Vector2 class comes with its `Vector2.clamp()` method, but it doesn't work the same way: it
## limits the vector's length instead of clamping each of the vector's components individually.
## That's why we need to code a new method.
func clamp_position(grid_position: Vector2i) -> Vector2i:
	var out := grid_position
	out.x = clampi(out.x, 0, map_size.x - 1)
	out.y = clampi(out.y, 0, map_size.y - 1)
	return out
