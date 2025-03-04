class_name Fighter extends EComponent

signal health_changed(cur, max)

var cur_health: int
var max_health: int
## Damage it deals on hit
var power: int

static func create(_cur: int, _max: int, _power: int) -> Fighter:
	var f:= Fighter.new()
	f.cur_health = _cur
	f.max_health = _max
	f.power = _power
	
	return f

func damage(amount: int) -> void:
	cur_health = maxi(cur_health - amount, 0)
	printt(entity.entity_name, cur_health)
	health_changed.emit(cur_health, max_health)
	
	if cur_health <= 0:
		if entity is Actor:
			entity.controller = ECorpseController.new()

func heal(amount: int) -> void:
	cur_health = mini(cur_health + amount, max_health)



#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"cur_health": cur_health,
		"max_health": max_health,
		"power": power,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.cur_health = data["cur_health"]
	self.max_health = data["max_health"]
	self.power = data["power"]
#endregion



