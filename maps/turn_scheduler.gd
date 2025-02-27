## Class that processes turns for actors. The "game loop".
class_name TurnScheduler extends Node

var map_data: MapData

var all_actors: Array[Actor] = []
var current_actor: int = 0

## Called to set up this node.
func setup(_map_data: MapData) -> void:
	self.map_data = _map_data
	self.map_data.actors_changed.connect(
		func():
			all_actors = self.map_data.actors
	)


## Turn loop for the game.
func _process(_delta: float) -> void:
	if all_actors.is_empty():
		return
	
	if current_actor >= all_actors.size():
		current_actor = current_actor % all_actors.size()
	
	# Get current controller and its associated actor
	var actor:= all_actors[current_actor]
	var controller:= actor.controller
	
	# Dead actor or simply an error, so we remove them from the turn set.
	if (
			(not is_instance_valid(actor)) or\
			(not is_instance_valid(controller)) or\
			(controller is ECorpseController)
		):
		
		all_actors.erase(actor)
		_increment_current_controller()
		return
	
	var energy: Energy = actor.components["Energy"]
	
	# Not ready to act yet.
	if energy.current_energy < energy.required_to_act:
		energy.current_energy += 1
		_increment_current_controller()
		return
	
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
			#if actor == map_data.player:
			Logger.log_error(result.error_message)
			return
		if result.alternative == null:
			break
		
		action = result.alternative
		# loop again after this
	
	# do the visual effects of the actions
	# await CombatDirector.process_visuals()
	
	# Reset energy for the actor since they acted.
	energy.current_energy = 0
	
	# Tell map to redraw, just in case.
	#if map_data:
		#map_data.changed.emit()
	# Cycle to next actor.
	_increment_current_controller()

func _increment_current_controller() -> void:
	if all_actors.is_empty():
		return
	
	current_actor = (current_actor + 1) % all_actors.size()



