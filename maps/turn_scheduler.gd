## Class that processes turns for actors. The "game loop".
class_name TurnScheduler extends Node

signal turn_taken

var map_data: MapData

var all_actors: Array[Actor] = []
var current_actor: int = 0
var prev_size: int

var _needs_update: bool = true

## Called to set up this node.
func setup(_map_data: MapData) -> void:
	self.map_data = _map_data
	self.map_data.actors_changed.connect(
		func():
			_needs_update = true
	)
	
## Turn loop for the game.
func _process(_delta: float) -> void:
	if _needs_update:
		_update_actor_list()
	
	if all_actors.is_empty():
		return
	
	if all_actors.size() != prev_size:
		current_actor = maxi(current_actor - 1, 0)
		prev_size = all_actors.size()
	
	if current_actor >= all_actors.size():
		current_actor = current_actor % all_actors.size()
	
	# Get current controller and its associated actor
	var actor: Actor = all_actors[current_actor]
	var controller:= actor.controller
	# Dead actor or simply an error, so we remove them from the turn set.
	if controller is ECorpseController:
		all_actors.erase(actor)
		return
	
	var energy: Energy = actor.get_component_or_null(Components.ENERGY)
	
	# Turbo speed for someone who can act
	if not energy.can_act():
		while true:
			actor = all_actors[current_actor]
			controller = actor.controller
			energy = actor.get_component_or_null(Components.ENERGY)
			if not energy.can_act():
				energy.current_energy += energy.speed
				_increment_current_controller()
				continue
			break
	
	# Non-blocking wait for an action. If there's nothing we just keep processing until we get one.
	var action: EAction = controller.get_action(actor)
	if not action:
		return
	
	# Attempt the action; if we definitively failed, void the action.
	# If we have a substituted action, try again. Repeat the substituted until we succeed or definitively fail.
	# Otherwise, if we succeeded and there's no other substituted action, we're done.
	while true:
		var result: EActionResult = action.execute()
		if not result.succeeded:
			if actor == map_data.player:
				Logger.error(result.error_message)
			
			return
		if result.alternative == null:
			break
		
		action = result.alternative
		# loop again after this
	
	# do the visual effects of the actions
	# await CombatDirector.process_visuals()
	
	# Reset energy for the actor since they acted.
	energy.current_energy -= energy.required_to_act
	
	# Tell the world a turn was taken.
	# This also tells the map to redraw.
	turn_taken.emit()
	
	# Cycle to next actor.
	_increment_current_controller()

func _update_actor_list() -> void:
	all_actors = self.map_data.actors.duplicate()
	all_actors = all_actors.filter(
		func(_actor: Actor) -> bool:
			if not is_instance_valid(_actor):
				return false
			var controller:= _actor.controller
			if not is_instance_valid(controller):
				return false
			# Dead actor or simply an error, so we remove them from the turn set.
			if controller is ECorpseController:
				return false
			if not _actor.get_component_or_null(Components.ENERGY):
				return false
			
			return true
	)
	all_actors.sort_custom(
		func(a: Actor, b: Actor):
			return a.id < b.id
	)
	_needs_update = false

func _increment_current_controller() -> void:
	if all_actors.is_empty():
		return
	
	current_actor = (current_actor + 1) % all_actors.size()


