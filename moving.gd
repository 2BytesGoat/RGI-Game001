extends UtilityAIAction


func start_action(actor) -> void:
	pass

func execute_action(actor) -> void:
	if is_finished:
		return 
	if actor.current_target == null:
		is_finished = true
		return
	var new_direction = actor.global_position.direction_to(actor.current_target.global_position)
	actor.desired_velocity = new_direction * actor.SPEED

func end_action(actor) -> void:
	actor.desired_velocity = Vector2.ZERO
