class_name MapData extends Resource

signal actors_changed

@export var grid_definition: GridDefinition

var rng_seed: int
var tile_data: Dictionary[Vector2i, Tile] = {}
var actors: Array[Actor] = []
var player: Actor

#var is_cursor_active: bool = false
#var cursor_rect: Rect2i
#var cursor_in_range: bool = false



func add_entity_to_tile_at_position(entity: Entity, position: Vector2i) -> void:
	entity.grid_position = position
	tile_data[position].entities.append(entity)
	
	if entity is Actor:
		actors.append(entity)
		actors_changed.emit()

func remove_entity(entity: Entity) -> void:
	tile_data[entity.grid_position].entities.erase(entity)
	
	if entity is Actor:
		actors.erase(entity)
		actors_changed.emit()



#region Saving and Loading
func serialize() -> Dictionary:
	# Convert all tiles to string version of dicts
	
	var t_data: String = "{"
	for i: int in range(tile_data.size()):
		var pos: Vector2i = tile_data.keys()[i]
		var tile: Tile = tile_data[pos]
		var d: String = "\"%s\": %s" % [pos, JSON.stringify(tile.serialize())]
		t_data += d
		if i != (tile_data.size() - 1):
			t_data += ","
	t_data += "}"
	
	var data: Dictionary = {
		"rng_seed": rng_seed,
		"tile_data": t_data,
	}
	return data

func deserialize(data: Dictionary) -> void:
	self.rng_seed = int(data["rng_seed"])
	
	var json:= JSON.new()
	var err = json.parse(data["tile_data"])
	if err:
		printt(json.get_error_line(), json.get_error_message())
		return
	
	var temp_tile_data: Dictionary = json.data as Dictionary
	for i: int in range(temp_tile_data.size()):
		var key: String = temp_tile_data.keys()[i]
		var pos: Vector2i = str_to_var("Vector2i" + key)
		
		var tile: Tile = Tile.new()
		tile.deserialize(temp_tile_data[key])
		tile_data[pos] = tile
#endregion




