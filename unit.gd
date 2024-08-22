extends CharacterBody2D

@onready var sensor_vision = $UtilityAIAgent/SensorVision
@onready var sensor_attack = $UtilityAIAgent/SensorAttack
@onready var tracking_target = $UtilityAIAgent/TrackingTarget
@onready var proximity_to_enemy = $UtilityAIAgent/ProximityToEnemy
@onready var is_patrol_locations = $UtilityAIAgent/IsPatrolLocations

@onready var aggression_level = $UtilityAIAgent/AggresivityLevel

@onready var ai = $UtilityAIAgent

var current_behaviour: UtilityAIBehaviour
var current_action: UtilityAIAction
var current_target

var aggression_level_scale = 100

var desired_velocity: Vector2
var SPEED = 150
var ACCELERATION = 1000

var patrol_locations = []


func _physics_process(delta):
	sensor_vision.from_vector = global_position
	sensor_attack.from_vector = global_position
	is_patrol_locations.boolean_value = len(patrol_locations) > 0
	
	var areas_in_sight = sensor_vision.unoccluded_areas
	if areas_in_sight.size() > 0:
		if current_target == null:
			current_target = get_closest_area_owner(areas_in_sight)
	else:
		current_target = null
	
	if current_target != null:
		tracking_target.boolean_value = true
		proximity_to_enemy.from_vector = global_position
		proximity_to_enemy.to_vector = current_target.global_position
		var aggression_modifier = 1 - min(1.0, proximity_to_enemy.distance / 256) # TODO: replace 128 with range of vision area
		aggression_level.range_value += aggression_level_scale * aggression_modifier * delta
		if len(patrol_locations) > 0:
			aggression_level.range_value = 100
			patrol_locations = []
	else:
		tracking_target.boolean_value = false
		proximity_to_enemy.from_vector = Vector2.ZERO
		proximity_to_enemy.to_vector = Vector2.ZERO
		aggression_level.range_value -= aggression_level_scale * 0.1 * delta
	%AggresionBar.value = aggression_level.range_value
	
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
	patrol_locations.append(projectile.source_position)
	projectile.queue_free()
