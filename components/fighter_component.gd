class_name Fighter extends EComponent

signal health_changed(fighter: Fighter)
signal stats_changed(fighter: Fighter)

var cur_health: int
var base_health: int
var max_health: int :
	get:
		return (
			base_health + stats[Stats.BODY].base + stats[Stats.BODY].mod \
				+ stats[Stats.ARMOR_VALUE].base + stats[Stats.ARMOR_VALUE].mod
		)

var stats: Dictionary[String, Dictionary] = {
	Stats.ARMOR_VALUE:	{ "base": 0, "mod": 0, },
	Stats.BODY:			{ "base": 0, "mod": 0, },
	Stats.SPIRIT:		{ "base": 0, "mod": 0, },
	Stats.SKILL:		{ "base": 0, "mod": 0, },
	Stats.APTITUDE:		{ "base": 0, "mod": 0, },
}





static func create(_body: int, _spirit: int, _skill: int, _aptitude: int, _base_health: int) -> Fighter:
	var f:= Fighter.new()
	f.stats[Stats.BODY].base = _body
	f.stats[Stats.SPIRIT].base = _spirit
	f.stats[Stats.SKILL].base = _skill
	f.stats[Stats.APTITUDE].base = _aptitude
	
	f.base_health = _base_health
	f.cur_health = f.max_health
	
	return f

## Deal this much damage.
func damage(amount: int) -> void:
	cur_health = maxi(cur_health - amount, 0)
	health_changed.emit(self)
	
	if cur_health <= 0:
		if entity is Actor:
			entity.controller = ECorpseController.new()

## Recover this much health.
func heal(amount: int) -> void:
	cur_health = mini(cur_health + amount, max_health)
	health_changed.emit(self)



func get_stat(stat: String) -> int:
	return -1 if not stats.has(stat) else (stats[stat].base + stats[stat].mod)

func get_stat_mod(stat: String) -> int:
	return -1 if not stats.has(stat) else stats[stat].mod

func set_stat_mod(stat: String, amount: int) -> void:
	if not stats.has(stat):
		return
	
	stats[stat].mod = amount
	stats_changed.emit(self)





#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"cur_health": cur_health,
		"base_health": base_health,
		
		"stats": stats,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.cur_health = data["cur_health"]
	self.base_health = data["base_health"]
	
	#var _stats: Dictionary = JSON.parse_string(data["stats"])
	#self.stats = _stats
	self.stats.merge(data["stats"], true)
#endregion



