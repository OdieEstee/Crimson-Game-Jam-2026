extends CanvasLayer

@export var heart_texture: Texture2D
@export var empty_heart_texture: Texture2D
@export var heart_size := Vector2(32, 32)

@onready var hearts: HBoxContainer = $Root/Hearts

func set_lives(lives: int, max_lives: int) -> void:
	for child in hearts.get_children():
		hearts.remove_child(child)
		child.queue_free()

	for i in max_lives:
		var heart := TextureRect.new()
		heart.texture = heart_texture if i < lives else empty_heart_texture
		heart.custom_minimum_size = heart_size
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hearts.add_child(heart)
