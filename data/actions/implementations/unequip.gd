class_name EAUnequip extends EAction

var slot_name: String

func execute() -> EActionResult:
	var equipment: Equipment = actor.get_component_or_null(Components.EQUIPMENT)
	if not equipment:
		return null
	
	var res:= equipment.unequip(slot_name, true)
	if not res:
		return EActionResult.new(false, null, "Unequipping failed.")
	
	return EActionResult.new(true)

func undo() -> EActionResult:
	return null


func _init(_actor: Actor, _slot_name: String, ) -> void:
	actor = _actor
	slot_name = _slot_name

