## Component representing an Entity's visuals.
class_name Graphics extends Resource

@export_file("*.png", "*.tres") var sprite_path: String = ""
@export var modulate: Color = Color.WHITE
@export var render_order: int = RenderOrder.TILE

var texture

#region Save and Load
func serialize() -> Dictionary:
	var data: Dictionary = {
		"sprite_path": sprite_path,
		"modulate": JSON.from_native(modulate),
		"render_order": render_order,
	}
	return data

func deserialize(data: Dictionary) -> void:
	self.sprite_path = data["sprite_path"]
	if not self.sprite_path.is_empty():
		texture = load(sprite_path)
	
	self.modulate = JSON.to_native(data["modulate"])
	self.render_order = data["render_order"]
#endregion

static func create(_path: String, _render_order: int, _modulate: Color = Color.WHITE) -> Graphics:
	var g:= Graphics.new()
	g.sprite_path = _path
	g.modulate = _modulate
	g.render_order = _render_order
	g.texture = load(g.sprite_path)
	
	return g


