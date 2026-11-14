extends CharacterBody2D

@export var SPEED = 100.0
@export var FIRE_RATE := 0.5
@onready var bow: Sprite2D = $Bow
var shot_cooldown := 0.0
const ARROW_SCENE := preload("res://arrow.tscn")

func _physics_process(delta: float) -> void:
	#Player movement start
	var vertical_direction := Input.get_axis("Up", "Down")
	if vertical_direction:
		velocity.y = vertical_direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	var horizontal_direction := Input.get_axis("Left", "Right")
	if horizontal_direction:
		velocity.x = horizontal_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	#Player movement end
	
	#Bow and arrow start
	var mouse_pos := get_global_mouse_position()
	bow.look_at(mouse_pos)
	bow.flip_v = mouse_pos.x < global_position.x
	
	shot_cooldown -= delta
	if Input.is_action_pressed("Attack") and shot_cooldown <= 0.0:
		shoot()
		shot_cooldown = FIRE_RATE
	#Bow and arrow end

func shoot() -> void:
	var arrow := ARROW_SCENE.instantiate()
	arrow.global_position = bow.to_global(bow.offset)
	arrow.global_rotation = bow.global_rotation
	arrow.direction = Vector2.RIGHT.rotated(bow.global_rotation)
	get_tree().current_scene.add_child(arrow)
