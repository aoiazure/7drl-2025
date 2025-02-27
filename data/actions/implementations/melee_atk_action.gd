class_name EAMeleeAttack extends EAWithDirection

var target_entity: Entity

func execute() -> EActionResult:
	var power: int = actor.fighter.power
	
	var target_actor: Actor = ActorHelper.get_actor_at_position(direction)
	if not target_actor:
		return EActionResult.new(false, null, "There is nothing to attack.")
	
	var target_defense: int = target_actor.fighter.armor
	var damage: int = maxi(0, power - target_defense)
	var attack_desc: String = "%s attacks %s" % [
		actor.name.capitalize(), target_actor.name.capitalize(),
	]
	if damage > 0:
		Logger.log_message("%s for %s damage." % [
			attack_desc, 
			TextHelper.format_color(str(damage), CLookup.DAMAGE_VAL),
		])
	else:
		Logger.log_message("%s, but does no damage." % [attack_desc])
	
	target_actor.fighter.hp -= damage
	return EActionResult.new(true)


func undo() -> EActionResult:
	return null


