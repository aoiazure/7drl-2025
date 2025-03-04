class_name TileLookup

const GenericFloorAtlas:= Vector2i(5, 16)

const FLOOR: Dictionary[Vector2i, AtlasTexture] = {
	# Floor
	GenericFloorAtlas: preload("res://assets/sprites/tiles/tile_basic.tres"),
	# Plants
	Vector2i(7, 25): preload("res://assets/sprites/tiles/tile_floor_plant_0.tres"),
	Vector2i(7, 26): preload("res://assets/sprites/tiles/tile_floor_plant_1.tres"),
	Vector2i(7, 27): preload("res://assets/sprites/tiles/tile_floor_plant_2.tres"),
	Vector2i(7, 28): preload("res://assets/sprites/tiles/tile_floor_plant_3.tres"),
	Vector2i(8, 25): preload("res://assets/sprites/tiles/tile_floor_plant_4.tres"),
	Vector2i(8, 26): preload("res://assets/sprites/tiles/tile_floor_plant_5.tres"),
	Vector2i(8, 27): preload("res://assets/sprites/tiles/tile_floor_plant_6.tres"),
	Vector2i(8, 28): preload("res://assets/sprites/tiles/tile_floor_plant_7.tres"),
}
const TREES: Dictionary[Vector2i, AtlasTexture] = {
	# Trees
	Vector2i(9, 25): preload("res://assets/sprites/tiles/tile_tree_0.tres"),
	Vector2i(9, 26): preload("res://assets/sprites/tiles/tile_tree_1.tres"),
}

const WALLS: Dictionary[Vector2i, AtlasTexture] = {
	# Wall
	Vector2i(0, 9): preload("res://assets/sprites/tiles/tile_wall_0.tres"),
}
