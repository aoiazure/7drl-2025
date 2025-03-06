## Indicates the entity can be worn.
class_name Equippable extends EComponent

static var Index: Dictionary[StringName, Equippable] = {
	"ArmorEquippable": ArmorEquippable.new(),
	Items.ARMOUR_LEATHER: ArmorEquippable.create(4),
	Items.ARMOUR_CHAIN: ArmorEquippable.create(6),
	Items.ARMOUR_FULL: ArmorEquippable.create(8),
}

var item_type: Items.Types



func on_equip(_equipping_entity: Entity) -> void:
	pass

func on_unequip(_equipping_entity: Entity) -> void:
	pass

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"name": get_script().get_global_name(),
		"item_type": item_type,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.item_type = data["item_type"]
#endregion


