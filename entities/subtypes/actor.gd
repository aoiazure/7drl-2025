class_name Actor extends Entity

signal died(actor: Actor)
signal fov_updated(fov_component: Fov)

const ACTOR_SCENE:= preload("res://entities/subtypes/actor.tscn")

var mark_for_freeing: bool = false
var is_player: bool = false

## The controller that dictates actions.
var controller: EController :
	set(val):
		controller = val
		controller.on_set_active(self)

static func create() -> Actor:
	var a: Actor = ACTOR_SCENE.instantiate()
	return a



#region Saving and Loading
func serialize() -> Dictionary:
	var data:= super()
	var new_data: Dictionary = {
		"type": "Actor",
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
	if self.is_player:
		var cam:= Camera2D.new()
		cam.position_smoothing_enabled = false
		add_child(cam)
	
	# Controller
	if data.has("controller"):
		var _controller_data: Dictionary = data["controller"]
		controller = EController.Lookup[_controller_data["name"]]
		controller.deserialize(_controller_data)
	
	var fov: Fov = get_component_or_null(Components.FOV)
	if fov:
		fov.updated.connect(
			func():
				print("called")
				call_deferred("emit_signal", &"fov_updated", fov)
		)
	

#endregion



func _set_grid_position(val: Vector2i) -> void:
	var _old_position: Vector2i = grid_position
	super(val)
	
	var fov: Fov = get_component_or_null(Components.FOV)
	if fov and map_data:
		fov.update_fov(map_data, grid_position)
	
	if not is_inside_tree():
		return
	
	# Animate movement
	#var tween:= create_tween()
	#var new_position: Vector2 = map_data.grid_definition.calculate_map_position_centered(val)
	#tween.tween_property(self, "global_position", new_position, 0.1)
	#tween.play()
	global_position = map_data.grid_definition.calculate_map_position_centered(val)


func _to_string() -> String:
	var msg:=  "%s%s" % [
		"", #"[%s]" %id,
		entity_name,
	]
	var energy: Energy = get_component_or_null(Components.ENERGY)
	if energy:
		msg += " | %s/%s" % [energy.current_energy, energy.required_to_act]
	return msg




