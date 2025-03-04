class_name Energy extends EComponent

var required_to_act: int
var current_energy: int

func can_act() -> bool:
	return current_energy >= required_to_act

#region Saving and Loading
func serialize() -> Dictionary:
	var data:= super()
	var new_data: Dictionary = {
		"required_to_act": required_to_act,
		"current_energy": current_energy,
	}
	data.merge(new_data)
	
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.required_to_act = data["required_to_act"]
	self.current_energy = data["current_energy"]
#endregion

static func create(_requirement: int, _current: int = 0) -> Energy:
	var e:= Energy.new()
	e.required_to_act = _requirement
	e.current_energy = _current
	return e
