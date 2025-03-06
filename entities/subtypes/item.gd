class_name Item extends Entity

static var Factories: Dictionary[StringName, Item] = {
	Items.ARROW: Item.create("Arrow", "", Items.Types.DEFAULT)\
		.add_component(Components.GRAPHICS,
			Graphics.create("res://assets/sprites/items/arrows.tres", RenderOrder.ITEM, Color.SANDY_BROWN))\
		.add_component(Components.STACKABLE, Stackable.create(99, 1)),
	
	Items.HEALTH_FLASK: Item.create("Health Flask", "", Items.Types.DEFAULT)\
		.add_component(Components.GRAPHICS, 
				Graphics.create("res://assets/sprites/items/health_flask.tres", RenderOrder.ITEM, Color.LIGHT_PINK))\
		.add_component(Components.CONSUMABLE, HealthFlask.new())\
		.add_component(Components.STACKABLE, Stackable.create(-1)),
	
	Items.MANA_FLASK: Item.create("Mana Flask", "", Items.Types.DEFAULT)\
		.add_component(Components.GRAPHICS, 
					Graphics.create("res://assets/sprites/items/mana_flask.tres", RenderOrder.ITEM, Color.LIGHT_BLUE))\
		.add_component(Components.CONSUMABLE, ManaFlask.new())\
		.add_component(Components.STACKABLE, Stackable.create(-1)),
	
	Items.ARMOUR_LEATHER: Item.create("Leather Armor", "", Items.Types.ARMOR)\
		.add_component(Components.GRAPHICS, 
					Graphics.create("res://assets/sprites/items/armor.tres", RenderOrder.ITEM, Color.ROSY_BROWN))\
		.add_component(Components.EQUIPPABLE, ArmorEquippable.create(4)),
	
	Items.ARMOUR_CHAIN: Item.create("Chainmail Armor", "", Items.Types.ARMOR)\
		.add_component(Components.GRAPHICS, 
					Graphics.create("res://assets/sprites/items/armor.tres", RenderOrder.ITEM, Color.DARK_GRAY))\
		.add_component(Components.EQUIPPABLE, ArmorEquippable.create(6)),
	
	Items.ARMOUR_FULL: Item.create("Full Plate Armor", "", Items.Types.ARMOR)\
		.add_component(Components.GRAPHICS, 
					Graphics.create("res://assets/sprites/items/armor.tres", RenderOrder.ITEM, Color.DARK_SLATE_GRAY))\
		.add_component(Components.EQUIPPABLE, ArmorEquippable.create(8)),
}

var item_type: Items.Types
var equipment_slot: EquipmentSlot = null
var inventory_container: Inventory = null

## Create an Item.
static func create(_name: String, _description: String, _type: Items.Types) -> Item:
	var i: Item = Item.new()
	i.entity_name = _name
	i.entity_desc = _description
	i.item_type = _type
	
	return i


## Make a copy of the item.
func copy() -> Item:
	var i: Item = Item.new()
	i.deserialize(self.serialize())
	
	return i

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"type": "Item",
		"item_type": item_type,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	self.item_type = data["item_type"]
#endregion


func _ready() -> void:
	super()

