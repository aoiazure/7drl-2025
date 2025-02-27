class_name Actor extends Entity

const SCENE:= preload("res://entities/subtypes/actor.tscn")

@export var is_player: bool = false

## The controller that dictates actions.
var controller: EController
#var energy: Energy

static func create() -> Actor:
	var a: Actor = SCENE.instantiate()
	return a



#region Saving and Loading
func serialize() -> Dictionary:
	var data:= super()
	var new_data: Dictionary = {
		"is_player": is_player,
	}
	
	if controller:
		data["controller"] = controller.serialize()
	
	# Merge with base serialize
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	
	self.is_player = data["is_player"]
	# Controller
	if data.has("controller"):
		var _controller_data: Dictionary = data["controller"]
		controller = EController.Lookup[_controller_data["name"]]
		controller.deserialize(_controller_data)

#endregion


func _set_grid_position(val: Vector2i) -> void:
	var _old_position: Vector2i = grid_position
	super(val)
	if not is_inside_tree():
		return
	
	#printt("%s set" % name, old_position, val)
	# Animate movement
	var tween:= create_tween()
	var new_position: Vector2 = map_data.grid_definition.calculate_map_position_centered(val)
	tween.tween_property(self, "global_position", new_position, 0.1)
	tween.play()



