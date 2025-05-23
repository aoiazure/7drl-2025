class_name TileDefinition extends Resource

static var Lookup: Dictionary[String, TileDefinition] = {
	
}

## Name of this tile.
@export var name: String = ""
## Graphics component.
@export var graphics: Graphics

## Whether this tile can be walked on under normal circumstances.
@export var is_walkable: bool = true
## Whether this tile can be seen through under normal circumstances.
@export var is_transparent: bool = true

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = {
		"name": name,
		"graphics": graphics.serialize(),
		
		"is_walkable": is_walkable,
		"is_transparent": is_transparent,
	}
	return data

func deserialize(data: Dictionary) -> void:
	self.name = data["name"]
	
	self.graphics = Graphics.new()
	self.graphics.deserialize(data["graphics"])
	
	self.is_walkable = data["is_walkable"]
	self.is_transparent = data["is_transparent"]
#endregion

static func create(_name: String, _path: String, _render_order: int, _modulate:= Color.WHITE) -> TileDefinition:
	var d:= TileDefinition.new()
	d.name = _name
	d.graphics = Graphics.create(_path, _render_order, _modulate)
	
	return d

func _to_string() -> String:
	return name
