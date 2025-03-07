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


static func create_hitbox(_time_to_kill: int, _power: int, _speed: int, affiliation:= Affinity.Affiliation.NONE) -> Hitbox:
	var h: Hitbox = HITBOX_SCENE.instantiate()
	h.time_to_kill = _time_to_kill
	h.add_component(Components.FIGHTER, Fighter.create(_power, 0, 0, 0, 0))
	h.add_component(Components.AFFINITY, Affinity.create(affiliation))
	h.add_component(Components.ENERGY, Energy.create(_speed, 100, -_speed))
	
	return h

## Generate positions based on a start position towards a target position, with a specified length and width.
## Essentially rotates a [LxW] box.
static func generate_positions(
			starting_position: Vector2i, target_position: Vector2i, length: int, width: int) -> Array[Vector2i]:
	
	var positions: Array[Vector2i] = []
	
	var difference:= target_position - starting_position
	if abs(difference.x) > abs(difference.y):
		var start_position: Vector2i
		# Start further away and move right
		if sign(difference.x) < 0:
			start_position = starting_position - Vector2i(length, 0)
		# Start close and move right
		else:
			start_position = starting_position + Vector2i.RIGHT
		
		for x in range(length):
			for w: int in range(-(width-1), (width)):
				var current_position:= start_position + Vector2i(x, w)
				if not positions.has(current_position):
					positions.append(current_position)
	else:
		var start_position: Vector2i
		# Start further up and move down
		if sign(difference.y) < 0:
			start_position = starting_position - Vector2i(0, length)
		# Start close and move down
		else:
			start_position = starting_position + Vector2i.DOWN
		
		for y in range(length):
			for w: int in range(-(width-1), (width)):
				var current_position:= start_position + Vector2i(w, y)
				if not positions.has(current_position):
					positions.append(current_position)
	
	return positions

func _ready() -> void:
	super()
	
	add_component(Components.GRAPHICS, Graphics.create(
		"res://assets/sprites/hitbox/texture_hitbox.tres",
		RenderOrder.HITBOX,
		ColorLookup.DAMAGE_VAL
	))
	
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






