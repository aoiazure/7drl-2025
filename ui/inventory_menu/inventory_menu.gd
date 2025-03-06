class_name InventoryMenu extends Control

static var instance: InventoryMenu

@export_group("References")
@export var container_items: Container
@export var container_equip_list: Container
@export var container_all_equip: Container
@export var label_description: Label
@export var scroll_items: ScrollContainer
@export var scroll_equip: ScrollContainer

var _cur_inventory: Inventory
var _cur_equipment: Equipment
var cur_hovered_button: Button

func load_inventory(actor: Actor) -> void:
	for child in container_items.get_children():
		child.queue_free()
	for child in container_equip_list.get_children():
		child.queue_free()
	
	#
	_set_up_item_list(actor)
	
	_set_up_equipment_list(actor)
	
	await get_tree().process_frame
	if container_items.get_child_count() > 0:
		var child:= container_items.get_child(0)
		if child is not Label:
			container_items.get_child(0).grab_focus()
			return
	if container_equip_list.visible and container_equip_list.get_child_count() > 0:
		var child:= container_equip_list.get_child(0)
		if child is not Label:
			container_equip_list.get_child(0).grab_focus()
			return



func toggle_inventory(active: bool = !self.visible) -> void:
	visible = active
	
	if visible:
		await get_tree().process_frame
		if container_items.get_child_count() > 0:
			container_items.get_child(0).grab_focus()
	else:
		cur_hovered_button = null
		
		if _cur_inventory and _cur_inventory.changed.is_connected(load_inventory):
			_cur_inventory.changed.disconnect(load_inventory)
		if _cur_equipment and _cur_equipment.changed.is_connected(load_inventory):
			_cur_equipment.changed.disconnect(load_inventory)


func _ready() -> void:
	InventoryMenu.instance = self
	
	var invisible_scrollbar_theme = Theme.new()
	var empty_stylebox = StyleBoxEmpty.new()
	invisible_scrollbar_theme.set_stylebox("scroll", "VScrollBar", empty_stylebox)
	invisible_scrollbar_theme.set_stylebox("scroll", "HScrollBar", empty_stylebox)
	if scroll_items:
		scroll_items.get_v_scroll_bar().theme = invisible_scrollbar_theme
		scroll_items.get_h_scroll_bar().theme = invisible_scrollbar_theme
	if scroll_equip:
		scroll_equip.get_v_scroll_bar().theme = invisible_scrollbar_theme
		scroll_equip.get_h_scroll_bar().theme = invisible_scrollbar_theme

func _set_up_item_list(actor: Actor) -> void:
	_cur_inventory = actor.get_component_or_null(Components.INVENTORY)
	if not _cur_inventory or _cur_inventory.items.is_empty():
		var label: Label = Label.new()
		label.text = "No items."
		container_items.add_child(label)
		return
	
	if not _cur_inventory.changed.is_connected(load_inventory):
		_cur_inventory.changed.connect(load_inventory.bind(actor))
	
	for item: Item in _cur_inventory.items:
		var button:= ItemButton.new(item, false)
		container_items.add_child(button)
		
		button.owner = self
		
		button.focus_entered.connect(_on_item_button_selected.bind(button))
		button.mouse_entered.connect(_on_item_button_selected.bind(button))

func _set_up_equipment_list(actor: Actor) -> void:
	_cur_equipment = actor.get_component_or_null(Components.EQUIPMENT)
	if not _cur_equipment or _cur_equipment.slots.is_empty():
		container_all_equip.hide()
		return
	
	if not _cur_equipment.changed.is_connected(load_inventory):
		_cur_equipment.changed.connect(load_inventory.bind(actor))
	
	for slot_name: String in _cur_equipment.slots:
		var equip_slot: EquipmentSlot = _cur_equipment.slots[slot_name]
		var slot_button:= SlotButton.new(slot_name, equip_slot.item)
		container_equip_list.add_child(slot_button)
		
		slot_button.owner = self
		
		slot_button.focus_entered.connect(_on_slot_button_selected.bind(slot_button))
		slot_button.mouse_entered.connect(_on_slot_button_selected.bind(slot_button))
	
	container_all_equip.show()

func _on_item_button_selected(button: ItemButton) -> void:
	cur_hovered_button = button
	label_description.text = button.item.entity_desc
	
	var children:= container_items.get_children()
	if button == children.front():
		scroll_items.scroll_vertical = 0
	elif button == children.back():
		scroll_items.scroll_vertical = ceili(scroll_equip.get_v_scroll_bar().max_value)

func _on_slot_button_selected(button: SlotButton) -> void:
	cur_hovered_button = button
	if button.item:
		label_description.text = button.item.entity_desc
	
	var children:= container_equip_list.get_children()
	if button == children.front():
		scroll_equip.scroll_vertical = 0
	elif button == children.back():
		scroll_equip.scroll_vertical = ceili(scroll_equip.get_v_scroll_bar().max_value)


class ItemButton extends Button:
	var item: Item
	var label: RichTextLabel
	
	func _init(_item: Item, is_equipped: bool) -> void:
		item = _item
		
		label = RichTextLabel.new()
		var graphics: Graphics = item.get_component_or_null(Components.GRAPHICS)
		if graphics:
			label.add_image(graphics.texture, 8, 8, graphics.modulate)
		label.push_font_size(8)
		
		var stackable: Stackable = _item.get_component_or_null(Components.STACKABLE)
		label.add_text("%s%s%s" % [
			item.entity_name,
			"" if not stackable or stackable.stack <= 1 else " x%s" % [stackable.stack],
			" (E)" if is_equipped else ""
		])
		
		label.fit_content = true
		label.bbcode_enabled = true
		label.scroll_active = false
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.custom_minimum_size = Vector2i(40, 6)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)
		
		self.mouse_filter = Control.MOUSE_FILTER_IGNORE
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		custom_minimum_size = label.custom_minimum_size + Vector2.ONE * 3

class SlotButton extends Button:
	var label: RichTextLabel
	var slot_name: String
	var item: Item
	
	func _init(_slot_name: String, _item: Item) -> void:
		slot_name = _slot_name
		item = _item
		
		label = RichTextLabel.new()
		label.text = "%s: %s." % [
			TextHelper.format_color(slot_name.capitalize(), Color.LIGHT_GRAY), 
			TextHelper.format_color("None", Color.WEB_GRAY) if not item else item.entity_name 
		]
		
		label.fit_content = true
		label.bbcode_enabled = true
		label.scroll_active = false
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.custom_minimum_size = Vector2i(40, 6)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)
		
		self.mouse_filter = Control.MOUSE_FILTER_IGNORE
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		custom_minimum_size = label.custom_minimum_size + Vector2.ONE * 2









