extends MarginContainer

@export_group("References")
@export var button_continue: Button
@export var button_new_game: Button
@export var button_quit: Button
@export var button_back_cc: Button
@export var button_start_game: Button
@export var button_class_select: OptionButton

@export var container_main: Container
@export var container_creation: Container
@export var name_line_edit: LineEdit

const SCENE_GAME:= preload("res://maps/game_map.tscn")

func _ready() -> void:
	button_new_game.pressed.connect(_start_new_game)
	button_quit.pressed.connect(get_tree().quit)
	button_back_cc.pressed.connect(
		func():
			container_creation.hide()
			container_main.show()
	)
	
	button_class_select.select(0)
	
	button_start_game.pressed.connect(
		func():
			match button_class_select.selected:
				0:
					var player: Actor = Actor.create()\
						.add_component(Components.GRAPHICS, Graphics.create(
								"res://assets/sprites/player/player_basic_frames.tres", RenderOrder.ACTOR))\
						.add_component(Components.ENERGY, Energy.create(1, 2))\
						.add_component(Components.FIGHTER, Fighter.create(2, 1, 0, 0, 8))\
						.add_component(Components.STAMINA, Stamina.create(3, 5))\
						.add_component(Components.MANA, Mana.create(3, 5))\
						.add_component(Components.FOV, Fov.create(12))\
						.add_component(Components.INVENTORY, Inventory.create([
								Item.Factories[Items.HEALTH_FLASK].copy(),
								Item.Factories[Items.MANA_FLASK].copy(),
							]
						))
					
					player.entity_name = "Player" if name_line_edit.text.is_empty() else name_line_edit.text
					player.is_player = true
					player.controller = PMoveController.new()
					
					SaveManager.player_data = player
				1:
					pass
				2:
					pass
			
			get_tree().change_scene_to_packed(SCENE_GAME)
	)


func _start_new_game() -> void:
	container_main.hide()
	container_creation.show()






