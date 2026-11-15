extends Node2D
const ENEMY_SCENE := preload("res://enemy.tscn")

@export var spawn_timer := 1.0
@export var spawn_offset := 10.0

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var camera: Camera2D = $CharacterBody2D/Camera2D
@onready var hud = $HUD



func _ready():
	player.lives_changed.connect(hud.set_lives)
	hud.set_lives(player.lives, player.MAX_LIVES)
	var timer := Timer.new()
	timer.wait_time = spawn_timer
	timer.autostart = true
	timer.timeout.connect(spawn_enemy)
	add_child(timer)

func spawn_enemy() -> void:
	var view_size := get_viewport_rect().size / camera.zoom
	var radius := (view_size.length() / 2.0) + spawn_offset
	var angle := randf() * TAU
	
	var enemy := ENEMY_SCENE.instantiate()
	enemy.global_position = camera.get_screen_center_position() + Vector2.RIGHT.rotated(angle) * radius
	enemy.player = player
	add_child(enemy)
