class_name TileDefinition extends Resource

## Name of this tile.
@export var name: String = ""
## Graphics component.
@export var graphic: Graphics

## Whether this tile can be walked on under normal circumstances.
@export var is_walkable: bool = true
## Whether this tile can be seen through under normal circumstances.
@export var is_transparent: bool = true

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = {
		"name": name,
		"graphic": graphic.serialize(),
		
		"is_walkable": is_walkable,
		"is_transparent": is_transparent,
	}
	return data

func deserialize(data: Dictionary) -> void:
	self.name = data["name"]
	
	self.graphic = Graphics.new()
	self.graphic.deserialize(data["graphic"])
	
	self.is_walkable = data["is_walkable"]
	self.is_transparent = data["is_transparent"]
#endregion

static func create(_name: String, _path: String, _render_order: int, _modulate:= Color.WHITE) -> TileDefinition:
	var d:= TileDefinition.new()
	d.name = _name
	d.graphic = Graphics.create(_path, _render_order, _modulate)
	return d

func _to_string() -> String:
	return name
