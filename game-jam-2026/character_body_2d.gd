extends CharacterBody2D

signal lives_changed(lives: int, max_lives: int)

@export var SPEED = 100.0
@export var FIRE_RATE := 0.5
@export var MAX_LIVES := 3.0
@export var IMMUNITY_TIME := 1.0
@export var TRANSFORM_TIME := 15.0
@onready var bow: Sprite2D = $Bow

var lives : int
var shot_cooldown := 0.0
var immunity_cooldown := 0.0
var transform_timer : float
var is_transformed = false
const ARROW_SCENE := preload("res://arrow.tscn")

func _ready() -> void:
	lives = MAX_LIVES

func take_damage(damage: int) -> void:
	lives -= damage
	lives_changed.emit(lives, MAX_LIVES)
	if lives <= 0:
		queue_free()

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
	if Input.is_action_pressed("Attack") and shot_cooldown <= 0.0 and not is_transformed:
		shoot()
		shot_cooldown = FIRE_RATE
	#Bow and arrow end
	
	#Damage check start
	immunity_cooldown -= delta
	if immunity_cooldown <= 0.0:
		for area in $Hitbox.get_overlapping_areas():
			if area is Enemy:
				take_damage(area.damage)
				immunity_cooldown = IMMUNITY_TIME
				break
	#Damage check end
	
	#Transform start
	transform_timer -= delta
	if transform_timer < 0:
		is_transformed = false
		$Bow.visible = true
	if Input.is_action_just_pressed("Transform") and transform_timer < 0:
		transform_timer = TRANSFORM_TIME
		is_transformed = true
		$Bow.visible = false
		
	#Transform end

func shoot() -> void:
	var arrow := ARROW_SCENE.instantiate()
	arrow.global_position = bow.to_global(bow.offset)
	arrow.global_rotation = bow.global_rotation
	arrow.direction = Vector2.RIGHT.rotated(bow.global_rotation)
	get_tree().current_scene.add_child(arrow)
