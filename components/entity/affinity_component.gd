## Component that tracks faction alignment and relationship.
class_name Affinity extends EComponent

enum Affiliation {
	NONE,		## Unaffiliated.
	PLAYER,		## Ally of the player.
	ENEMY, 		## Enemy of the player.
}

var affiliation: Affiliation

static func create(_affiliation: Affiliation) -> Affinity:
	var a:= Affinity.new()
	a.affiliation = _affiliation
	
	return a

func is_friendly(other_entity: Entity) -> bool:
	var a: Affinity = other_entity.get_component_or_null(Components.AFFINITY)
	return is_instance_valid(a) and a.affiliation == affiliation 



#region Saving and Loading
func serialize() -> Dictionary:
	var data: Dictionary = super()
	var new_data: Dictionary = {
		
	}
	
	data.merge(new_data, true)
	return data

func deserialize(data: Dictionary) -> void:
	super(data)
#endregion



