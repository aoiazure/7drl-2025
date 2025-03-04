## Base component script that represents a component attached to an Entity.
class_name EComponent extends Resource

##
static var Lookup: Dictionary[StringName, EComponent] = {
	Components.ENERGY: Energy.new(),
	Components.FIGHTER: Fighter.new(),
	Components.STAMINA: Stamina.new(),
	Components.MANA: Mana.new(),
	
	Components.AFFINITY: Affinity.new(),
	Components.FOV: Fov.new(),
	Components.INVENTORY: Inventory.new(),
	
	Components.CONSUMABLE: Consumable.new(),
}

var entity: Entity

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = {
		
	}
	return data

func deserialize(_data: Dictionary) -> void:
	pass
#endregion
