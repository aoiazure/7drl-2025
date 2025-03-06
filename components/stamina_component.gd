class_name Stamina extends EComponent

signal stamina_changed(cur, max)

var cur_stamina: int
var max_stamina: int

var recharge: Energy = Energy.create(1, 3, 0)

static func create(_cur: int, _max: int) -> Stamina:
	var s:= Stamina.new()
	s.cur_stamina = _cur
	s.max_stamina = _max
	
	return s

func spend(amount: int) -> bool:
	if cur_stamina < amount:
		return false
	# Reset recharge
	recharge.current_energy = 0
	# Spend the stamina
	cur_stamina = maxi(cur_stamina - amount, 0)
	# Update
	stamina_changed.emit(cur_stamina, max_stamina)
	return true

func increment_recovery(actor: Actor, base_amount: int = recharge.speed) -> void:
	recharge.current_energy += base_amount
	if recharge.can_act():
		recharge.current_energy = 0
		recover(1)
		if actor.is_player:
			Logger.log("You recovered 1 stamina.")

func recover(amount: int) -> void:
	cur_stamina = mini(cur_stamina + amount, max_stamina)
	stamina_changed.emit(cur_stamina, max_stamina)

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"cur_stamina": cur_stamina,
		"max_stamina": max_stamina,
		"recharge": recharge.serialize(),
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.cur_stamina = data["cur_stamina"]
	self.max_stamina = data["max_stamina"]
	self.recharge.deserialize(data["recharge"])
#endregion



