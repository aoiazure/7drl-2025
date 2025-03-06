class_name EAlertController extends EController



func get_action(actor: Actor) -> EAction:
	if not actor.visible:
		return EARest.new(actor)
	
	var fov:= actor.get_component_or_null(Components.FOV)
	fov.update_fov(actor.map_data, actor.grid_position)
	
	# Spotted an alive player, so swap to chase and continue its actions
	var player:= actor.map_data.player
	if player.grid_position in fov.tiles_currently_visible and player.controller is not ECorpseController:
		actor.controller = EMeleeController.create(player, self)
		Logger.log("%s caught sight of %s and is moving to attack!" % [
			actor.entity_name, actor.map_data.player.entity_name
		], true, true)
		return null
	
	var direction: Vector2i = [Vector2i.ZERO, Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT].pick_random()
	# Rest
	if direction == Vector2i.ZERO:
		return EARest.new(actor)
	# Move
	return EAMove.new(actor, direction)



#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion


