extends Area2D

@export var speed: float = 600.0
@export var max_distance: float = 400.0
@export var decay_time: int = 2
@export var decay_color := Color(0.398, 0.398, 0.398, 1.0)

var direction: Vector2 = Vector2.RIGHT
var distance_traveled: float = 0.0

func _physics_process(delta: float) -> void:
	var step := speed * delta
	position += direction * step
	distance_traveled += step

	if distance_traveled >= max_distance:
		speed = 0
		$Sprite2D.modulate = decay_color
		await get_tree().create_timer(decay_time).timeout
		queue_free()

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not distance_traveled >= max_distance:
		area.queue_free()
		queue_free()
