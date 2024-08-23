extends Node2D
class_name TileMapNavigation

@onready var ground_layer: TileMapLayer = $GroundLayer

var map_size = null
var astar = AStar2D.new()

var navigation_path = []
var start_end_coords = {} : set = update_naviagation_path


func _ready():
	for cell in ground_layer.get_used_cells():
		var cell_id = get_cell_id(cell)
		if not astar.has_point(cell_id):
			astar.add_point(cell_id, cell, 1.0)
		for n_cell in get_cell_neighbours(cell):
			var n_cell_id = get_cell_id(n_cell)
			if not astar.has_point(n_cell_id):
				astar.add_point(n_cell_id, n_cell, 1.0)
			astar.connect_points(cell_id, n_cell_id, false)

func get_cell_id(cell):
	if map_size == null:
		map_size = ground_layer.get_used_rect().size
	return cell.y * map_size.x + cell.x

func get_cell_by_id(cell_id):
	if map_size == null:
		map_size = ground_layer.get_used_rect().size
	var x_pos = int(cell_id / map_size.x)
	var y_pos = int(cell_id % map_size.x)
	return Vector2i(x_pos, y_pos)

func get_cell_neighbours(cell):
	var neighbours = []
	for direction in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var n_cell = cell + direction
		var n_alt_tile = ground_layer.get_cell_alternative_tile(n_cell)
		if n_alt_tile != -1:
			neighbours.append(n_cell)
	return neighbours

func global_to_map(target_global_position):
	return ground_layer.local_to_map(ground_layer.to_local(target_global_position))

func map_to_global(cell):
	return ground_layer.to_global(ground_layer.map_to_local(cell))

func get_next_cell_position():
	if len(navigation_path) > 0:
		return map_to_global(navigation_path[0])
	return null

func pop_first_navigation_path():
	navigation_path.remove_at(0)

func update_naviagation_path(new_start_end):
	start_end_coords = new_start_end
	var start_cell = global_to_map(start_end_coords["start"])
	var start_cell_id = get_cell_id(start_cell)
	var end_cell = global_to_map(start_end_coords["end"])
	var end_cell_id = get_cell_id(end_cell)
	print(start_cell, start_cell_id, end_cell, end_cell_id, map_size)
	navigation_path = astar.get_point_path(start_cell_id, end_cell_id)
	print(start_cell, end_cell, navigation_path)
