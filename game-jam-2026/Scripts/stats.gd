extends Node

# Main stats
@export var SPAWN_TIMER : float = 1.0

# Player stats
var PLAYER_SPEED = 100.0 # Player speed
var PLAYER_FIRE_RATE := 0.5 # Bow fire rate
var PLAYER_TRANSFORM_FIRE_RATE := .25 # Swipe fire rate
var PLAYER_MAX_LIVES := 5 # Total lives
var player_lives : int
var PLAYER_XP_TO_NEXT_LEVEL := 100 # XP needed for first level
var PLAYER_IMMUNITY_TIME := 1.0 # Time after taking damage the player is immune for
var PLAYER_TRANSFORM_TIME := 5.0 # How long the player can be transformed for

# Enemy stats
var ENEMY_SPEED := 40.0 # Enemy speed
var ENEMY_HEALTH := 10.0 # Enemy health
var ENEMY_DAMAGE := 1 # Enemy damage

# Arrow stats
@export var ARROW_DAMAGE := 5.0 # Damage dealt
@export var ARROW_SPEED: float = 150.0 # Velocity in units/s
@export var ARROW_MAX_DISTANCE: float = 100.0 # Max distance in units

# Swipe stats
@export var SWIPE_DAMAGE := 5.0 # Swipe damage
@export var SWIPE_SPEED: float = 150.0 # Swipe speed in units/s
@export var SWIPE_MAX_DISTANCE: float = 25.0 # Swipe distance in units

# Power-up stats
@export var CARD_CHOICES := 3 # How many cards show on level up

signal stat_changed(stat: String) # Emitted when a power-up changes a stat

var _defaults := {} # Starting values, used to reset between runs

# Remember every stat's starting value
func _ready() -> void:
	for prop in get_script().get_script_property_list():
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and not prop.name.begins_with("_"):
			_defaults[prop.name] = get(prop.name)

# Change a stat by name. Used by power-ups.
func modify(stat: String, type: StatModifier.Type, value: float) -> void:
	if not _defaults.has(stat):
		push_error("Stats has no stat called " + stat)
		return
	var current = get(stat)
	var result: float = current + value if type == StatModifier.Type.ADD else current * value
	if typeof(current) == TYPE_INT:
		set(stat, roundi(result)) # Keep int stats (like MAX_LIVES) as ints
	else:
		set(stat, result)
	stat_changed.emit(stat)

# Put every stat back to its starting value (call when a run starts)
func reset() -> void:
	for stat in _defaults:
		set(stat, _defaults[stat])
