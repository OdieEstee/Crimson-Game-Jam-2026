extends Node2D

const ENEMY_SCENE := preload("res://Scenes/enemy.tscn") # Referenced scene for Enemy creation

@export var SPAWN_OFFSET := 10.0 # Offset for Enemy spawn location outside of camera view

@onready var player: CharacterBody2D = $Player # Player node
@onready var camera: Camera2D = $Player/Camera2D # Camera node
@onready var hud = $HUD # HUD node

# On load connect HUD lives to player lives, set up Enemy spawn timer
func _ready():
	# Connect lives_changed signal from player to set_lives(lives, max_lives) in HUD
	player.lives_changed.connect(hud.set_lives)
	# connect xp_changed signal from player to HUD
	player.xp_changed.connect(hud.set_xp)
	
	hud.set_lives(Stats.player_lives, Stats.PLAYER_MAX_LIVES) # Match HUD lives to player lives
	hud.set_xp(player.current_xp, player.xp_needed, player.current_level)#Sets the initial HUD value
	
	# Set up Enemy spawn timer in root
	var timer := Timer.new()
	timer.wait_time = Stats.SPAWN_TIMER
	timer.autostart = true
	timer.timeout.connect(spawn_enemy) # Whenever the timer ends call spawn_enemy()
	add_child(timer)
	
	var power_up_menu := PowerUpMenu.new()
	add_child(power_up_menu)
	player.leveled_up.connect(power_up_menu.on_level_up)

func _enter_tree() -> void:
	Stats.reset()

# Spawn Enemy outside of camera view
func spawn_enemy() -> void:
	var view_size := get_viewport_rect().size / camera.zoom # Global size of camera view
	var radius := (view_size.length() / 2.0) + SPAWN_OFFSET # Radius of camera view
	var angle := randf() * TAU # Random angle
	
	var enemy := ENEMY_SCENE.instantiate()
	enemy.global_position = camera.get_screen_center_position() + Vector2.RIGHT.rotated(angle) * radius # Set Enemy position
	enemy.player = player # Set Enemy target player to real player
	add_child(enemy) # Spawn Enemy
