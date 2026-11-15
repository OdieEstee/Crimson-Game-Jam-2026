extends Area2D

@export var damage := 5.0
@export var speed: float = 150.0
@export var max_distance: float = 400.0

var direction: Vector2 = Vector2.RIGHT
var distance_traveled: float = 0.0

func _physics_process(delta: float) -> void:
	var step := speed * delta
	position += direction * step
	distance_traveled += step

	if distance_traveled >= max_distance:
		speed = 0
		queue_free()

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not distance_traveled >= max_distance:
		if area is Enemy:
			area.take_damage(damage)
		queue_free()
