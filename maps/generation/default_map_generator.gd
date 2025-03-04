class_name MapGenerator extends Node2D

signal generation_finished

enum Zones {
	RUINS,
	CHURCH,
	BOSS_ARENA,
}

@export var zone_configs: Array[ZoneConfig] = []
@export var render_in_progress: bool = false
@export var generate_on_ready: bool = false

@export_group("References")
@export var camera: Camera2D
@export var tilemap_target: TileMapLayer

var zones: Array[ZoneData] = []
var _astar: AStarGrid2D

func _ready() -> void:
	#if not render_in_progress:
		#camera.queue_free()
		#camera = null
	
	if generate_on_ready:
		generate()

func _unhandled_input(_event: InputEvent) -> void:
	var input:= Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	#if Input.is_action_just_released(&"move_left") or \
			#Input.is_action_just_released(&"move_right") or \
			#Input.is_action_just_released(&"move_down") or \
			#Input.is_action_just_released(&"move_up"):
	camera.global_position += input * 8

func generate() -> void:
	Logger.log("Beginning generation.", true, true)
	# 1. generate each zone's rects, and their exits relative to each other
	_create_zone_data()
	Logger.log("Finished step 1.", true, true)
	while true:
		# 2. place prefabs.
		await _place_prefabs_in_zones()
		Logger.log("Finished step 2.", true, true)
		# 3. do an initial WFC pass, placing trees and generic floor tiles.
		await _place_edge_trees()
		await _run_wfc_trees()
		await _carve_exits()
		# 4. clean up of miscellaneous walls
		_clean_up_walls()
		# 5. validate map is traversible.
		if _check_valid_map():
			break
		# else reset.
		tilemap_target.clear()
	
	Logger.log("Finished generation.", true, true)
	generation_finished.emit()


## Generates each zone's rects, and their exits relative to each other
func _create_zone_data() -> void:
	var idx: int = 0
	var prev_zone: ZoneData = null
	var prev_direction: int = -1
	
	# for each zone type
	for config: ZoneConfig in zone_configs:
		# Make base shape
		var size: Vector2i = config.roll_size()
		var rect:= Rect2i(Vector2i.ZERO, size)
		
		var zone: ZoneData = ZoneData.create(rect)
		zone.zone_config = config
		
		# 0 = N, 1 = E, 2 = S, 3 = W
		#var direction = randi_range(0, 3)
		var direction = 3
		
		# If there is not a previous zone to go off of
		if prev_zone == null:
			Logger.log("First zone [%s] set." % config.zone_name, true, true)
			
		# Otherwise, generate new zone and align exits
		else:
			# Reroll until we don't retread old ground
			while true:
				if direction == 0 and prev_direction != 2:
					Logger.log("Zone [%s] moving N." % config.zone_name, true, true)
					break
				if direction == 1 and prev_direction != 3:
					Logger.log("Zone [%s] moving E." % config.zone_name, true, true)
					break
				if direction == 2 and prev_direction != 0:
					Logger.log("Zone [%s] moving S." % config.zone_name, true, true)
					break
				if direction == 3 and prev_direction != 1:
					Logger.log("Zone [%s] moving W." % config.zone_name, true, true)
					break
				
				direction = randi_range(0, 3)
			
			## Choose an exit coordinate for the previous zone
			var prev_exit: Vector2i = prev_zone.position
			# new zone's connecting exit
			var our_exit: Vector2i
			# Generate
			match direction:
				0:
					# Northern half edge
					prev_exit += Vector2i(floori(prev_zone.size.x / 2.), 0)
					
					our_exit = Vector2i(floori(zone.size.x / 2.), zone.size.y) # S
					zone.exit_positions[2] = ZoneData.ExitData.create(our_exit, idx - 1)
				1:
					# Eastern half edge
					prev_exit += Vector2i(prev_zone.size.x, floori(prev_zone.size.y / 2.))
					
					our_exit = Vector2i(0, floori(zone.size.y / 2.)) # W
					zone.exit_positions[3] = ZoneData.ExitData.create(our_exit, idx - 1)
				2:
					# Southern half edge
					prev_exit += Vector2i(floori(prev_zone.size.x / 2.), prev_zone.size.y)
					
					our_exit = Vector2i(floori(zone.size.x / 2.), 0) # N
					zone.exit_positions[0] = ZoneData.ExitData.create(our_exit, idx - 1)
				3:
					# Western half edge
					prev_exit += Vector2i(0, floori(prev_zone.size.y / 2.))
					
					our_exit = Vector2i(zone.size.x, floori(zone.size.y / 2.)) # E
					zone.exit_positions[1] = ZoneData.ExitData.create(our_exit, idx - 1)
			
			## Save previous zone's new exit
			prev_zone.exit_positions[direction] = ZoneData.ExitData.create(prev_exit, idx)
			
			var offset:= 3
			var our_global_exit:= zone.position + our_exit
			var prev_global_exit:= prev_zone.position + prev_exit
			
			## Align our exits
			match direction:
				0: # N
					# move up
					zone.position = prev_zone.position - Vector2i(0, zone.size.y + offset)
					# align horizontal
					zone.position.x -= (our_global_exit.x - prev_global_exit.x)
				1: # E
					# move right
					zone.position = prev_zone.position + Vector2i(prev_zone.size.x + offset, 0)
					# align vertical
					zone.position.y -= (our_global_exit.y - prev_global_exit.y)
				2: # S
					# move down
					zone.position = prev_zone.position + Vector2i(0, prev_zone.size.y + offset)
					# align horizontal
					zone.position.x -= (our_global_exit.x - prev_global_exit.x)
				3: # W
					# move left
					zone.position = prev_zone.position - Vector2i(zone.size.x + offset, 0)
					# align vertical
					zone.position.y -= (our_global_exit.y - prev_global_exit.y)
			
			Logger.log("Previous zone [%s] exit: %s \tNew zone [%s] exit: %s" % [
				prev_zone.zone_config.zone_name, prev_global_exit,
				zone.zone_config.zone_name, our_global_exit
			], true, true)
			
			prev_direction = direction
		
		# Add new zone
		prev_zone = zone
		self.zones.append(zone)
		idx += 1


func _position_camera_to_show_full() -> void:
	var master_rect:= Rect2i()
	for zone: ZoneData in zones:
		master_rect = master_rect.merge(Rect2i(zone.position, zone.size))
	
	camera.global_position = master_rect.get_center()
	get_viewport().size = master_rect.size * 16


## Place prefabs in valid spaces in all zones.
func _place_prefabs_in_zones() -> void:
	for zone: ZoneData in zones:
		var config: ZoneConfig = zone.zone_config
		var scene_prefab: PackedScene = config.prefabs.pick_random()
		var prefab:= scene_prefab.instantiate() as TileMapLayer
		add_child(prefab)
		prefab.visible = false
		
		var prefab_rect:= prefab.get_used_rect()
		# Rect roughly in the center of the zone
		var placing_zone:= Rect2i(
			Vector2i.ZERO, 
			zone.size / 2
		)
		placing_zone.position = zone.position + (zone.size / 2) - placing_zone.size / 2
		# Try until we find a point the prefab rect can be placed in 
		# that is also contained entirely within the zone. 
		var rect_to_place: Rect2i
		var zone_rect:= Rect2i(zone.position, zone.size)
		Logger.log("Beginning Zone [%s] prefab point finding." % [
			config.zone_name
		], true, true)
		for i in range(1000):
			# random point
			var offset:= Vector2i(randi_range(0, placing_zone.size.x), randi_range(0, placing_zone.size.y))
			rect_to_place = Rect2i(placing_zone.position + offset, prefab_rect.size)
			if zone_rect.encloses(rect_to_place):
				Logger.log("[Attempt %s] Zone %s encloses %s." % [i, zone_rect, rect_to_place], true, true)
				break
			Logger.log("[Attempt %s] Zone %s cannot enclose %s, retrying." % [i, zone_rect, rect_to_place], true, true)
		
		# Copy over all the prefab info into the zone.
		Logger.log("Beginning prefab placement.", true, true)
		await _copy_tilemap_to_other(prefab, tilemap_target, rect_to_place.position)
		
		prefab.queue_free()

## Copy all tiles
func _copy_tilemap_to_other(from_tilemap: TileMapLayer, to_tilemap: TileMapLayer, offset:= Vector2i.ZERO) -> void:
	for coords: Vector2i in from_tilemap.get_used_cells():
		var source_id:= from_tilemap.get_cell_source_id(coords)
		var atlas_coord:= from_tilemap.get_cell_atlas_coords(coords)
		to_tilemap.set_cell(coords + offset, source_id, atlas_coord)
		
		if render_in_progress:
			camera.global_position = to_tilemap.to_global(to_tilemap.map_to_local(coords + offset))
			await get_tree().create_timer(0.05).timeout


func _place_edge_trees() -> void:
	for zone: ZoneData in zones:
		# N / S
		for x in range(zone.size.x + 1):
			# N
			tilemap_target.set_cell(
				zone.position + Vector2i(x, 0), 1, 
				TileLookup.TREES.keys().pick_random()
			)
			# S
			tilemap_target.set_cell(
				zone.position + Vector2i(x, zone.size.y), 1, 
				TileLookup.TREES.keys().pick_random()
			)
			
			if render_in_progress:
				await get_tree().create_timer(0.05).timeout
		
		# W / E
		for y in range(zone.size.y + 1):
			# W
			tilemap_target.set_cell(
				zone.position + Vector2i(0, y), 1, 
				TileLookup.TREES.keys().pick_random()
			)
			# E
			tilemap_target.set_cell(
				zone.position + Vector2i(zone.size.x, y), 1, 
				TileLookup.TREES.keys().pick_random()
			)
			
			if render_in_progress:
				await get_tree().create_timer(0.05).timeout



func _run_wfc_trees() -> void:
	for zone: ZoneData in zones:
		var zone_rect:= Rect2i(zone.position, zone.size)
		var wfc_trees:= WFC2DGenerator.new()
		add_child(wfc_trees)
		
		if not wfc_trees.is_node_ready():
			await wfc_trees.ready
		
		wfc_trees.target = wfc_trees.get_path_to(tilemap_target)
		wfc_trees.rect = zone_rect
		wfc_trees.positive_sample = wfc_trees.get_path_to($Trees/TreesSample)
		wfc_trees.negative_sample = wfc_trees.get_path_to($Trees/TreesNegative)
		
		wfc_trees.precondition = WFC2DPreconditionReadExistingSettings.new()
		wfc_trees.use_multithreading = false
		
		Logger.log("Running WFC for tree and floor placement in Zone [%s]." % zone.zone_config.zone_name, true, true)
		
		if render_in_progress:
			wfc_trees.render_intermediate_results = true
		
		wfc_trees.start()
		await wfc_trees.done
		Logger.log("WFC in Zone [%s] completed." % zone.zone_config.zone_name, true, true)
		
		wfc_trees.queue_free()
		await get_tree().process_frame

func _carve_exits() -> void:
	var handled_positions: Array[Vector2i] = []
	
	for zone: ZoneData in zones:
		# the key is also the direction
		for key_dir_id: int in zone.exit_positions:
			var our_exit: ZoneData.ExitData = zone.exit_positions[key_dir_id]
			
			## We've already done this exit, so move on
			if our_exit.position in handled_positions:
				continue
			
			var other_zone: ZoneData = zones[our_exit.linked_id]
			var other_exit: ZoneData.ExitData
			# 
			match key_dir_id:
				0: # N
					other_exit = other_zone.exit_positions[2]
				1: # E
					other_exit = other_zone.exit_positions[3]
				2: # S
					other_exit = other_zone.exit_positions[0]
				3: # W
					other_exit = other_zone.exit_positions[1]
			
			var other_global_pos:= (other_zone.position + other_exit.position)
			var our_global_pos:= (zone.position + our_exit.position)
			var dir_vec:= other_global_pos - our_global_pos
			# Horizontal alignment
			if dir_vec.x != 0:
				for x in range(0, abs(dir_vec.x) + 1):
					var coords:= Vector2i(min(other_global_pos.x, our_global_pos.x) + x, our_global_pos.y)
					tilemap_target.set_cell(coords, 1, Vector2i(8, 26))
					
					#Logger.log("Carved exit path at %s." % coords, true, true)
					
					if render_in_progress:
						await get_tree().create_timer(0.1).timeout
			# Vertical alignment
			else:
				for y in range(0, abs(dir_vec.y) + 1):
					var coords:= Vector2i(our_global_pos.x, min(other_global_pos.y, our_global_pos.y) + y)
					tilemap_target.set_cell(coords, 1, Vector2i(8, 26))
					
					#Logger.log("Carved exit path at %s." % coords, true, true)
					
					if render_in_progress:
						await get_tree().create_timer(0.1).timeout
			
			## Save as handled
			handled_positions.append(our_exit.position)
			handled_positions.append(other_exit.position)
	pass


func _check_valid_map() -> bool:
	_astar = AStarGrid2D.new()
	_astar.region = tilemap_target.get_used_rect()
	_astar.cell_size = Vector2i(8, 8)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()
	_astar.fill_solid_region(tilemap_target.get_used_rect())
	
	for coord: Vector2i in tilemap_target.get_used_cells():
		if tilemap_target.get_cell_atlas_coords(coord) in TileLookup.FLOOR:
			_astar.set_point_solid(coord, false)
	
	var is_valid:= true
	for i in range(zones.size() - 1):
		var cur_zone:= zones[i]
		var next_zone:= zones[i+1]
		
		var cur_rect:= Rect2i(cur_zone.position, cur_zone.size)
		var next_rect:= Rect2i(next_zone.position, next_zone.size)
		
		var path:= _astar.get_point_path(cur_rect.get_center(), next_rect.get_center())
		if path.is_empty():
			is_valid = false
			break
	
	return is_valid



func _clean_up_walls() -> void:
	for coord: Vector2i in tilemap_target.get_used_cells_by_id(1, Vector2i(0, 9)):
		var surrounding:= tilemap_target.get_surrounding_cells(coord)
		var cell_types:= surrounding.map(
			func(element: Vector2i):
				return tilemap_target.get_cell_atlas_coords(element)
		)
		if not Vector2i(0, 9) in cell_types:
			tilemap_target.set_cell(coord, 1, TileLookup.GenericFloorAtlas)










