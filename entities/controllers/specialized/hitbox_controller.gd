class_name HitboxController extends EController

var affiliation: Affinity.Affiliation

func get_action(actor: Actor) -> EAction:
	var hitbox:= actor as Hitbox
	if hitbox.current_time_to_kill > 1:
		return HitboxAction.new(actor)
	
	return HitboxAttack.new(actor, actor.grid_position, [actor])

func on_set_active(actor: Actor) -> void:
	assert(actor is Hitbox)
	actor = actor as Hitbox
	
	actor.current_time_to_kill = actor.time_to_kill

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

class HitboxAction extends EAction:
	func execute() -> EActionResult:
		(actor as Hitbox).current_time_to_kill -= 1
		#Logger.log("%s counts down to %s." % [actor.entity_name, actor.current_time_to_kill], true, true)
		return EActionResult.new(true)

	func undo() -> EActionResult:
		return null
	
	func _init(_hitbox: Hitbox) -> void:
		actor = _hitbox

class HitboxAttack extends EAWithDirection:
	var excluded: Array[Actor] = []
	
	func execute() -> EActionResult:
		var fighter: Fighter = actor.get_component_or_null(Components.FIGHTER)
		var power: int = fighter.get_stat(Stats.BODY)
		
		actor.queue_free()
		actor.map_data.remove_entity(actor)
		
		var target_actor: Actor = ActorHelper.get_actor_at_position(actor.grid_position, excluded)
		if not target_actor:
			return EActionResult.new(true, null, "Nothing to attack, so it missed.")
		
		var target_fighter: Fighter = target_actor.get_component_or_null(Components.FIGHTER)
		if not target_fighter:
			return EActionResult.new(false, null, "The target actor does not have a fighter component.") 
		
		var damage: int = maxi(0, power)
		var attack_desc: String = "%s attacks %s" % [
			actor.entity_name.capitalize(), target_actor.entity_name.capitalize(),
		]
		if damage > 0:
			Logger.log("%s for %s damage." % [
				attack_desc, 
				TextHelper.format_color(str(damage), ColorLookup.DAMAGE_VAL),
			])
		else:
			Logger.log("%s, but does no damage." % [attack_desc])
		
		## Deal the damage
		target_fighter.damage(damage)
		
		return EActionResult.new(true)
	
	func _init(_actor: Actor, _direction: Vector2i, _excluded: Array[Actor] = []) -> void:
		actor = _actor
		direction = _direction
		excluded = _excluded






