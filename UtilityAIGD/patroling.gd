extends UtilityAIAction


func start_action(actor) -> void:
	pass

func execute_action(actor) -> void:
	if actor.current_target != null or len(actor.patrol_locations) == 0:
		actor.desired_velocity = Vector2.ZERO
		is_finished = true
		return
	
	var target_position = actor.patrol_locations[0]
	var distance_to_target = actor.global_position.distance_to(target_position)
	if distance_to_target <= 10:
		actor.patrol_locations.pop_front()
		return execute_action(actor)
	
	actor.look_at_position(target_position)
	var new_direction = actor.global_position.direction_to(target_position)
	actor.desired_velocity = new_direction * actor.SPEED

func end_action(actor) -> void:
	pass
