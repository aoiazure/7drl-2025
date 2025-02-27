class_name EAWithDirection extends EAction

var direction: Vector2i



func execute() -> EActionResult:
	return null

func undo() -> EActionResult:
	return null

func _init(_actor: Actor, _direction: Vector2i) -> void:
	actor = _actor
	direction = _direction


