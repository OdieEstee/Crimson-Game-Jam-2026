extends CanvasLayer

@export var heart_texture: Texture2D # Full heart texture
@export var empty_heart_texture: Texture2D # Empty heart texture
@export var heart_size := Vector2(64, 64) # Size of heart on screen

@onready var hearts: HBoxContainer = $Root/Hearts

# Function that is called when lives_changed signal is emitted from the Player
func set_lives(lives: int, max_lives: int) -> void:
	# Clear container of old lives stat
	for child in hearts.get_children():
		hearts.remove_child(child)
		child.queue_free()
	
	# Add new lives stat to container
	for i in max_lives:
		var heart := TextureRect.new() # Create new heart
		heart.texture = heart_texture if i < lives else empty_heart_texture # Set heart texture to full if there is enough lives, otherwise set to empty heart texture
		heart.custom_minimum_size = heart_size # Set heart size
		# Texture settings
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hearts.add_child(heart) # Add heart to container
