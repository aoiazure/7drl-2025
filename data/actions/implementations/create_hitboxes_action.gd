class_name EACreateHitboxesAction extends EAction

const SCENE:= preload("res://entities/subtypes/hitbox.tscn")

var all_grid_positions: Array[Vector2i] = []
var time_to_kill: int
var affiliation: Affinity.Affiliation


func execute() -> EActionResult:
	for grid_position: Vector2i in all_grid_positions:
		var hitbox:= Hitbox.create_hitbox(time_to_kill, 1, self.affiliation)
		hitbox.map_data = actor.map_data
		actor.map_data.add_entity_to_tile_at_position(hitbox, grid_position)
		actor.reset_physics_interpolation()
	
	Logger.log("Created %s hitboxes!" % all_grid_positions.size(), true, true)
	var energy: Energy = actor.get_component_or_null(Components.ENERGY)
	if energy:
		energy.current_energy = -10
	return EActionResult.new(true)

func undo() -> EActionResult:
	return null



func _init(_actor: Actor, _grid_positions: Array[Vector2i], 
			_time_to_kill: int, _affiliation:= Affinity.Affiliation.NONE) -> void:
	actor = _actor
	all_grid_positions = _grid_positions
	time_to_kill = _time_to_kill
	affiliation = _affiliation


