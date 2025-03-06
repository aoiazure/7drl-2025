class_name Mana extends EComponent

signal mana_changed(cur, max)

var cur_mana: int
var max_mana: int

static func create(_cur: int, _max: int) -> Mana:
	var m:= Mana.new()
	m.cur_mana = _cur
	m.max_mana = _max
	
	return m

func spend(amount: int) -> bool:
	if cur_mana < amount:
		return false
	
	cur_mana = maxi(cur_mana - amount, 0)
	mana_changed.emit(cur_mana, max_mana)
	return true

func recover(amount: int) -> void:
	cur_mana = mini(cur_mana + amount, max_mana)
	mana_changed.emit(cur_mana, max_mana)

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"cur_mana": cur_mana,
		"max_mana": max_mana,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.cur_mana = data["cur_mana"]
	self.max_mana = data["max_mana"]
#endregion



