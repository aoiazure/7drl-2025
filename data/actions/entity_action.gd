class_name EAction extends RefCounted

var actor: Actor



func execute() -> EActionResult:
	return null

func undo() -> EActionResult:
	return null



func _init(_actor: Actor) -> void:
	actor = _actor
