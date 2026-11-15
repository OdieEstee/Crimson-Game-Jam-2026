extends Area2D

@export var DAMAGE := 5.0 # Swipe damage
@export var SPEED: float = 150.0 # Swipe speed in units/s
@export var MAX_DISTANCE: float = 400.0 # Swipe distance in units

var direction: Vector2 = Vector2.RIGHT # Base direction vector, modified when shoot() is called in Player
var distance_traveled: float = 0.0 # Track distance traveled

func _physics_process(delta: float) -> void:
	var step := SPEED * delta # Calculate step distance for each frame by SPEED
	position += direction * step # Change position by step distance with the angle of direction
	distance_traveled += step # Track distance traveled

	if distance_traveled >= MAX_DISTANCE: # Check if swipe distance met MAX_DISTANCE
		queue_free() # Despwan swipe

# Connect area_entered signal with function _on_area_entered(area: Area2D)
func _ready() -> void:
	area_entered.connect(_on_area_entered)

# Called when area_entered signal is recieved
func _on_area_entered(area: Area2D) -> void:
	if not distance_traveled >= MAX_DISTANCE: # 
		if area is Enemy: # Check if overlapping area is an Enemy
			area.take_damage(DAMAGE) # Call take_damage function in Enemy
