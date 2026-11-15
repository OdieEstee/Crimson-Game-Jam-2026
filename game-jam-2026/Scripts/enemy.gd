class_name Enemy # Global class name
extends Area2D

@export var SPEED := 40.0 # Enemy speed
@export var HEALTH := 5.0 # Enemy health (chaning to 5 for testing, og 10) 
@export var DAMAGE := 1 # Enemy damage

@export var XP_REWARD := 25 # xp awarded when enemy dies

@onready var health_fill : ColorRect = $HealthBar/Fill # HealthBar Fill node

var current_health : float # Current health
var player: CharacterBody2D # Player node (not loaded)
var health_width : float # Width of health bar

# Set enemy up
func _ready():
	current_health = HEALTH # Set current_health to HEALTH
	health_width = health_fill.size.x # Set width of health bar to current size
	update_health_bar() # Function to update health bar

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player): # Check if there is a valid player
		return
	global_position = global_position.move_toward(player.global_position, SPEED * delta) # Follow script to go to players position

func take_damage(damage_taken: int) -> void:
	print("Enemy ID: ", get_instance_id()) #error checking
	
	current_health -= damage_taken # Reduce health by damage taken
	update_health_bar() # Function to update health bar
	
	print("Enemy health remaining: ", current_health) #error checking
	
	if current_health <= 0: # Death check
		print("Enemy Died") # error checking 
		
		if is_instance_valid(player): # check if player exist
			print("Player found! Awarding xp: ", XP_REWARD) #error checking
			player.gain_xp(XP_REWARD) # award XP to player
		else:
			print("ERROR: player refernce invalid") #error checking
	queue_free() # Despawn Enemy

# Updates the visual health bar
func update_health_bar() -> void:
	var ratio := clampf(current_health / HEALTH, 0.0, 1.0) # Calculates the percentage of health left
	health_fill.size.x = health_width * ratio # Set HealthBar Fill size to current percentage of health left
	if ratio <= 0.25: # Set color to red if health is 25% or less
		health_fill.color = Color(1.0, 0.0, 0.0, 1.0)
	elif ratio <= 0.50: # Set color to yellow if health is 50% or less
		health_fill.color = Color(0.873, 0.716, 0.0, 1.0)
