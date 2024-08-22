extends UtilityAIAction

var is_attacking = false


func start_action(actor) -> void:
	pass

func execute_action(actor) -> void:
	if is_attacking:
		return
	$Timer.start()
	is_attacking = true

func end_action(actor) -> void:
	actor.desired_velocity = Vector2.ZERO

func _on_timer_timeout() -> void:
	is_attacking = false
