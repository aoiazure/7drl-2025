class_name ArmorEquippable extends Equippable

var armor_value: int

static func create(_armor_value: int) -> ArmorEquippable:
	var a:= ArmorEquippable.new()
	a.armor_value = _armor_value
	a.item_type = Items.Types.ARMOR
	
	return a



func on_equip(_equipping_entity: Entity) -> void:
	var fighter: Fighter = _equipping_entity.get_component_or_null(Components.FIGHTER)
	if not fighter:
		return
	
	var mod:= fighter.get_stat_mod(Stats.ARMOR_VALUE)
	fighter.set_stat_mod(Stats.ARMOR_VALUE, mod + armor_value)


func on_unequip(_equipping_entity: Entity) -> void:
	var fighter: Fighter = _equipping_entity.get_component_or_null(Components.FIGHTER)
	if not fighter:
		return
	
	var mod:= fighter.get_stat_mod(Stats.ARMOR_VALUE)
	fighter.set_stat_mod(Stats.ARMOR_VALUE, mod - armor_value)

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"armor_value": armor_value,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.armor_value = data["armor_value"]
#endregion


