class_name PMoveController extends EController

var next_action: EAction = null

func get_action(actor: Actor) -> EAction:
	var action: EAction = null
	
	if next_action:
		action = next_action
		next_action = null
		return next_action
	
	## Leveling up
	#if actor.level.requires_level_up:
		#actor.controller = LevelingController.new()
		#return null
	
	# Movement time
	if Input.is_action_just_pressed(&"move_up"):
		action = EABump.new(actor, Vector2i.UP)
	elif Input.is_action_just_pressed(&"move_down"):
		action = EABump.new(actor, Vector2i.DOWN)
	elif Input.is_action_just_pressed(&"move_left"):
		action = EABump.new(actor, Vector2i.LEFT)
	elif Input.is_action_just_pressed(&"move_right"):
		action = EABump.new(actor, Vector2i.RIGHT)
	
	elif Input.is_action_just_pressed(&"wait"):
		action = EARest.new(actor)
	
	#elif PlayerInputs.toggle_inspect:
		## Set our controller to something new and make sure we swap over to using a cursor
		#actor.controller = CursorController.create(self, actor.grid_position)\
			#.set_select_filter(SelectionFilter.new())
	#
	#elif PlayerInputs.toggle_inventory:
		#actor.controller = InventoryController.create(self, InventoryController.Mode.Inventory)
	#
	#elif PlayerInputs.toggle_action_menu:
		#actor.controller = InventoryController.create(self, InventoryController.Mode.Actions)
	
	#elif Input.is_action_just_pressed("ui_text_backspace"):
		#var tile:= MapHelper.get_tile_at_position(actor.grid_position)
		#if tile.has_item():
			#action = ItemAction.new(actor, tile.get_first_item())
	
	return action

func on_set_active(_actor: Actor) -> void:
	pass

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		
	}
	
	data.merge(new_data, true)
	return data

func deserialize(_data: Dictionary) -> void:
	pass
#endregion

