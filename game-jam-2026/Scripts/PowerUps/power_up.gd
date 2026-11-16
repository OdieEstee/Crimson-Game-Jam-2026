class_name PowerUp
extends Resource
## A level-up card. One .tres file per power-up in res://PowerUps/

@export var title := "Power Up"
@export_multiline var description := ""
@export var weight := 100.0 # Higher = more common. Chance = weight / total weight of eligible cards
@export var max_stacks := 0 # Times it can be picked per run. 0 = unlimited
@export var color := Color(0.2, 0.25, 0.35) # Placeholder until card backgrounds are done
@export var modifiers: Array[StatModifier] = []

# Applies every modifier. Override in a subclass for special effects
func apply(main: Node) -> void:
	for mod in modifiers:
		Stats.modify(mod.stat, mod.type, mod.value)
