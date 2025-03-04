## Called to activate an item.
class_name ItemAction extends EAction

var item: Item
var target_positions: Array[Vector2i] = []



func execute() -> EActionResult:
	var consumable: Consumable = item.get_component_or_null(Components.CONSUMABLE)
	## We pass in this action so the consumable has containerized info to work with.
	return consumable.activate(self)

func undo() -> EActionResult:
	return null


func _init(_actor: Actor, _item: Item, _targets: Array[Vector2i] = []) -> void:
	actor = _actor
	item = _item
	target_positions = _targets


