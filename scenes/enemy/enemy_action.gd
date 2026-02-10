class_name EnemyAction
extends Node

enum Type {CONDITIONAL, CHANCE_BASED}

@export var intent: Intent
@export var sound: AudioStream
@export_multiline var description: String = ""  # Description shown in tooltip
@export var type: Type
@export_range(0.0, 10.0) var chance_weight := 0.0

@onready var accumalated_weight := 0.0

var enemy: Enemy
var target: Node2D


func is_performable() -> bool:
	return false


func perform_action() -> void:
	pass


func update_intent_text() -> void:
	intent.current_text = intent.base_text


# Override this in child classes to provide dynamic descriptions
# that update based on modifiers (buffs/debuffs)
func get_tooltip_description() -> String:
	return description
