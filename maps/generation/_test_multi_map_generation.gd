extends Node2D

@export var tilemap: TileMapLayer
@export var wfc: WFC2DGenerator

func _ready() -> void:
	$Sample/Main.hide()
	$Negative/Main.hide()
	$Target/Main.show()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_accept"):
		get_tree().reload_current_scene()


