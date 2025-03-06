extends Node2D

## The progenitor map data. All other map_data should be referencing this one.
@export var map_data: MapData

@export_group("References")
@export var map_gen: MapGenerator
@export var tile_drawer: TileDrawer
@export var entity_holder: Node2D
@export var actor_helper: ActorHelper
@export var entity_action_handler: EntityActionHandler
@export var map_helper: MapHelper
@export var logger: Logger
@export var turn_scheduler: TurnScheduler

@export_subgroup("User Interface")
@export var inventory_menu: InventoryMenu
@export var layer_loading_screen: CanvasLayer
@export var layer_game_ui: CanvasLayer
@export var label_health: Label
@export var label_stamina: Label
@export var label_mana: Label
@export var label_death_msg: Label

var _spawn_campfire_pos: Vector2i

func _ready() -> void:
	_setup()



func _setup() -> void:
	map_data.entity_needs_adding_to_tree.connect(_on_map_data_entity_tree_add)
	
	tile_drawer.map_data = map_data
	actor_helper.map_data = map_data
	entity_action_handler.map_data = map_data
	map_helper.map_data = map_data
	turn_scheduler.setup(map_data)
	
	map_gen.generate()
	await map_gen.generation_finished
	
	_convert_tilemap_to_map_data()
	_place_entities()
	
	tile_drawer.queue_redraw()
	ActorHelper.instance.set_up_astar()
	layer_loading_screen.hide()

func _on_map_data_entity_tree_add(entity: Entity) -> void:
	if not entity.is_inside_tree():
		entity_holder.add_child(entity)
		entity._set_grid_position(entity.grid_position)
		entity.reset_physics_interpolation()
	
	


func _convert_tilemap_to_map_data() -> void:
	var tilemap: TileMapLayer = map_gen.tilemap_target
	var tile_rect:= tilemap.get_used_rect()
	var offset: Vector2i = -tile_rect.position
	
	map_data.grid_definition.map_size = tile_rect.size
	
	for coord: Vector2i in tilemap.get_used_cells():
		var atlas_coord:= tilemap.get_cell_atlas_coords(coord)
		coord += offset
		# Floor/flora
		if TileLookup.FLOOR.keys().has(atlas_coord):
			var td:= TileDefinition.create("floor", TileLookup.FLOOR[atlas_coord].resource_path, 0, Color.SLATE_GRAY)
			map_data.tile_data[coord] = Tile.create(td)
		# Trees
		elif TileLookup.TREES.keys().has(atlas_coord):
			var td:= TileDefinition.create("tree", TileLookup.TREES[atlas_coord].resource_path, 0, Color.DARK_GREEN)
			td.is_walkable = false
			td.is_transparent = false
			map_data.tile_data[coord] = Tile.create(td)
		elif TileLookup.WALLS.keys().has(atlas_coord):
			var td:= TileDefinition.create("tree", TileLookup.WALLS[atlas_coord].resource_path, 0, Color.DARK_GRAY)
			td.is_walkable = false
			td.is_transparent = false
			map_data.tile_data[coord] = Tile.create(td)
		elif atlas_coord == TileLookup.CAMPFIRE:
			_place_campfire(coord, offset)
		elif atlas_coord == TileLookup.CHEST:
			_place_chest(coord)
		elif atlas_coord == TileLookup.ENTRANCE:
			pass
		elif atlas_coord == TileLookup.ARENA_TRIGGER:
			pass

func _place_chest(coord: Vector2i) -> void:
	var td:= TileDefinition.create(
		"floor", TileLookup.FLOOR[TileLookup.GENERIC_FLOOR].resource_path,
		0, Color.SLATE_GRAY
	)
	var tile:= Tile.create(td)
	map_data.tile_data[coord] = tile
	
	## pick and place a random item
	var item_key: StringName = Item.Factories.keys().pick_random()
	var item: Item = Item.Factories[item_key].copy()
	item.map_data = map_data
	map_data.add_entity_to_tile_at_position(item, coord)
	
	print("placed %s at %s" % [item.entity_name, coord])
	
	## TODO: implement chests here.
	#var chest: Chest = Chest.SCENE.instantiate()
	#chest.map_data = map_data
	#map_data.add_entity_to_tile_at_position(chest, coord)

func _place_campfire(coord: Vector2i, offset: Vector2i) -> void:
	var td:= TileDefinition.create(
		"floor", TileLookup.FLOOR[TileLookup.GENERIC_FLOOR].resource_path,
		0, Color.SLATE_GRAY
	)
	var tile:= Tile.create(td)
	map_data.tile_data[coord] = tile
	
	var campfire: Campfire = Campfire.SCENE.instantiate()
	campfire.map_data = map_data
	map_data.add_entity_to_tile_at_position(campfire, coord)
	
	if map_gen.first_campfire_rect.has_point(coord - offset):
		_spawn_campfire_pos = coord






func _place_entities() -> void:
	## Calculate dijkstra once
	var dijkstra_result: Dictionary[Vector2i, int] = Dijkstra.calculate(
		_spawn_campfire_pos, [_spawn_campfire_pos],
		map_data.get_all_walkable_cells_from_position(_spawn_campfire_pos, true),
		Rect2i(Vector2i.ZERO, map_data.grid_definition.map_size)
	)
	
	_spawn_player(dijkstra_result)
	_spawn_enemies(dijkstra_result)

func _spawn_player(dijkstra: Dictionary[Vector2i, int]) -> void:
	var a1:= Actor.create()
	if SaveManager.player_data:
		a1.deserialize(SaveManager.player_data.serialize())
	else:
		a1.is_player = true
		a1.entity_name = "Banana Bread"
		a1.blocks_movement = true
		
		a1.controller = PMoveController.new()
		a1.add_component(Components.GRAPHICS, Graphics.create(
					"res://assets/sprites/player/player_basic_frames.tres", RenderOrder.ACTOR))\
			.add_component(Components.ENERGY, Energy.create(1, 2))\
			.add_component(Components.FIGHTER, Fighter.create(2, 1, 1, 1, 8))\
			.add_component(Components.STAMINA, Stamina.create(3, 5))\
			.add_component(Components.EQUIPMENT, Equipment.create({
				"Weapon": EquipmentSlot.create("Weapon", Items.Types.WEAPON),
				"Armor": EquipmentSlot.create("Armour", Items.Types.ARMOR),
			}))\
			.add_component(Components.MANA, Mana.create(3, 5))\
			.add_component(Components.FOV, Fov.create(12))
		
		a1.add_component(Components.INVENTORY, Inventory.create([
				Item.Factories[Items.HEALTH_FLASK].copy(),
				Item.Factories[Items.MANA_FLASK].copy(),
				Item.Factories[Items.ARMOUR_LEATHER].copy(),
			]
		))
		
		a1.deserialize(a1.serialize())
	
	## Spawn player near campfire.
	var valid_keys:= dijkstra.keys().filter(
		func(v: Vector2i):
			return dijkstra[v] <= 5
	)
	
	var player_spawn_point: Vector2i = valid_keys.pick_random()
	Logger.log("Spawned at %s relative to %s at distance %s." % [
		player_spawn_point, _spawn_campfire_pos, dijkstra[player_spawn_point]
	], true, true)
	
	a1.grid_position = player_spawn_point
	a1.map_data = map_data
	map_data.add_entity_to_tile_at_position(a1, a1.grid_position)
	map_data.player = a1
	
	_set_up_player_signals(a1)
	## Reupdate just in case.
	map_data.get_all_walkable_cells_from_position(a1.grid_position, true)


func _set_up_player_signals(player: Actor) -> void:
	var fighter: Fighter = player.get_component_or_null(Components.FIGHTER)
	label_health.text = "HP: %2d/%2d" % [fighter.cur_health, fighter.max_health]
	fighter.health_changed.connect(
		func(_fighter: Fighter):
			label_health.text = "HP: %2d/%2d" % [_fighter.cur_health, _fighter.max_health]
	)
	fighter.stats_changed.connect(
		func(_fighter: Fighter):
			label_health.text = "HP: %2d/%2d" % [_fighter.cur_health, _fighter.max_health]
	)
	
	var stamina: Stamina = player.get_component_or_null(Components.STAMINA)
	label_stamina.text = "SP: %2d/%2d" % [stamina.cur_stamina, stamina.max_stamina]
	stamina.stamina_changed.connect(
		func(_cur, _max):
			label_stamina.text = "SP: %2d/%2d" % [_cur, _max]
	)
	
	var mana: Mana = player.get_component_or_null(Components.MANA)
	label_mana.text = "MP: %2d/%2d" % [mana.cur_mana, mana.max_mana]
	mana.mana_changed.connect(
		func(_cur, _max):
			label_mana.text = "MP: %2d/%2d" % [_cur, _max]
	)
	
	player.died.connect(
		func(_a: Actor):
			label_death_msg.show()
	)
	
	player.fov_updated.connect(
		func(fov: Fov):
			call_thread_safe(&"_on_player_fov_updated", fov)
	)
	
	## Show it
	layer_game_ui.show()


func _spawn_enemies(dijkstra: Dictionary[Vector2i, int]) -> void:
	var amount: int = randi_range(5, 8) + 1
	var spawned_locations: Array[Vector2i] = [_spawn_campfire_pos]
	
	var valid_keys:= dijkstra.keys().filter(
	func(v: Vector2i):
		return dijkstra[v] >= 15
	)
	
	for i in range(amount):
		var e1:= Actor.create()
		e1.entity_name = "Soldier"
		e1.blocks_movement = true
		
		
		e1.controller = EAlertController.new()
		e1.add_component(Components.GRAPHICS, Graphics.create(
				"res://assets/sprites/player/player_basic_frames.tres", RenderOrder.ACTOR, Color.RED
			))\
			.add_component(Components.ENERGY, Energy.create(1, 5))\
			.add_component(Components.FIGHTER, Fighter.create(2, 2, 0, 0, 4))\
			.add_component(Components.FOV, Fov.create(6))
		
		e1.deserialize(e1.serialize())
		
		e1.map_data = map_data
		
		#var valid_keys:= dijkstra.keys().filter(
		#func(v: Vector2i):
			#return dijkstra[v] >= 15
		#)
		
		var spawn_location: Vector2i = valid_keys.pick_random()
		map_data.add_entity_to_tile_at_position(e1, spawn_location)
		
		spawned_locations.append(spawn_location)
		
		#dijkstra = Dijkstra.calculate(
			#_spawn_campfire_pos, spawned_locations,
			#map_data.get_all_walkable_cells_from_position(_spawn_campfire_pos),
			#Rect2i(Vector2i.ZERO, map_data.grid_definition.map_size)
		#)





## Hide actors as needed.
func _on_player_fov_updated(fov: Fov) -> void:
	for entity: Entity in map_data.entities:
		entity.visible = entity.grid_position in fov.tiles_currently_visible



func _test() -> void:
	var a1:= Actor.create()
	a1.entity_name = "Banana Bread"
	a1.grid_position = Vector2i(32, 3)
	a1.blocks_movement = true
	
	a1.controller = PMoveController.new()
	a1.graphics = Graphics.create("res://assets/sprites/player/player_basic_frames.tres", RenderOrder.ACTOR)
	a1.energy = Energy.create(1, 0)
	
	a1.map_data = map_data
	
	var json = JSON.new()
	var err = json.parse(JSON.stringify(a1.serialize()))
	if err:
		printt(json.get_error_line(), json.get_error_message())
		return
	
	#print(json.data)
	
	var a2:= Actor.create()
	a2.deserialize(json.data)
	a2.map_data = map_data
	#print(a2.controller.get_script().get_global_name())
	#print(e1.entity_name)
	
	var tile:= Tile.create(TileDefinition.create("void", "res://assets/sprites/tiles/tile_basic.tres", 0))
	tile.add_entity(a2)
	err = json.parse(JSON.stringify(tile.serialize()))
	if err:
		printt(json.get_error_line(), json.get_error_message())
		return
	
	#print(json.data)
	
	var t1:= Tile.new()
	t1.deserialize(json.data)
	printt("Tile name:", t1.definition.name.capitalize(), t1.entities.front().entity_name)
	
	var m1 = MapData.new()
	m1.tile_data[Vector2i(3, 5)] = t1
	err = json.parse(JSON.stringify(m1.serialize()))
	if err:
		printt(json.get_error_line(), json.get_error_message())
		return
	
	#print(json.data)
	
	var m2 = MapData.new()
	m2.deserialize(json.data)
	printt("M2:", m2.tile_data)








