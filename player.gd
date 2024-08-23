extends CharacterBody2D

enum CONTROLLER_TYPES {
	BUTTONS,
	POINT_AND_CLICK,
}

@export var controller: CONTROLLER_TYPES = CONTROLLER_TYPES.BUTTONS
@export var tilemap_navigation: TileMapNavigation

var MAX_SPEED = 220
var ACCELERATION = 800
var FRICTION = 300

@onready var character_controller = $CharacterController
@onready var Projectile = load("res://Projectile.tscn")


func _ready():
	character_controller.tilemap_navigation = tilemap_navigation

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_mouse_button"):
		if controller == CONTROLLER_TYPES.POINT_AND_CLICK:
			character_controller.set_target_position(event.global_position)

func _process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	if controller == CONTROLLER_TYPES.BUTTONS:
		direction = character_controller.get_move_direction_button()
	elif controller == CONTROLLER_TYPES.POINT_AND_CLICK:
		direction = character_controller.get_next_direction_tilemap()
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_slide()

func _on_q_button_pressed() -> void:
	var mouse_position = get_global_mouse_position()
	var projectile_direction = global_position.direction_to(mouse_position)
	var projectile = Projectile.instantiate()
	projectile.direction = projectile_direction
	projectile.global_position = global_position
	projectile.look_at(mouse_position)
	projectile.source = self
	get_parent().add_child(projectile)
