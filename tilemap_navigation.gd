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
			for n_cell in ground_layer.get_surrounding_cells(cell):
				var n_alt_tile = ground_layer.get_cell_alternative_tile(n_cell)
				if n_alt_tile == -1:
					continue
				var n_cell_id = get_cell_id(n_cell)
				if not astar.has_point(n_cell_id):
					astar.add_point(n_cell_id, cell, 1.0)
				# TODO: maybe remove bidirectional connection
				astar.connect_points(cell_id, n_cell_id)

func get_cell_id(cell):
	if map_size == null:
		map_size = ground_layer.get_used_rect().size
	return cell.y * map_size.x + cell.x

func global_to_map(target_global_position):
	return ground_layer.local_to_map(ground_layer.to_local(target_global_position))

func get_next_cell_position():
	pass

func update_naviagation_path(new_start_end):
	start_end_coords = new_start_end
	var start_cell = global_to_map(start_end_coords["start"])
	var end_cell = global_to_map(start_end_coords["end"])
	navigation_path = astar.get_point_path(get_cell_id(start_cell), get_cell_id(end_cell))
	print(navigation_path)
