## Tracks an entity's equipped equipment.
class_name Equipment extends EComponent

var slots: Dictionary[String, EquipmentSlot] = {}



static func create(_slots: Dictionary[String, EquipmentSlot] = {}) -> Equipment:
	var e:= Equipment.new()
	e.slots = _slots
	
	return e

## Returns true if the operation succeeded, false otherwise.
func equip(item: Item, slot_name: String, add_message: bool = false) -> bool:
	# Unequip the item in the current slot first, if any
	var cur_slot: EquipmentSlot = slots[slot_name]
	if cur_slot and is_instance_valid(cur_slot.item):
		var res:= unequip(slot_name, add_message)
		if not res:
			return false
	
	cur_slot.item = item
	item.equipment_slot = cur_slot
	var equippable: Equippable = item.get_component_or_null(Components.EQUIPPABLE)
	if equippable:
		equippable.on_equip(self.entity)
	
	if add_message:
		Logger.log("You equipped the %s." % item.entity_name)
	
	emit_changed()
	return true

## Returns true if the operation succeeded, false otherwise.
func unequip(slot_name: String, add_message: bool = true) -> bool:
	var cur_slot: EquipmentSlot = slots[slot_name]
	if not cur_slot:
		Logger.error("Slot [%s] does not exist." % slot_name, true)
		return false
	
	var item: Item = cur_slot.item
	if not item:
		Logger.error("There is no item in slot [%s] to unequip." % slot_name, true)
		return false
	
	var equippable: Equippable = item.get_component_or_null(Components.EQUIPPABLE)
	if equippable:
		equippable.on_unequip(self.entity)
	
	var inventory: Inventory = entity.get_component_or_null(Components.INVENTORY)
	## Drop on floor if you have no pockets
	if not inventory:
		item.equipment_slot = null
		item.inventory_container = null
		entity.map_data.add_entity_to_tile_at_position(item, entity.grid_position)
		if add_message:
			Logger.log("You unequipped %s and dropped it on the floor." % item.entity_name, true)
		
		return true
	
	## Otherwise (try to) put it back in our inventory
	var res: bool = inventory.add(item)
	if res:
		cur_slot.item = null
		item.equipment_slot = null
		if add_message:
			Logger.log("You unequipped %s and put it in your bag." % item.entity_name, true)
		
		emit_changed()
	
	return res



#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	
	# Serialize all slots
	var s_data: String = "{"
	for i: int in range(slots.size()):
		var slot_name: StringName = slots.keys()[i]
		var slot: EquipmentSlot = slots[slot_name]
		var d: String = "\"%s\": %s" % [slot_name, JSON.stringify(slot.serialize())]
		s_data += d
		if i != (slots.size() - 1):
			s_data += ","
	s_data += "}"
	var new_data: Dictionary = {
		"slots": s_data,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	
	# Slots
	var json:= JSON.new()
	var err = json.parse(data["slots"])
	if err:
		printt(json.get_error_line(), json.get_error_message())
		return
	
	var temp_slots: Dictionary = json.data
	
	for slot: String in temp_slots:
		var _equip_slot:= EquipmentSlot.new()
		_equip_slot.deserialize(temp_slots[slot])
		self.slots[slot] = _equip_slot
#endregion



