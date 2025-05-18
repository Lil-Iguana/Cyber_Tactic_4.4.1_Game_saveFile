class_name Stats
extends Resource

enum Element { PHYSICAL, FIRE, WATER, ICE, LIGHTING}

signal stats_changed

@export var max_health := 1
@export var enemy_name: String
@export var art: Texture
@export_multiline var tooltip_text: String
@export_multiline var tooltip_text_real: String
@export var elemental_multipliers := {
	Element.PHYSICAL: 1.0,
	Element.FIRE: 1.0,
	Element.WATER: 1.0,
	Element.ICE: 1.0,
	Element.LIGHTING: 1.0
}

var health: int : set = set_health
var block: int : set = set_block


func set_health(value: int) -> void:
	health = clampi(value, 0, max_health)
	stats_changed.emit()


func set_block(value : int) -> void:
	block = clampi(value, 0, 999)
	stats_changed.emit()


func take_damage(damage : int) -> void:
	if damage <= 0:
		return
	var initial_damage = damage
	damage = clampi(damage - block, 0, damage)
	block = clampi(block - initial_damage, 0, block)
	health -= damage


func take_pure_damage(damage: int) -> void:
	if damage <= 0:
		return
	health -= damage


func heal(amount: int) -> void:
	health += amount


# Helper to get the multiplier for an element (defaults to 1.0 if not found)
func get_elemental_multiplier(elem: Element) -> float:
	if elemental_multipliers.has(elem):
		return elemental_multipliers[elem]
	return 1.0


func create_instance() -> Resource:
	var instance: Stats = self.duplicate()
	instance.health = max_health
	instance.block = 0
	return instance
	
