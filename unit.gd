extends CharacterBody2D

@onready var sensor_vision = $UtilityAIAgent/SensorVision
@onready var sensor_in_range = $UtilityAIAgent/TargetInRange
@onready var sensor_is_visible = $UtilityAIAgent/TargetIsVisible

@onready var aggression_level = $UtilityAIAgent/AggresionLevel
@onready var ai = $UtilityAIAgent

var current_behaviour: UtilityAIBehaviour
var current_action: UtilityAIAction
var current_target
var distance_to_current_target

var aggression_level_scale = 100

var desired_velocity: Vector2
var SPEED = 150
var ACCELERATION = 1000


func _physics_process(delta):
	sensor_vision.from_vector = global_position
	
	var areas_in_sight = sensor_vision.unoccluded_areas
	if areas_in_sight.size() > 0:
		if current_target == null:
			current_target = get_closest_area_owner(areas_in_sight)
	elif aggression_level.range_value > 0:
		current_target = null
	
	if current_target != null:
		var distance = get_distance_to_unit(current_target)
		var aggression_modifier = 1 - min(1.0, distance / 256) # TODO: replace 128 with range of vision area
		aggression_level.range_value += aggression_level_scale * aggression_modifier * delta
	else:
		aggression_level.range_value -= aggression_level_scale * 0.1 * delta
	%AggresionBar.value = aggression_level.range_value
	
	sensor_in_range.boolean_value = false
	if current_target != null:
		var areas_in_attack_range = $AttackArea.get_overlapping_areas()
		for area in areas_in_attack_range:
			if area.owner == current_target:
				sensor_in_range.boolean_value = true
	
	ai.evaluate_options(delta)
	ai.update_current_behaviour()
	
	if current_action != null:
		current_action.execute_action(self)
	velocity = velocity.move_toward(desired_velocity, ACCELERATION * delta)
	move_and_slide()

func get_closest_area_owner(areas):
	var closest_unit = null
	var shortest_distance = INF
	for area in areas:
		if area == null:
			continue
		var distance = get_distance_to_unit(area.owner)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_unit = area.owner
	return closest_unit

func get_distance_to_unit(unit):
	return global_position.distance_to(unit.global_position)

func _on_utility_ai_agent_behaviour_changed(behaviour_node: Object) -> void:
	current_behaviour = behaviour_node
	if current_behaviour != null:
		%WhatDoing.text = current_behaviour.name

func _on_utility_ai_agent_action_changed(action_node):
	if current_action != null:
		current_action.end_action(self)
	current_action = action_node
	if current_action != null:
		current_action.start_action(self)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	aggression_level.range_value += 50
	var projectile = area.owner
	current_target = projectile.source
	projectile.queue_free()
