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

@export var prefab_campfires: Array[PackedScene] = []

@export_group("References")
@export var camera: Camera2D
@export var tilemap_target: TileMapLayer

@onready var _precondition:= preload("res://maps/generation/precondition_settings/basic_generation.tres")

var zones: Array[ZoneData] = []
var all_prefab_rects: Array[Rect2i] = []
var _astar: AStarGrid2D

var boss_arena_data: Dictionary = {}
var first_campfire_rect: Rect2i

func _ready() -> void:
	if generate_on_ready:
		generate()

func _unhandled_input(_event: InputEvent) -> void:
	var input:= Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	camera.global_position += input * 8

func generate() -> void:
	Logger.log("Beginning generation.", true, true)
	# 1. generate each zone's rects, and their exits relative to each other
	_create_zone_data()
	Logger.log("Finished step 1.", true, true)
	# 2. do an initial WFC pass, placing trees and generic floor tiles.
	await _place_edge_trees()
	await _run_wfc_trees()
	# 3. clean up of miscellaneous walls
	_clean_up_walls()
	# 4. place prefabs on top.
	Logger.log("Finished step 2.", true, true)
	await _place_prefabs_in_zones()
	await _place_campfires()
	# 5. carve path between zones.
	await _carve_zone_exits()
	# 6. validate map is traversible.
	#if not _check_valid_map():
	# 6a. fuck it, always force a path through.
	await _force_carve_path()
	
	## Scatter when done
	await _scatter_items()
	
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
		var direction = randi_range(0, 3)
		
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

## Place prefabs in valid spaces in all zones.
func _place_prefabs_in_zones() -> void:
	var config: ZoneConfig
	var scene_prefab: PackedScene
	var prefab: TileMapLayer
	var is_valid_placement: bool = false
	
	var zone_rect: Rect2i
	
	for zone: ZoneData in zones:
		config = zone.zone_config
		scene_prefab = config.prefabs.pick_random()
		prefab = scene_prefab.instantiate() as TileMapLayer
		add_child(prefab)
		prefab.visible = false
		
		zone_rect = Rect2i(zone.position, zone.size)
		
		var prefab_rect:= prefab.get_used_rect()
		# Rect roughly in the center of the zone
		var placing_zone:= Rect2i(
			Vector2i.ZERO, 
			zone.size / 1.5
		)
		placing_zone.position = zone.position + (zone.size / 2) - placing_zone.size / 2
		# Try until we find a point the prefab rect can be placed in 
		# that is also contained entirely within the zone. 
		var rect_to_place: Rect2i
		Logger.log("Beginning Zone [%s] prefab point finding." % [
			config.zone_name
		], true, true)
		# Try up to 1000 times, lol
		for i in range(1000):
			# random point
			var offset:= Vector2i(randi_range(0, placing_zone.size.x), randi_range(0, placing_zone.size.y))
			rect_to_place = Rect2i(placing_zone.position + offset, prefab_rect.size)
			
			if not zone_rect.encloses(rect_to_place):
				continue
			
			is_valid_placement = true
			# Check it doesnt overlap any other prefabs
			for rect: Rect2i in all_prefab_rects:
				if rect_to_place.intersects(rect):
					is_valid_placement = false
					break
			
			if not is_valid_placement:
				#Logger.log("[Attempt %s] Zone %s cannot enclose %s, retrying." % [i, zone_rect, rect_to_place], true, true)
				continue
			
			Logger.log("[Attempt %s] Zone %s encloses %s." % [i, zone_rect, rect_to_place], true, true)
			break
		
		## If still not valid, just slap it in the center
		if not is_valid_placement:
			Logger.error(
				TextHelper.format_color("Failed to find position, defaulting.", ColorLookup.ERROR),
				true
			)
			rect_to_place = Rect2i(zone_rect.get_center() - prefab_rect.size / 2, prefab_rect.size)
		
		# Copy over all the prefab info into the zone.
		Logger.log("Beginning prefab placement.", true, true)
		await _copy_tilemap_to_other(prefab, tilemap_target, rect_to_place.position)
		# Save boss arenas
		if prefab is Prefab:
			if prefab.type == Prefab.Type.ARENA:
				self.boss_arena_data = prefab.data.duplicate(true)
				self.boss_arena_data["rect"] = Rect2i(rect_to_place)
		
		all_prefab_rects.append(rect_to_place.grow(2))
		prefab.queue_free()

## Place all campfires.
func _place_campfires() -> void:
	# Starter zone
	var zone: ZoneData = zones.front()
	var prefab_campfire: PackedScene = prefab_campfires.pick_random()
	var prefab:= prefab_campfire.instantiate() as TileMapLayer
	add_child(prefab)
	prefab.visible = false
	
	var prefab_rect:= prefab.get_used_rect()
	# Anywhere within the zone
	var placing_zone:= Rect2i(
		Vector2i.ZERO, 
		zone.size / 1.25
	)
	placing_zone.position = zone.position + (zone.size / 2) - placing_zone.size / 2
	
	# Try until we find a point the prefab rect can be placed in 
	# that is also contained entirely within the zone. 
	var rect_to_place: Rect2i
	var zone_rect:= Rect2i(zone.position, zone.size)
	Logger.log("Beginner Campfire point finding.", true, true)
	
	# Try up to 1000 times, lol
	for i in range(1000):
		# random point in `placing_zone`
		var offset:= Vector2i(randi_range(0, placing_zone.size.x), randi_range(0, placing_zone.size.y))
		rect_to_place = Rect2i(placing_zone.position + offset, prefab_rect.size)
		
		if zone_rect.encloses(rect_to_place):
			Logger.log("[Attempt %s] Zone %s encloses %s." % [i, zone_rect, rect_to_place], true, true)
			break
		
		#Logger.log("[Attempt %s] Zone %s cannot enclose %s, retrying." % [i, zone_rect, rect_to_place], true, true)
	
	# Copy over all the prefab info into the zone.
	Logger.log("Beginning campfire placement at %s." % rect_to_place.position, true, true)
	await _copy_tilemap_to_other(prefab, tilemap_target, rect_to_place.position)
	# Save this
	first_campfire_rect = rect_to_place
	all_prefab_rects.append(rect_to_place.grow(5))
	
	prefab.queue_free()

## Place a bunch of items, at least and up to 2 at each prefab.
func _scatter_items() -> void:
	var _pos: Vector2i 
	var tile_data: TileData
	for prefab_rect: Rect2i in all_prefab_rects:
		for i in range(randi_range(1, 2)):
			while true:
				_pos = Vector2i(randi_range(0, prefab_rect.size.x), randi_range(0, prefab_rect.size.y))
				tile_data = tilemap_target.get_cell_tile_data(prefab_rect.position + _pos)
				if not tile_data:
					continue
				
				if tile_data.get_custom_data("wfc_road") == true:
					break
			
			tilemap_target.set_cell(prefab_rect.position + _pos, 1, TileLookup.CHEST)

## Copy all tiles
func _copy_tilemap_to_other(from_tilemap: TileMapLayer, to_tilemap: TileMapLayer, offset:= Vector2i.ZERO) -> void:
	for coords: Vector2i in from_tilemap.get_used_cells():
		var source_id:= from_tilemap.get_cell_source_id(coords)
		var atlas_coord:= from_tilemap.get_cell_atlas_coords(coords)
		to_tilemap.set_cell(coords + offset, source_id, atlas_coord)
		
		if source_id == 0:
			print(coords+offset)
		
		if render_in_progress:
			camera.global_position = to_tilemap.to_global(to_tilemap.map_to_local(coords + offset))
			await get_tree().create_timer(0.05).timeout

## Surround each zone with trees as a guaranteed border.
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

## Run WFC to populate each area.
func _run_wfc_trees() -> void:
	for zone: ZoneData in zones:
		#var wfc_trees:= await _create_wfc(zone)
		var wfc_trees: WFC2DGenerator = load("res://maps/generation/wfc_configs/trees_wfc.tscn").instantiate()
		add_child(wfc_trees)
		wfc_trees.target = wfc_trees.get_path_to(tilemap_target)
		wfc_trees.rect = Rect2i(zone.position, zone.size)
		
		if not wfc_trees.is_node_ready():
			await wfc_trees.ready
		
		Logger.log("Running WFC for tree and floor placement in Zone [%s]." % zone.zone_config.zone_name, true, true)
		
		wfc_trees.start()
		await wfc_trees.done
		Logger.log("WFC in Zone [%s] completed." % zone.zone_config.zone_name, true, true)
		
		wfc_trees.queue_free()
		await get_tree().process_frame

## Carve paths from zone to zone.
func _carve_zone_exits() -> void:
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

## See if you can get from one zone to another.
func _check_valid_map() -> bool:
	_set_up_astar()
	
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

## Forcefully carve at least 1 path from prefab to prefab.
func _force_carve_path() -> void:
	var _temp_astar = AStarGrid2D.new()
	_temp_astar.region = tilemap_target.get_used_rect()
	_temp_astar.cell_size = Vector2i(8, 8)
	_temp_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_temp_astar.update()
	
	_temp_astar.fill_solid_region(tilemap_target.get_used_rect())
	
	var atlas_coord: Vector2i
	for coord: Vector2i in tilemap_target.get_used_cells():
		atlas_coord = tilemap_target.get_cell_atlas_coords(coord)
		if atlas_coord in TileLookup.FLOOR:
			_temp_astar.set_point_solid(coord, false)
			_temp_astar.set_point_weight_scale(coord, 1)
		elif atlas_coord == TileLookup.ARENA_TRIGGER || atlas_coord == TileLookup.ARENA_ENTRANCE:
			_temp_astar.set_point_solid(coord, false)
			_temp_astar.set_point_weight_scale(coord, 1)
		elif atlas_coord in TileLookup.TREES:
			_temp_astar.set_point_solid(coord, false)
			_temp_astar.set_point_weight_scale(coord, 10.0)
	
	var cur_rect: Rect2i
	var next_rect: Rect2i
	var points: PackedVector2Array
	
	for i in range(all_prefab_rects.size() - 1):
		cur_rect = all_prefab_rects[i]
		next_rect = all_prefab_rects[i+1]
		
		points = _temp_astar.get_id_path(cur_rect.get_center(), next_rect.get_center())
		#Logger.log("All points: %s" % points, true, true)
		for point: Vector2i in points:
			atlas_coord = tilemap_target.get_cell_atlas_coords(point)
			if atlas_coord in TileLookup.TREES:
				tilemap_target.set_cell(point, 1, TileLookup.GENERIC_FLOOR)
				_temp_astar.set_point_weight_scale(point, 1.0)
			
			if render_in_progress:
				camera.global_position = _temp_astar.get_point_position(point)
				await get_tree().create_timer(0.05).timeout

## Clean up all excess walls.
func _clean_up_walls() -> void:
	for coord: Vector2i in tilemap_target.get_used_cells_by_id(1, Vector2i(0, 9)):
		var surrounding:= tilemap_target.get_surrounding_cells(coord)
		var cell_types:= surrounding.map(
			func(element: Vector2i):
				return tilemap_target.get_cell_atlas_coords(element)
		)
		if not Vector2i(0, 9) in cell_types:
			tilemap_target.set_cell(coord, 1, TileLookup.GENERIC_FLOOR)
			
			if render_in_progress:
				await get_tree().create_timer(0.05).timeout
				camera.global_position = tilemap_target.to_global(tilemap_target.map_to_local(coord))




# Helper to automatically set up WFC.
func _create_wfc() -> WFC2DGenerator:
	var wfc_trees:= WFC2DGenerator.new()
	
	wfc_trees.positive_sample = wfc_trees.get_path_to($Trees/TreesSample)
	wfc_trees.negative_sample = wfc_trees.get_path_to($Trees/TreesNegative)
	
	wfc_trees.precondition = _precondition
	wfc_trees.use_multithreading = true
	
	var _solver:= WFCSolverSettings.new()
	_solver.require_backtracking = true
	wfc_trees.solver_settings = _solver
	
	if render_in_progress:
		wfc_trees.render_intermediate_results = true
	
	return wfc_trees

# Helper to set up astar.
func _set_up_astar() -> void:
	_astar = AStarGrid2D.new()
	_astar.region = tilemap_target.get_used_rect()
	_astar.cell_size = Vector2i(8, 8)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()
	_astar.fill_solid_region(tilemap_target.get_used_rect())
	
	var atlas_coord: Vector2i
	for coord: Vector2i in tilemap_target.get_used_cells():
		atlas_coord = tilemap_target.get_cell_atlas_coords(coord)
		if atlas_coord in TileLookup.FLOOR:
			_astar.set_point_solid(coord, false)
		elif atlas_coord == TileLookup.ARENA_TRIGGER || atlas_coord == TileLookup.ARENA_ENTRANCE:
			_astar.set_point_solid(coord, false)


