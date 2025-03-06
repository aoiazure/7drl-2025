## Called to activate an item.
class_name ItemAction extends EAction

var item: Item
var target_positions: Array[Vector2i] = []



func execute() -> EActionResult:
	var consumable: Consumable = item.get_component_or_null(Components.CONSUMABLE)
	var equippable: Equippable = item.get_component_or_null(Components.EQUIPPABLE)
	if not consumable and not equippable:
		return EActionResult.new(false, null, "You can't use this item.")
	
	## TODO: Equippable
	if equippable:
		var equipment: Equipment = actor.get_component_or_null(Components.EQUIPMENT)
		if not equipment:
			return EActionResult.new(false, null, "You have no equipment slots.")
		
		var result: bool = false
		for slot_name: String in equipment.slots:
			var slot: EquipmentSlot = equipment.slots[slot_name]
			printt(slot.type, equippable.item_type)
			if slot.type == equippable.item_type:
				result = equipment.equip(item, slot_name, true)
				if result:
					var inventory: Inventory = item.inventory_container
					if inventory:
						inventory.remove(item)
		
		return EActionResult.new(result, null, "No appropriate item slot found.")
	
	## We pass in this action so the consumable has containerized info to work with.
	return consumable.activate(self)

func undo() -> EActionResult:
	return null


func _init(_actor: Actor, _item: Item, _targets: Array[Vector2i] = []) -> void:
	actor = _actor
	item = _item
	target_positions = _targets


