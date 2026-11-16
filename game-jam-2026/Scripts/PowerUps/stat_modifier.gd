@tool
class_name StatModifier
extends Resource
## One stat change, e.g. ARROW_DAMAGE x1.5 or PLAYER_MAX_LIVES +1

const STATS_SCRIPT_PATH := "res://Scripts/stats.gd" # Update this if you move stats.gd

enum Type { ADD, MULTIPLY }

@export var stat: String = ""
@export var type: Type = Type.MULTIPLY
@export var value: float = 1.25 # MULTIPLY: 1.25 = +25%, 0.8 = -20%. ADD: flat amount

# Turns "stat" into a dropdown of every variable in stats.gd
func _validate_property(property: Dictionary) -> void:
	if property.name != "stat":
		return
	var names := PackedStringArray()
	var script: Script = load(STATS_SCRIPT_PATH)
	for p in script.get_script_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and not p.name.begins_with("_"):
			names.append(p.name)
	property.hint = PROPERTY_HINT_ENUM
	property.hint_string = ",".join(names)
