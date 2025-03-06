class_name EMeleeController extends EController

const ATTACK_PATTERNS: Array[Array] = [
	[4, 2, 3],
	[5, 1, 1],
	[2, 3, 2],
]

var target: Actor
var prev_controller: EController
var thread: Thread

var _prev_target_position: Vector2i
var _prev_visited: Array[Vector2i] = []

static func create(_target: Actor, _prev_controller: EController) -> EMeleeController:
	var c:= EMeleeController.new()
	c.target = _target
	c.prev_controller = _prev_controller
	c.thread = Thread.new()
	
	return c

func get_action(actor: Actor) -> EAction:
	# Swap back if we lost our target or they died.
	if not target or target.controller is ECorpseController:
		actor.controller = prev_controller
		return null
	
	if not thread.is_started():
		thread.start(_run_pathing_thread.bind(actor, target), Thread.PRIORITY_HIGH)
	
	if thread.is_alive():
		return null
	
	var next_position: Vector2i = thread.wait_to_finish()
	# If we haven't reached our goal tile, keep moving
	if next_position != actor.grid_position:
		return EABump.new(actor, next_position - actor.grid_position)
	
	var attack_pattern: Array = ATTACK_PATTERNS.pick_random()
	return EACreateHitboxesAction.new(actor, _create_hitboxes(actor, attack_pattern[0], attack_pattern[1]), attack_pattern[2])


func _create_hitboxes(actor: Actor, length: int, width: int) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	
	var difference:= target.grid_position - actor.grid_position
	if abs(difference.x) > abs(difference.y):
		var start_position: Vector2i
		# Start further away and move right
		if sign(difference.x) < 0:
			start_position = actor.grid_position - Vector2i(length, 0)
		# Start close and move right
		else:
			start_position = actor.grid_position + Vector2i.RIGHT
		
		for x in range(length):
			for w: int in range(-(width-1), (width)):
				var current_position:= start_position + Vector2i(x, w)
				if not positions.has(current_position):
					positions.append(current_position)
	else:
		var start_position: Vector2i
		# Start further up and move down
		if sign(difference.y) < 0:
			start_position = actor.grid_position - Vector2i(0, length)
		# Start close and move down
		else:
			start_position = actor.grid_position + Vector2i.DOWN
		
		for y in range(length):
			for w: int in range(-(width-1), (width)):
				var current_position:= start_position + Vector2i(w, y)
				if not positions.has(current_position):
					positions.append(current_position)
	
	return positions

#region Pathing
func _path_to_vision_from_goal_pos(_actor: Actor, _target: Actor, _next_position: Vector2i) -> Vector2i:
	var front_coord:= _next_position + (_target.grid_position - _next_position).clamp(Vector2i(-1, -1), Vector2i(1, 1))
	var tile: Tile = _actor.map_data.get_tile(front_coord)
	# if we can't, we'll path directly towards the target instead and try again next turn
	if not tile.is_walkable() and not tile.is_transparent():
		var path: Array[Vector2i] = ActorHelper.get_navigation_path_to(
			_actor.grid_position, _target.grid_position, false, true
		)
		_next_position = path.pop_front()
		if not path.is_empty():
			_next_position = path.pop_front()
	# otherwise if we can, just return the same position untouched
	
	return _next_position

func _run_pathing_thread(actor: Actor, _target: Actor) -> Vector2i:
	var distance: int = abs(target.grid_position.x - actor.grid_position.x) + abs(target.grid_position.y - actor.grid_position.y)
	if distance <= 1:
		return actor.grid_position
	
	var path: Array[Vector2i] = []
	## If close, path to one of the 4 nearbys
	if distance <= 5:
		var closest: int = 9999
		for dir: Vector2i in MapUtils.NEIGHBOR_DIRECTIONS:
			var new_position: Vector2i = target.grid_position + dir * 2
			# Skip further ones naively
			var new_distance: int = abs(new_position.x - actor.grid_position.x) \
					+ abs(new_position.y - actor.grid_position.y)
			if new_distance > closest:
				continue
			# Save
			closest = new_distance
			if new_position in _prev_visited:
				continue
			
			var new_path:= ActorHelper.get_navigation_path_to(actor.grid_position, new_position, true)
			if path.is_empty():
				path = new_path
			elif not new_path.is_empty():
				if path.size() > new_path.size():
					path = new_path
				elif path.size() == new_path.size():
					if randf() > 0.5:
						path = new_path
	## Otherwise, just move towards the player
	else:
		path = ActorHelper.get_navigation_path_to(actor.grid_position, target.grid_position)
	
	# Remove front (which is almost always our own position)
	var next_position = path.pop_front()
	
	# If we've reached our final destination, check if in front of us is a valid target.
	if not path.is_empty():
		next_position = path.pop_front()
		# if this next move is out last,
		# check that we'd be able to see the target from there
		if path.is_empty():
			var new_position:= _path_to_vision_from_goal_pos(actor, target, next_position)
			# If it's different, remember that point is invalid for now
			if new_position != next_position:
				_prev_visited.append(next_position)
			
			next_position = new_position
	elif next_position != null:
		next_position = _path_to_vision_from_goal_pos(actor, target, next_position)
	else:
		next_position = ActorHelper.get_navigation_path_to(actor.grid_position, target.grid_position)[1]
	
	# Update positions
	if target.grid_position != _prev_target_position:
		_prev_target_position = target.grid_position
		_prev_visited.clear()
	
	return next_position

func _run_dijkstra_thread(actor: Actor, target_grid_position: Vector2i) -> Vector2i:
	var _next: Vector2i = Vector2i(-1, -1)
	# Dijkstra
	var dijkstra_result: Dictionary[Vector2i, int] = Dijkstra.calculate(
		actor.grid_position, [
			target_grid_position,
			target_grid_position + Vector2i(2, 0),
			target_grid_position - Vector2i(2, 0),
			target_grid_position + Vector2i(0, 2),
			target_grid_position - Vector2i(0, 2),
		],
		actor.map_data.get_all_walkable_cells_from_position(actor.grid_position),
		Rect2i(Vector2i.ZERO, actor.map_data.grid_definition.map_size),
		(actor.get_component_or_null(Components.FOV) as Fov).vision_radius + 1
	)
	
	_next = actor.grid_position
	var lowest: int = dijkstra_result[actor.grid_position]
	for dir: Vector2i in MapUtils.NEIGHBOR_DIRECTIONS:
		var new_position: Vector2i = actor.grid_position + dir
		if dijkstra_result.has(new_position) and dijkstra_result[new_position] < lowest:
			_next = new_position
	
	return _next
#endregion

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"prev_controller": prev_controller.serialize(),
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	prev_controller = data["prev_controller"]
#endregion


