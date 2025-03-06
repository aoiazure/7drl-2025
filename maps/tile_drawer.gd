class_name TileDrawer extends Node2D

var map_data: MapData

func _on_turn_scheduler_turn_taken() -> void:
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(map_data):
		return
	
	var player: Actor = map_data.player
	if not is_instance_valid(player):
		return
	
	var fov: Fov = player.get_component_or_null(Components.FOV)
	var viewport_rect: Rect2i = get_viewport_rect()
	var player_point: Vector2i = map_data.grid_definition.calculate_map_position(player.grid_position)
	viewport_rect.position = player_point
	viewport_rect.position -= Vector2i.ONE * 8 * 16 # more to top left
	
	for key: Vector2i in fov.all_tiles_seen:
		var world_position:= map_data.grid_definition.calculate_map_position(key)
		if not viewport_rect.has_point(world_position):
			continue
		
		var tile: Tile = map_data.get_tile(key)
		var graphics:= tile.definition.graphics
		if not is_instance_valid(graphics.texture):
			continue
		
		var modulate_multiplier = 1.0
		# Fade out invisible places you've seen at some point
		if fov and not fov.tiles_currently_visible.has(key):
			modulate_multiplier = 0.6
		
		var rect:= Rect2i(world_position, map_data.grid_definition.cell_size)
		draw_texture_rect(
			graphics.texture,
			rect,
			false,
			graphics.modulate * modulate_multiplier,
		)


