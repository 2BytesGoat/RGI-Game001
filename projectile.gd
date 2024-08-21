extends Node2D

var speed = 500
var direction = Vector2.ZERO
var source = null
var source_position: Vector2

func _ready():
	source_position = global_position

func _process(delta: float) -> void:
	position += speed * direction * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
