extends Node

var min_distance_to_target = 10
var target_global_position = null


func get_move_direction_button() -> Vector2:
	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	direction = direction.normalized()
	return direction

func set_target_position(new_target_global_position: Vector2):
	target_global_position = new_target_global_position

func get_move_direction_target_position() -> Vector2:
	if target_global_position == null:
		return Vector2.ZERO
	
	var distance = owner.global_position.distance_to(target_global_position)
	if distance <= min_distance_to_target:
		return Vector2.ZERO
	
	var current_speed = (owner.velocity.x ** 2 + owner.velocity.y ** 2) ** 0.5
	var direction = owner.global_position.direction_to(target_global_position)
	var direction_scale = min(1.0, distance / current_speed)
	direction = direction.normalized() * direction_scale
	return direction
