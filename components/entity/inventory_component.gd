class_name Inventory extends EComponent

var capacity: int = -1
var items: Array[Item] = []



func is_empty() -> bool:
	return items.is_empty()

func add(item: Item) -> bool:
	if capacity > 0 and items.size() >= capacity:
		return false
	
	items.append(item)
	item.inventory_container = self
	items.sort_custom(
		func(a: Item, b: Item):
			return a.entity_name.casecmp_to(b.entity_name) < 0
	)
	return true

func remove(item: Item) -> void:
	items.erase(item)



#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	# Serialize all items
	var i_data: String = "["
	for i: Item in items:
		i_data += JSON.stringify(i.serialize())
		if i != (items.back()):
			i_data += ","
	i_data += "]"
	
	var new_data: Dictionary = {
		"capacity": capacity,
		"items": i_data,
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
	
	self.capacity = data["capacity"]
	
	# Items
	var _parsed = JSON.parse_string(data["items"])
	for _item_data: Dictionary in _parsed:
		var item: Item = Item.new()
		item.deserialize(_item_data)
		
		self.add(item)

#endregion



