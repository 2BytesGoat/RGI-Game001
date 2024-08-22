extends UtilityAIAction


func start_action(actor) -> void:
	pass

func execute_action(actor) -> void:
	if actor.current_target == null:
		is_finished = true
		return
	actor.look_at_position(actor.current_target.global_position)
	var new_direction = actor.global_position.direction_to(actor.current_target.global_position)
	actor.desired_velocity = new_direction * actor.SPEED

func end_action(actor) -> void:
	actor.desired_velocity = Vector2.ZERO
