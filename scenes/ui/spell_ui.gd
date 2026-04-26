class_name SpellUI
extends HBoxContainer

@export var show_max_spell: bool = true

@onready var spell_label: Label = %SpellLabel
@onready var max_spell_label: Label = %MaxSpellLabel

func update_stats(stats: Stats) -> void:
	spell_label.text = str(stats.spell)
	max_spell_label.text = "/%s" % str(stats.max_spell)
	max_spell_label.visible = show_max_spell
