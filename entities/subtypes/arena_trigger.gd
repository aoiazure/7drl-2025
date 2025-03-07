class_name ArenaTrigger extends Entity



func _ready() -> void:
	super()
	
	self.blocks_movement = false
	self.blocks_vision = false
	
	MapSignalBus.arena_entrance_triggered.connect(
		func():
			map_data.remove_entity(self)
			self.queue_free()
	)
	
	MapSignalBus.player_position_changed.connect(
		func(_o, _n):
			if _n == self.grid_position:
				MapSignalBus.arena_entrance_triggered.emit()
	)

#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		"type": "ArenaTrigger",
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion


