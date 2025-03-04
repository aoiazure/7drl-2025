class_name ZoneConfig extends Resource

@export var zone_name: String = "Zone"
@export var base_size: Vector2i
@export_range(0.0, 2, 0.01, "or_greater") var width_scalability: float = 0.0
@export_range(0.0, 2, 0.01, "or_greater") var height_scalability: float = 0.0

@export var prefabs: Array[PackedScene] = []

func roll_size() -> Vector2i:
	var size:= base_size
	
	size.x = floori(size.x * (1.0 + randf_range(-1, 1) * width_scalability))
	size.y = floori(size.y * (1.0 + randf_range(-1, 1) * height_scalability))
	
	return size
