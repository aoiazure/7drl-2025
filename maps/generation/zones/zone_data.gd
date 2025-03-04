class_name ZoneData extends Resource

@export var zone_config: ZoneConfig

@export var position: Vector2i
@export var size: Vector2i

var exit_positions: Dictionary[int, ExitData] = {}

static func create(rect: Rect2i) -> ZoneData:
	var z:= ZoneData.new()
	z.position = rect.position
	z.size = rect.size
	
	return z


class ExitData extends Resource:
	## The coordinate for the exit position.
	var position: Vector2i
	## The index id for the Zone this is connected to. Corresponds to an array index.
	var linked_id: int
	
	static func create(_position: Vector2i, _linked_id: int) -> ExitData:
		var e:= ExitData.new()
		e.position = _position
		e.linked_id = _linked_id
		
		return e

#match direction:
	#0: # N
		#pass
	#1: # E
		#pass
	#2: # S
		#pass
	#3: # W
		#pass


