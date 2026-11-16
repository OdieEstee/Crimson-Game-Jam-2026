extends Area2D

@export var DECAY_TIME: int = 2 # Number of seconds before arrow despawns
@export var DECAY_COLOR := Color(0.398, 0.398, 0.398, 1.0) # Color modulated onto texture when decaying/out of range

var direction: Vector2 = Vector2.RIGHT # Base direction vector, modified when shoot() is called in Player
var distance_traveled: float = 0.0 # Records how far the arrow has travelled in units

# Transforms arrow each frame to follow its trajectory, determines if arrow distance has met max_distance
func _physics_process(delta: float) -> void:
	# Check if arrow distance has met or exceed max_distance, if so despawn it over time
	if distance_traveled >= Stats.ARROW_MAX_DISTANCE:
		$ArrowTexture.modulate = DECAY_COLOR
		await get_tree().create_timer(DECAY_TIME).timeout # Wait DECAY_TIME in seconds
		queue_free() # Despawn arrow
	else:
		var step := Stats.ARROW_SPEED * delta # Distance each frame needs
		position += direction * step # Direction step needs to be taken
		distance_traveled += step # Record total distance traveled
	



# On load connect area_entered signal with _on_area_entered(area)
func _ready() -> void:
	area_entered.connect(_on_area_entered)

# When area_entered signal is recieved, if overlapping area(s) is an Enemy, let Enemy take damage through take_damage(damage) and despawn arrow
func _on_area_entered(area: Area2D) -> void:
	if not distance_traveled >= Stats.ARROW_MAX_DISTANCE:
		if area is Enemy:
			area.take_damage(Stats.ARROW_DAMAGE)
		queue_free()
