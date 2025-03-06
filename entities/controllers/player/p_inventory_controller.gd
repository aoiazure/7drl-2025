class_name PInventoryController extends EController

var prev_controller: EController
var inventory: Inventory



func get_action(actor: Actor) -> EAction:
	if Input.is_action_just_pressed(&"toggle_inventory") and InventoryMenu.instance.visible:
		InventoryMenu.instance.toggle_inventory(false)
		actor.set_deferred("controller", prev_controller)
		return null
	
	if Input.is_action_just_pressed(&"wait"):
		var button = InventoryMenu.instance.cur_hovered_button
		if button is InventoryMenu.ItemButton:
			var item: Item = button.item
			return ItemAction.new(actor, item)
		
		elif button is InventoryMenu.SlotButton:
			var item: Item = button.item
			if item:
				var slot_name: String = button.slot_name
				return EAUnequip.new(actor, slot_name)
	
	return null

func on_set_active(actor: Actor) -> void:
	assert(is_instance_valid(prev_controller))
	
	inventory = actor.get_component_or_null(Components.INVENTORY)
	assert(is_instance_valid(inventory))
	
	InventoryMenu.instance.load_inventory(actor)
	InventoryMenu.instance.toggle_inventory(true)



#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"prev_controller": prev_controller.serialize(),
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.prev_controller = data["prev_controller"]
#endregion
