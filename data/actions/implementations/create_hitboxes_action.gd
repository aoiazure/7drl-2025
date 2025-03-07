class_name EACreateHitboxesAction extends EAction

const SCENE:= preload("res://entities/subtypes/hitbox.tscn")

var all_grid_positions: Array[Vector2i] = []
var time_to_kill: int
var affiliation: Affinity.Affiliation
var override_energy: int = -1

func execute() -> EActionResult:
	var actor_energy: Energy = actor.get_component_or_null(Components.ENERGY)
	var hitbox_speed: int = 90
	if actor_energy and override_energy < 0:
		hitbox_speed = ceili(actor_energy.speed * 1.05)
		actor_energy.current_energy = -hitbox_speed * time_to_kill - 5
	elif override_energy >= 0:
		actor_energy.current_energy = override_energy
	
	var idx: int = 0
	for grid_position: Vector2i in all_grid_positions:
		if not actor.map_data.tile_data.has(grid_position):
			continue
		
		var hitbox:= Hitbox.create_hitbox(time_to_kill, 1, hitbox_speed, self.affiliation)
		hitbox.map_data = actor.map_data
		# Set name to its source
		hitbox.entity_name = actor.entity_name
		actor.map_data.add_entity_to_tile_at_position(hitbox, grid_position)
		actor.reset_physics_interpolation()
		actor.id += idx
		idx += 1
	
	Logger.log("Created %s hitboxes!" % all_grid_positions.size(), true, true)
	return EActionResult.new(true)

func undo() -> EActionResult:
	return null



func _init(_actor: Actor, _grid_positions: Array[Vector2i], 
			_time_to_kill: int, _override_energy: int = -1, _affiliation:= Affinity.Affiliation.NONE) -> void:
	actor = _actor
	all_grid_positions = _grid_positions
	time_to_kill = _time_to_kill
	override_energy = _override_energy
	affiliation = _affiliation


