class_name PowerUpMenu
extends CanvasLayer
## Pauses the game on the LevelUp key (when a level-up is banked) and shows weighted-random cards

const POWER_UP_DIR := "res://PowerUps/"
const CARD_SIZE := Vector2(220, 300)

var pending_level_ups := 0 # Level-ups the player hasn't spent yet
var pool: Array[PowerUp] = [] # Every power-up found in POWER_UP_DIR
var stacks := {} # PowerUp -> times picked this run

var _overlay: ColorRect
var _card_row: HBoxContainer
var _hint: Label
var _shown: Array[PowerUp] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Keep working while the game is paused
	layer = 10 # Draw above the HUD
	_load_pool()
	_build_ui()
	_update_hint()

# Connected to player.leveled_up
func on_level_up() -> void:
	pending_level_ups += 1
	_update_hint()

func _unhandled_input(event: InputEvent) -> void:
	if not _overlay.visible:
		if event.is_action_pressed("LevelUp") and pending_level_ups > 0:
			_open()
			get_viewport().set_input_as_handled()
		return
	# While open, number keys 1-9 also pick a card
	if event is InputEventKey and event.pressed and not event.echo:
		var index: int = event.keycode - KEY_1
		if index >= 0 and index < _shown.size():
			_choose(_shown[index])
			get_viewport().set_input_as_handled()

# Weighted random pick of `count` different power-ups, skipping maxed ones
func roll(count: int) -> Array[PowerUp]:
	var candidates: Array[PowerUp] = []
	candidates.assign(pool.filter(func(p: PowerUp) -> bool:
		return p.weight > 0.0 and (p.max_stacks == 0 or stacks.get(p, 0) < p.max_stacks)))

	var picked: Array[PowerUp] = []
	while picked.size() < count and not candidates.is_empty():
		var total := 0.0
		for p in candidates:
			total += p.weight
		var r := randf() * total
		var index := candidates.size() - 1 # Fallback for float rounding
		for i in candidates.size():
			r -= candidates[i].weight
			if r < 0.0:
				index = i
				break
		picked.append(candidates[index])
		candidates.remove_at(index) # No duplicates in one roll
	return picked

func _open() -> void:
	_shown = roll(Stats.CARD_CHOICES)
	if _shown.is_empty(): # Everything is maxed out
		pending_level_ups = 0
		_update_hint()
		return
	for i in _shown.size():
		_card_row.add_child(_make_card(_shown[i], i + 1))
	_overlay.visible = true
	_hint.visible = false
	get_tree().paused = true

func _choose(p: PowerUp) -> void:
	p.apply(get_parent()) # Parent is Main
	stacks[p] = stacks.get(p, 0) + 1
	pending_level_ups -= 1
	_close()

func _close() -> void:
	for card in _card_row.get_children():
		card.queue_free()
	_shown.clear()
	_overlay.visible = false
	get_tree().paused = false
	_update_hint()

func _load_pool() -> void:
	for file in DirAccess.get_files_at(POWER_UP_DIR):
		file = file.trim_suffix(".remap") # Exported builds rename resources
		if file.ends_with(".tres") or file.ends_with(".res"):
			var res := load(POWER_UP_DIR + file)
			if res is PowerUp:
				pool.append(res)
	print("Loaded %d power-ups" % pool.size())

func _build_ui() -> void:
	# "LEVEL UP! Press E" banner
	_hint = Label.new()
	_hint.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_hint.offset_top = 40
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 24)
	add_child(_hint)

	# Dimmed full-screen backdrop
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.6)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = false
	add_child(_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)

	_card_row = HBoxContainer.new()
	_card_row.add_theme_constant_override("separation", 24)
	center.add_child(_card_row)

func _make_card(p: PowerUp, number: int) -> Control:
	var card := ColorRect.new() # Swap for TextureRect when backgrounds are ready
	card.custom_minimum_size = CARD_SIZE
	card.color = p.color
	card.mouse_filter = Control.MOUSE_FILTER_STOP

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 16
	box.offset_top = 16
	box.offset_right = -16
	box.offset_bottom = -16
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 12)
	card.add_child(box)

	box.add_child(_label("[%d]" % number, 14))
	box.add_child(_label(p.title, 24))
	box.add_child(_label(p.description, 16))
	if p.max_stacks > 0:
		box.add_child(_label("%d / %d" % [stacks.get(p, 0), p.max_stacks], 14))

	card.mouse_entered.connect(func(): card.color = p.color.lightened(0.2))
	card.mouse_exited.connect(func(): card.color = p.color)
	card.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_choose(p))
	return card

func _label(text: String, font_size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", font_size)
	return l

func _update_hint() -> void:
	var events := InputMap.action_get_events("LevelUp")
	var key := events[0].as_text().replace(" (Physical)", "") if not events.is_empty() else "?"
	_hint.text = "LEVEL UP! Press %s  (%d)" % [key, pending_level_ups]
	_hint.visible = pending_level_ups > 0 and not _overlay.visible
