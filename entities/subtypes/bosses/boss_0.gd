class_name Boss extends Actor

const BOSS_FRAMES:= preload("res://assets/sprites/enemies/boss_0.tres")

var arena_data: Dictionary = {}

func _ready() -> void:
	super()
	
	self.entity_name = "Gallagher, the Spoiled Wrath"
	
	var graphics:= Graphics.create(
		BOSS_FRAMES.resource_path, RenderOrder.ACTOR, Color.ORANGE_RED
	)
	add_component(Components.GRAPHICS, graphics)
	add_component(Components.ENERGY, Energy.create(75,))
	add_component(Components.FIGHTER, Fighter.create(5, 0, 2, 0, 25))
	add_component(Components.AFFINITY, Affinity.create(Affinity.Affiliation.ENEMY))
	
	sprite = AnimatedSprite2D.new()
	sprite.centered = false
	sprite.sprite_frames = BOSS_FRAMES
	sprite.self_modulate = graphics.modulate
	add_child(sprite)
	sprite.play()
	
	self.blocks_movement = true
	self.blocks_vision = false
	
	self.controller = BossController.new()
	
	MapSignalBus.arena_entrance_triggered.connect(
		func():
			if not self.controller.is_active:
				self.controller.target = map_data.player
				self.controller.is_active = true
				Logger.log(TextHelper.format_color(
					TextHelper.format_dialogue("You made a grave mistake, coming here..."), Color.ORANGE_RED
				))
				Logger.log(TextHelper.format_color(
					TextHelper.format_dialogue("It shall be your last."), Color.ORANGE_RED
				))
	)

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"type": "Boss",
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion






