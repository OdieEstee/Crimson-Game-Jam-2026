extends Area2D

@export var speed := 40.0

var player: CharacterBody2D

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	global_position = global_position.move_toward(player.global_position, speed * delta)
