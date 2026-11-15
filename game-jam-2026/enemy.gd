class_name Enemy
extends Area2D

@export var speed := 40.0
@export var health := 10.0
@export var damage := 1

var current_health : float
var player: CharacterBody2D
var health_width : float

@onready var health_fill : ColorRect = $HealthBar/Fill

func _ready():
	current_health = health
	health_width = health_fill.size.x
	update_health_bar()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	global_position = global_position.move_toward(player.global_position, speed * delta)

func take_damage(damage: int) -> void:
	current_health -= damage
	update_health_bar()
	if current_health <= 0:
		queue_free()

func update_health_bar() -> void:
	var ratio := clampf(current_health / health, 0.0, 1.0)
	health_fill.size.x = health_width * ratio
	if ratio <= 0.25:
		health_fill.color = Color(1.0, 0.0, 0.0, 1.0)
	elif ratio <= 0.50:
		health_fill.color = Color(0.873, 0.716, 0.0, 1.0)
