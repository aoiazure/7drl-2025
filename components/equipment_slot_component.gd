class_name EquipmentSlot extends EComponent

## Slot name.
var name: String
## Item equipped.
var item: Item
## Type of items this slot can take.
var type: Items.Types

static func create(_name: String, _type: Items.Types, _item: Item = null) -> EquipmentSlot:
	var e:= EquipmentSlot.new()
	e.name = _name
	e.type = _type
	if is_instance_valid(_item):
		e.item = _item
		e.item.equipment_slot = e
	
	return e

## Returns whether the given item is equipped in this slot.
func is_this_item_equipped_here(_item: Item) -> bool:
	return item == _item



#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"name": name,
		"type": type,
	}
	
	if is_instance_valid(item):
		new_data["item"] = item.serialize()
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.name = data["name"]
	
	if data.has("item"):
		var _item:= Item.new()
		_item.deserialize(data["item"])
		item.equipment_slot = self
		self.item = _item
	
	self.type = data["type"]
#endregion



