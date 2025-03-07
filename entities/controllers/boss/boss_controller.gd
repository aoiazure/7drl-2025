class_name BossController extends EController

const BASIC_ATTACK_PATTERNS: Array[Array] = [
	#L  W  Time to kill
	[5, 2, 3],
	[5, 2, 2],
	[2, 3, 2],
]

const FRENZY_ATTACK_PATTERNS: Array[Array] = [
	#L  W  Time to kill
	[5, 2, 3],
	[5, 3, 2],
	[3, 3, 2],
	[5, 4, 3],
]

var fighter: Fighter
var target: Actor

var is_active: bool = false
var has_alerted: bool = false
var is_phase_two: bool = false

var _astar: AStarGrid2D = null
var _dijkstra: Dictionary[Vector2i, int] = {}
var _dijkstra_offset: Vector2i
var _arena_radius: int = 9

var _turns_til_can_explode: int = -1

func get_action(actor: Actor) -> EAction:
	if not is_active:
		return EARest.new(actor)
	
	assert(is_instance_valid(target), "BossController requires a target.")
	if not has_alerted and fighter.cur_health <= ceili(0.6 * fighter.max_health):
		Logger.log(TextHelper.format_color(
			TextHelper.format_dialogue("You are beginning to irritate me."), Color.ORANGE_RED
		), true)
		Logger.log(TextHelper.format_color(
			"Smoke begins to nip the edges of the arena...", Color.PALE_VIOLET_RED
		), true)
		has_alerted = true
	
	var action: EAction = _choose_action(actor)
	return action

## Pick an action
func _choose_action(actor: Actor) -> EAction:
	var action: EAction = EARest.new(actor)
	var rng:= RandomNumberGenerator.new()
	var distance_to_target: int = MapUtils.distance_to(actor.grid_position, target.grid_position)
	
	# phase change if eligible
	if fighter.cur_health <= floori(0.5 * fighter.max_health) and not is_phase_two:
		is_phase_two = true
		action = PhaseTwoAction.new(actor, actor.controller)
	# always move if too far
	elif distance_to_target > floori(_arena_radius / 1.5):
		action = _move_towards_target(actor)
	# healthy mode
	elif fighter.cur_health >= floori(0.75 * fighter.max_health):
		action = _healthy_pick(actor, rng, distance_to_target)
	# hurted
	else:
		action = _hurt_pick(actor, rng, distance_to_target)
	
	## Cooldown exploding
	_turns_til_can_explode = maxi(0, _turns_til_can_explode - 1)
	return action

func _healthy_pick(actor: Actor, rng: RandomNumberGenerator, distance_to_target: int) -> EAction:
	var action: EAction = null
	var roll:= rng.randi_range(0, 9)
	Logger.log("Distance: %s.\tRolled a %s." % [distance_to_target, roll], true, true)
	# 20 % chance to do AoE attack around self
	if roll >= 8 and distance_to_target <= 2 and _turns_til_can_explode <= 0:
		# Cooldown
		_turns_til_can_explode = 6
		
		var _attack: Array[Vector2i] = []
		var _position: Vector2i
		for x in range(-2, 3):
			for y in range(-2, 3):
				_position = actor.grid_position + Vector2i(x, y)
				if _position != actor.grid_position:
					_attack.append(_position)
		
		action = EACreateHitboxesAction.new(actor, _attack, 3, -1, Affinity.Affiliation.ENEMY)
	
	# 70% chance for basic attack when close
	elif roll >= 3 and distance_to_target <= 2:
		var _attack: Array = BASIC_ATTACK_PATTERNS.pick_random().duplicate()
		var _pattern:= Hitbox.generate_positions(actor.grid_position, target.grid_position, _attack[0], _attack[1])
		action = EACreateHitboxesAction.new(actor, _pattern, _attack[2], -1, Affinity.Affiliation.ENEMY)
	# Move towards target 70% of the time.
	elif roll >= 3 and distance_to_target > 1:
		action = _move_towards_target(actor)
	else:
		# Sometimes do nothing...
		action = EARest.new(actor)
	
	return action

func _hurt_pick(actor: Actor, rng: RandomNumberGenerator, distance_to_target: int) -> EAction:
	var action: EAction = null
	var roll: int = rng.randi_range(0, 9)
	
	# 30 % chance to do AoE attack around self
	if roll >= 7 and distance_to_target <= 2 and _turns_til_can_explode <= 0:
		# Cooldown
		_turns_til_can_explode = 3
		var explode_range: int = 3
		
		var _attack: Array[Vector2i] = []
		var _position: Vector2i
		for x in range(-explode_range, explode_range+1):
			for y in range(-explode_range, explode_range+1):
				_position = actor.grid_position + Vector2i(x, y)
				if _position != actor.grid_position:
					_attack.append(_position)
		
		action = EACreateHitboxesAction.new(actor, _attack, 3, -1, Affinity.Affiliation.ENEMY)
	# 40% chance for frenzy
	elif roll >= 6 and distance_to_target <= 2:
		var _attack: Array = FRENZY_ATTACK_PATTERNS.pick_random().duplicate()
		var _pattern:= Hitbox.generate_positions(actor.grid_position, target.grid_position, _attack[0], _attack[1])
		action = EACreateHitboxesAction.new(actor, _pattern, _attack[2], -1, Affinity.Affiliation.ENEMY)
	# 70% chance for basic attack when close
	elif roll >= 3 and distance_to_target <= 2:
		var _attack: Array = BASIC_ATTACK_PATTERNS.pick_random().duplicate()
		var _pattern:= Hitbox.generate_positions(actor.grid_position, target.grid_position, _attack[0], _attack[1])
		action = EACreateHitboxesAction.new(actor, _pattern, _attack[2], -1, Affinity.Affiliation.ENEMY)
	# Always move towards target if there's nothing else to do.
	elif distance_to_target > 1:
		action = _move_towards_target(actor)
	# Sometimes somehow do nothing...
	else:
		action = EARest.new(actor)
	
	return action

## Walk towards
func _move_towards_target(actor: Actor) -> EAction:
	var path: Array[Vector2i] = _astar.get_id_path(actor.grid_position, target.grid_position)
	var next_position: Vector2i = path.pop_front()
	
	if path.is_empty():
		return null
	
	next_position = path.pop_front()
	return EAMove.new(actor, next_position - actor.grid_position)



#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"is_active": is_active,
		"is_phase_two": is_phase_two,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.is_active = data["is_active"]
	self.is_phase_two = data["is_phase_two"]
#endregion


func on_set_active(actor: Actor) -> void:
	assert(actor is Boss, "BossController must be used by a Boss.")
	
	actor = actor as Boss
	fighter = actor.get_component_or_null(Components.FIGHTER)
	assert(is_instance_valid(fighter), "BossController requires a Fighter component on its actor.")
	
	target = actor.map_data.player
	
	_set_up_astar(actor)

# Set up astar
func _set_up_astar(actor: Actor) -> void:
	var arena_rect: Rect2i = actor.arena_data["rect"]
	_astar = AStarGrid2D.new()
	_astar.region = arena_rect
	_astar.cell_size = Vector2i(8, 8)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()
	
	_astar.fill_solid_region(arena_rect, true)
	
	var _arena_data: Array[Vector2i] = actor.arena_data[Prefab.ARENA_TILES]
	var adjusted_data: Array[Vector2i] = []
	adjusted_data.resize(_arena_data.size())
	
	for i: int in _arena_data.size():
		var _position:= arena_rect.position + _arena_data[i]
		adjusted_data[i] = _position
		_astar.set_point_solid(_position, false)

func _set_up_dijkstra(actor: Actor) -> void:
	var arena_rect: Rect2i = actor.arena_data["rect"]
	var center_positions: Array[Vector2i] = []
	var center:= arena_rect.get_center()
	if arena_rect.size.x % 2 == 0:
		center -= Vector2i.ONE
		## top left of center
		center_positions.append(center)
		## top right of center
		center_positions.append(center + Vector2i.RIGHT)
		## bottom left of center
		center_positions.append(center + Vector2i.DOWN)
		## bottom right of center
		center_positions.append(center + Vector2i.ONE)
	else:
		center_positions.append(center)
	
	var _arena_data: Array[Vector2i] = actor.arena_data[Prefab.ARENA_TILES]
	
	_dijkstra = Dijkstra.calculate(
		center_positions.front(), center_positions, _arena_data, Rect2i(Vector2i.ZERO, arena_rect.size)
	)
	_dijkstra_offset = arena_rect.position
	
	var distances:= _dijkstra.values()
	distances.sort()
	_arena_radius = distances.back()
	print(_arena_radius)



class PhaseTwoAction extends EAction:
	var controller: BossController
	
	func execute() -> EActionResult:
		controller.is_phase_two = true
		actor = actor as Boss
		Logger.log(TextHelper.format_color(
			TextHelper.format_dialogue("Miserable wretch!"), Color.ORANGE_RED
		), true)
		Logger.log(TextHelper.format_color(
			TextHelper.format_dialogue("I am the KING OF THIS LAND!"), Color.ORANGE_RED
		), true)
		Logger.log(TextHelper.format_color(
			TextHelper.format_dialogue("Away with you!"), Color.ORANGE_RED
		), true)
		
		var arena_rect: Rect2i = actor.arena_data["rect"]
		var middle_rect:= arena_rect.grow(-floori(arena_rect.size.x / 4.))
		middle_rect.position = arena_rect.get_center() - middle_rect.size / 2
		
		var only_edges: Array[Vector2i] = []
		for tile_pos: Vector2i in actor.arena_data[Prefab.ARENA_TILES]:
			var pos:= arena_rect.position + tile_pos
			if not middle_rect.has_point(pos) and not only_edges.has(pos):
				only_edges.append(pos)
		
		var half: int = ceili(only_edges.size() / 2.)
		for i in range(half):
			var pos:= Vector2i(only_edges[i])
			var fire:= FireTile.new()
			fire.map_data = actor.map_data
			actor.map_data.add_entity_to_tile_at_position(fire, pos)
			
			if only_edges.size() % 2 == 0:
				var pos1:= Vector2i(only_edges[only_edges.size() - i - 1])
				var fire1:= FireTile.new()
				fire1.map_data = actor.map_data
				actor.map_data.add_entity_to_tile_at_position(fire1, pos1)
			else:
				# dont do on midpoint again
				if i == half - 1:
					continue
				
				var pos1:= Vector2i(only_edges[only_edges.size() - i - 1])
				var fire1:= FireTile.new()
				fire1.map_data = actor.map_data
				actor.map_data.add_entity_to_tile_at_position(fire1, pos1)
		
		return EActionResult.new(true)
	
	func undo() -> EActionResult:
		return null
	
	func _init(_boss: Boss, _controller: BossController) -> void:
		actor = _boss
		controller = _controller









