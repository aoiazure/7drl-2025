## Base component script that represents a component attached to an Entity.
class_name EComponent extends Resource

##
static var Lookup: Dictionary[StringName, EComponent] = {
	Components.Energy: Energy.new(),
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
