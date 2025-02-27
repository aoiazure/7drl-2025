class_name Tile extends Resource


## Definition that tells what this tile actually is.
var definition: TileDefinition
var entities: Array[Entity] = []

#region Saving and Loading
func serialize() -> Dictionary:
	# Convert all entities to string version of dicts
	var e_data: String = "["
	for e: Entity in entities:
		e_data += JSON.stringify(e.serialize())
		if e != entities.back():
			e_data += ","
	e_data += "]"
	
	var data: Dictionary = {
		"definition": definition.serialize(),
		"entities": e_data,
	}
	return data

func deserialize(data: Dictionary) -> void:
	self.definition = TileDefinition.new()
	self.definition.deserialize(data["definition"])
	
	var _parsed = JSON.parse_string(data["entities"])
	#printt("Tile parsed:", _parsed)
	var _entities: Array[Entity] = []
	for _save_data: Dictionary in _parsed:
		var e: Entity = Entity.new()
		e.deserialize(_save_data)
		_entities.append(e)
	
	self.entities = _entities
#endregion

## Sort the list of entities by render order.
func sort_by_render_order(descending: bool = false) -> void:
	entities.sort_custom(
		func(a: Entity, b: Entity):
				return (a.render_order > b.render_order) if descending else (a.render_order < b.render_order)
	)

## Returns the first item in this tile, or null if none.
func get_first_item() -> Item:
	var item: Item = null
	for entity: Entity in entities:
		if entity is Item:
			item = entity as Item
	
	return item

## Returns whether this tile contains an item.
func has_item() -> bool:
	for e: Entity in entities:
		if e is Item:
			return true
	
	return false

## Returns whether a specific tile is able to be walked through.
func is_walkable() -> bool:
	var is_possible:= false
	if not definition.is_walkable:
		return false
	if entities.is_empty():
		is_possible = true
	else:
		var can_walk: bool = true
		for e: Entity in entities:
			if e.blocks_movement:
				can_walk = false
				break
		is_possible = can_walk
	
	return is_possible



func add_entity(entity: Entity) -> void:
	entities.append(entity)
	sort_by_render_order()

func remove_entity(entity: Entity) -> void:
	entities.erase(entity)


func _to_string() -> String:
	var list_entities: String = ""
	sort_by_render_order()
	
	for i in range(entities.size()):
		list_entities += "%s%s" % [
			entities[i].entity_name,
			", " if i < entities.size() - 1 else "."
		]
	if list_entities.is_empty():
		list_entities = "None."
	
	var desc: String = "%s|%s" % [
		definition.to_string().capitalize(), list_entities
	]
	return desc


static func create(_definition: TileDefinition) -> Tile:
	var t:= Tile.new()
	t.definition = TileDefinition.create(
		_definition.name, 
		_definition.graphic.sprite_path,
		_definition.graphic.render_order,
		_definition.graphic.modulate,
	)
	return t


