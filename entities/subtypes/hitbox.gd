class_name Hitbox extends Actor

const HITBOX_SCENE:= preload("res://entities/subtypes/hitbox.tscn")

@export var spr_countdown: AnimatedSprite2D

var time_to_kill: int :
	set(val):
		time_to_kill = val
		if spr_countdown:
			if not spr_countdown.is_node_ready():
				await spr_countdown.ready
			
			spr_countdown.frame = clampi(val, 0, 19)

var current_time_to_kill: int :
	set(val):
		current_time_to_kill = val
		if spr_countdown:
			spr_countdown.frame = clampi(val, 0, 19)


static func create_hitbox(_time_to_kill: int, _power: int, affiliation:= Affinity.Affiliation.NONE) -> Hitbox:
	var h: Hitbox = HITBOX_SCENE.instantiate()
	h.time_to_kill = _time_to_kill
	h.add_component(Components.FIGHTER, Fighter.create(0, 0, _power))
	h.add_component(Components.AFFINITY, Affinity.create(affiliation))
	h.add_component(Components.ENERGY, Energy.create(15))
	
	return h

func _ready() -> void:
	super()
	
	graphics = Graphics.create(
		"res://assets/sprites/hitbox/texture_hitbox.tres",
		RenderOrder.HITBOX,
		ColorLookup.DAMAGE_VAL
	)
	
	self.blocks_movement = false
	self.blocks_vision = false
	self.controller = HitboxController.new()
	reset_physics_interpolation()

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"type": "Hitbox",
		"time_to_kill": time_to_kill,
		"current_time_to_kill": current_time_to_kill,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion






