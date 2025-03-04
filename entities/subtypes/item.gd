class_name Item extends Entity

const ITEM_SCENE:= preload("res://entities/subtypes/item.tscn")

var inventory_container: Inventory = null

static func create(
				_name: String, _description: String,
				_consumable: Consumable
			) -> Item:
	
	var i: Item = ITEM_SCENE.instantiate()
	i.entity_name = _name
	i.entity_desc = _description
	i.add_component(Components.CONSUMABLE, _consumable)
	
	return i



#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"type": "Item",
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion


func _ready() -> void:
	super()

