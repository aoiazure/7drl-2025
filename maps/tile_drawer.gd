class_name TileDrawer extends Node2D

var map_data: MapData

func _process(_delta: float) -> void:
	if not map_data:
		return
	
	queue_redraw()

func _draw() -> void:
	if not map_data:
		return
	
	for key: Vector2i in map_data.tile_data:
		var rect:= Rect2i(map_data.grid_definition.calculate_map_position(key), map_data.grid_definition.cell_size)
		draw_rect(rect, Color(0.0, 0.0, 0.1, 1.0))
		var tile: Tile = map_data.tile_data[key]
		var graphic:= tile.definition.graphic
		draw_texture_rect(
			graphic.texture, 
			Rect2i(map_data.grid_definition.calculate_map_position(key), map_data.grid_definition.cell_size),
			false,
			graphic.modulate,
		)


