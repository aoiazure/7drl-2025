extends Node2D

## The progenitor map data. All other map_data should be referencing this one.
@export var map_data: MapData

@export_group("References")
@export var tile_drawer: TileDrawer
@export var entity_holder: Node2D
@export var actor_helper: ActorHelper
@export var entity_action_handler: EntityActionHandler
@export var map_helper: MapHelper
@export var logger: Logger
@export var turn_scheduler: TurnScheduler



func _ready() -> void:
	_setup()
	_test_move()



func _setup() -> void:
	tile_drawer.map_data = map_data
	actor_helper.map_data = map_data
	entity_action_handler.map_data = map_data
	map_helper.map_data = map_data
	turn_scheduler.setup(map_data)


func _test_move() -> void:
	var a1:= Actor.create()
	a1.is_player = true
	a1.entity_name = "Banana Bread"
	a1.grid_position = Vector2i(5, 3)
	a1.blocks_movement = true
	
	a1.controller = PMoveController.new()
	a1.graphics = Graphics.create("res://assets/sprites/player/player_basic_frames.tres", RenderOrder.ACTOR)
	a1.components[Components.Energy] = Energy.create(1, 0)
	
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
	print(a2.controller.get_script().get_global_name())
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








