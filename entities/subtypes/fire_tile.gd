class_name FireTile extends Entity

const TILE_FIRE_FRAMES:= preload("res://assets/sprites/tiles/tile_fire_frames.tres")

var damage: int = 1

func _ready() -> void:
	super()
	
	self.entity_name = "Desecrated Flames"
	
	var graphics:= Graphics.create(
		TILE_FIRE_FRAMES.resource_path, RenderOrder.ACTOR, Color.RED
	)
	add_component(Components.GRAPHICS, graphics)
	
	sprite = AnimatedSprite2D.new()
	sprite.centered = false
	sprite.sprite_frames = TILE_FIRE_FRAMES
	sprite.self_modulate = graphics.modulate
	add_child(sprite)
	sprite.play()
	
	self.blocks_movement = false
	self.blocks_vision = false
	
	MapSignalBus.player_position_changed.connect(
		func(_o, _n):
			_burn_player(_n)
	)
	MapSignalBus.player_in_fire_check_requested.connect(_burn_player)



func _burn_player(_position: Vector2i) -> void:
	if _position != self.grid_position:
		return
	
	var player:= map_data.player
	var fighter: Fighter = player.get_component_or_null(Components.FIGHTER)
	if not fighter:
		return
	
	Logger.log(TextHelper.format_color("The flames burn you, dealing %s damage..." % damage, Color.DARK_ORANGE))
	fighter.damage(damage)

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"type": "FireTile",
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion


