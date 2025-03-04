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



func _ready() -> void:
	_setup()



func _setup() -> void:
	map_data.actors_changed.connect(_on_map_data_actors_changed)
	
	tile_drawer.map_data = map_data
	actor_helper.map_data = map_data
	entity_action_handler.map_data = map_data
	map_helper.map_data = map_data
	turn_scheduler.setup(map_data)
	
	map_gen.generation_finished.connect(_convert_tilemap_to_map_data)
	map_gen.generate()

func _on_map_data_actors_changed() -> void:
	for actor: Actor in map_data.actors:
		if not actor.is_inside_tree():
			entity_holder.add_child(actor)
			actor._set_grid_position(actor.grid_position)
			actor.reset_physics_interpolation()

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
	
	var a1:= Actor.create()
	a1.is_player = true
	a1.entity_name = "Banana Bread"
	a1.grid_position = Rect2i(map_gen.zones[0].position, map_gen.zones[0].size).get_center() + offset
	a1.blocks_movement = true
	
	a1.controller = PMoveController.new()
	a1.graphics = Graphics.create("res://assets/sprites/player/player_basic_frames.tres", RenderOrder.ACTOR)
	a1.add_component(Components.ENERGY, Energy.create(10, 0))\
		.add_component(Components.FIGHTER, Fighter.create(1, 10, 1))\
		.add_component(Components.STAMINA, Stamina.create(3, 5))\
		.add_component(Components.MANA, Mana.create(5, 5))\
		.add_component(Components.FOV, Fov.create(12))
	
	a1.deserialize(a1.serialize())
	
	a1.map_data = map_data
	map_data.add_entity_to_tile_at_position(a1, a1.grid_position)
	map_data.player = a1
	
	_set_up_player_signals(a1)
	
	var e1:= Actor.create()
	e1.entity_name = "Security Camera"
	e1.grid_position = Rect2i(map_gen.zones[0].position, map_gen.zones[0].size).get_center() + Vector2i.RIGHT + offset
	e1.blocks_movement = true
	
	e1.controller = EAlertController.new()
	e1.graphics = Graphics.create(
		"res://assets/sprites/player/player_basic_frames.tres", RenderOrder.ACTOR, Color.RED
	)
	e1.add_component(Components.ENERGY, Energy.create(50, 0))\
		.add_component(Components.FIGHTER, Fighter.create(5, 5, 0))\
		.add_component(Components.FOV, Fov.create(6))
	
	e1.deserialize(e1.serialize())
	
	e1.map_data = map_data
	map_data.add_entity_to_tile_at_position(e1, e1.grid_position)
	
	tile_drawer.queue_redraw()
	ActorHelper.instance.set_up_astar()
	map_data.get_all_walkable_cells_from_position(a1.grid_position, true)



func _set_up_player_signals(player: Actor) -> void:
	var fighter: Fighter = player.get_component_or_null(Components.FIGHTER)
	$CanvasLayer/VBoxContainer/HealthLabel.text = "HP: %2d/%2d" % [fighter.cur_health, fighter.max_health]
	fighter.health_changed.connect(
		func(_cur, _max):
			$CanvasLayer/VBoxContainer/HealthLabel.text = "HP: %2d/%2d" % [_cur, _max]
	)
	
	var stamina: Stamina = player.get_component_or_null(Components.STAMINA)
	$CanvasLayer/VBoxContainer/StaminaLabel.text = "SP: %2d/%2d" % [stamina.cur_stamina, stamina.max_stamina]
	stamina.stamina_changed.connect(
		func(_cur, _max):
			$CanvasLayer/VBoxContainer/StaminaLabel.text = "SP: %2d/%2d" % [_cur, _max]
	)
	
	var mana: Mana = player.get_component_or_null(Components.MANA)
	$CanvasLayer/VBoxContainer/ManaLabel.text = "MP: %2d/%2d" % [mana.cur_mana, mana.max_mana]
	mana.mana_changed.connect(
		func(_cur, _max):
			$CanvasLayer/VBoxContainer/ManaLabel.text = "SP: %2d/%2d" % [_cur, _max]
	)
	
	$CanvasLayer/VBoxContainer.show()
	
	player.died.connect(
		func(_a: Actor):
			$CanvasLayer/DeathLabel.show()
	)
	
	player.fov_updated.connect(
		func(fov: Fov):
			call_thread_safe(&"_on_player_fov_updated", fov)
	)

## Hide actors as needed.
func _on_player_fov_updated(fov: Fov) -> void:
	for actor: Actor in map_data.actors:
		actor.visible = actor.grid_position in fov.tiles_currently_visible



func _test_move() -> void:
	var a1:= Actor.create()
	a1.is_player = true
	a1.entity_name = "Banana Bread"
	a1.grid_position = Vector2i(5, 3)
	a1.blocks_movement = true
	
	a1.controller = PMoveController.new()
	a1.graphics = Graphics.create("res://assets/sprites/player/player_basic_frames.tres", RenderOrder.ACTOR)
	a1.components[Components.ENERGY] = Energy.create(1, 0)
	
	a1.map_data = map_data
	
	for x in range(map_data.grid_definition.map_size.x):
		for y in range(map_data.grid_definition.map_size.y):
			map_data.tile_data[Vector2i(x, y)] = Tile.create(
				TileDefinition.create("void", "res://assets/sprites/tiles/tile_basic.tres", 0, Color.DIM_GRAY)
			)
	
	var a2:= Actor.create()
	a2.name = "Banana"
	entity_holder.add_child(a2)
	a2.map_data = map_data
	a2.deserialize(JSON.parse_string(JSON.stringify(a1.serialize())))
	map_data.add_entity_to_tile_at_position(a2, a2.grid_position)
	map_data.player = a2


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








