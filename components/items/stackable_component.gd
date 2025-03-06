## Used to mark and handle something being Inventory stackable.
class_name Stackable extends EComponent

var max_stacks: int = 0
var stack: int = 0

static func create(_max_stacks: int, _cur_stack: int = 0) -> Stackable:
	var s:= Stackable.new()
	s.max_stacks = _max_stacks
	s.stack = _cur_stack
	
	return s

## Returns true if the stack amount was added.
## Returns false if the operation failed.
func add_stack(amount: int = 1) -> bool:
	if max_stacks > 0 and ((stack + amount) > max_stacks):
		return false
	
	stack += amount
	return true

## Returns true if the stack amount was removed.
## Returns false if the operation failed.
func remove_stack(amount: int = 1) -> bool:
	if ((stack - amount) < 0):
		return false
	
	stack -= amount
	return true

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"max_stacks": max_stacks,
		"stack": stack,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.max_stacks = data["max_stacks"]
	self.stack = data["stack"]
#endregion


