class_name EAMeleeAttack extends EAWithDirection

var target_entity: Entity
var excluded: Array[Actor] = []

func execute() -> EActionResult:
	var fighter: Fighter = actor.get_component_or_null(Components.FIGHTER)
	if not is_instance_valid(fighter):
		return EActionResult.new(false, null, "This actor does not have a fighter component.")
	
	var stamina: Stamina = actor.get_component_or_null(Components.STAMINA)
	if stamina:
		if not stamina.spend(1):
			return EActionResult.new(false, null, "This actor does not have %s stamina to spend." % 1)
	
	var power: int = fighter.power
	
	var target_actor: Actor = ActorHelper.get_actor_at_position(direction, excluded)
	if not target_actor:
		return EActionResult.new(false, null, "There is nothing to attack.")
	
	var target_fighter: Fighter = target_actor.get_component_or_null(Components.FIGHTER)
	if not target_fighter:
		return EActionResult.new(false, null, "The target actor does not have a fighter component.") 
	
	#var target_defense: int = target_actor.fighter.armor
	#var damage: int = maxi(0, power - target_defense)
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


func undo() -> EActionResult:
	return null

func _init(_actor: Actor, _direction: Vector2i, _excluded: Array[Actor] = []) -> void:
	actor = _actor
	direction = _direction
	excluded = _excluded
