extends CharacterBody2D

signal lives_changed(lives: int, max_lives: int) # Signal for set_lives() in HUD
signal xp_changed(xp: int, xp_needed: int, level: int) #Signal for XP bar in HUD

@export var SPEED = 100.0 # Player speed
@export var FIRE_RATE := 0.5 # Bow fire rate
@export var TRANSFORM_FIRE_RATE := 2.0 # Swipe fire rate
@export var MAX_LIVES := 3 # Total lives
@export var XP_TO_NEXT_LEVEL := 100 # XP needed for first level
@export var IMMUNITY_TIME := 1.0 # Time after taking damage the player is immune for
@export var TRANSFORM_TIME := 15.0 # How long the player can be transformed for

@onready var bow: Sprite2D = $Bow # Bow node

var lives : int # Current lives
var shot_cooldown := 0.0 # Current shot cooldown
var immunity_cooldown := 0.0 # Current immunity cooldown
var transform_timer : float # Current time transformed
var is_transformed = false # Binary tracking if the player is transformed or not

var current_xp : int = 0 # current xp
var current_level : int = 1 # current player level
var xp_needed : int # XP needed for next level  

const ARROW_SCENE := preload("res://Scenes/arrow.tscn")
const SWIPE_SCENE := preload("res://Scenes/swipe.tscn")

func _ready() -> void:
	lives = MAX_LIVES # Set current lives to MAX_LIVES
	xp_needed = XP_TO_NEXT_LEVEL # Set initial XP requirments

func _physics_process(delta: float) -> void:
	# Player movement
	var direction := Input.get_vector("Left", "Right", "Up", "Down") # Get direction of movement
	if direction != Vector2.ZERO:
		velocity = direction * SPEED # Apply SPEED and the direction to velocity
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	# Attack functionality
	var mouse_pos := get_global_mouse_position() # Find mouse position
	bow.look_at(mouse_pos) # Rotate bow towards mouse position
	bow.flip_v = mouse_pos.x < global_position.x # Flip bow texture if it is on the left side of the player
	
	shot_cooldown -= delta # Reduce shot_cooldown over time
	if Input.is_action_pressed("Attack") and shot_cooldown <= 0.0 and not is_transformed: # Check if shooting is valid
		shoot() # Shoot function
		shot_cooldown = FIRE_RATE # Reset shot_cooldown to FIRE_RATE
	
	if is_transformed and Input.is_action_pressed("Attack") and shot_cooldown <= 0.0: # Check if swipe attack is valid
		swipe_attack() # Swipe attack function
		shot_cooldown = TRANSFORM_FIRE_RATE # Reset shot_cooldown to TRANSFORM_FIRE_RATE
	
	#Damage check
	immunity_cooldown -= delta # Reduce immunity_cooldown over time
	if immunity_cooldown <= 0.0: # Check if player can get damaged again
		for area in $Hitbox.get_overlapping_areas(): # Check for overlapping Area2D within Player collision box
			if area is Enemy: # Check if overlapping Area2D is an Enemy
				take_damage(area.DAMAGE) # Take damage function
				immunity_cooldown = IMMUNITY_TIME # Reset immunity_cooldown to IMMUNITY_TIME
				break # Only one enemy can damage at a time
	
	#Transform functionality
	transform_timer -= delta # Reduce transform_timer over time
	if transform_timer < 0: # Check if transform_timer is up and reset back to normal
		is_transformed = false
		$Bow.visible = true
	if Input.is_action_just_pressed("Transform") and transform_timer < 0: # Check if transformation is valid and set status to transform
		transform_timer = TRANSFORM_TIME # Reset transform_timer to TRANSFORM_TIME
		is_transformed = true
		$Bow.visible = false

# Set up arrow to be shot
func shoot() -> void:
	var arrow := ARROW_SCENE.instantiate() # Create new arrow
	arrow.global_position = bow.to_global(bow.offset) # Set arrow position inside bow position
	arrow.global_rotation = bow.global_rotation # Rotate arrow to point in bow direction
	arrow.direction = Vector2.RIGHT.rotated(bow.global_rotation) # Set arrow direction to bow direction
	get_tree().current_scene.add_child(arrow) # Spawn arrow

# Set up swipe attack
func swipe_attack() -> void:
	var swipe := SWIPE_SCENE.instantiate() # Create new swipe
	swipe.global_position = bow.to_global(bow.offset) # Set swipe position inside bow position
	swipe.global_rotation = bow.global_rotation # Rotate swipe to point in bow direction
	swipe.direction = Vector2.RIGHT.rotated(bow.global_rotation) # Set swipe direction to bow direction
	get_tree().current_scene.add_child(swipe) # Spawn swipe

# Changes lives locally when taking damage and emits lives_changed signal for set_lives in HUD
func take_damage(damage: int) -> void:
	lives -= damage # Lower lives from damage
	lives_changed.emit(lives, MAX_LIVES) # Emit lives_changed signal
	if lives <= 0: # Dead check
		queue_free()

#Adds XP to Player and handles leveling up
func gain_xp(amount : int) -> void:
	current_xp += amount # increase current xp
	
	#check if player has enough xp to level up
	while current_xp >= xp_needed:
		current_xp -= xp_needed #carry over extra xp
		current_level += 1 # increase player level
		xp_needed = int(xp_needed * 1.25) # increases xp requirement by 25%
		
		print("Level UP! Current level: ", current_level)
	xp_changed.emit(current_xp, xp_needed, current_level) #update XP bar in hub
