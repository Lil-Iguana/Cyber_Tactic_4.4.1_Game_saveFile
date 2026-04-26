class_name StatsUI
extends HBoxContainer

@onready var block: HBoxContainer = $Block
@onready var block_label: Label = %BlockLabel
@onready var health_bar_ui: HealthBarUI = $HealthBarUI
@onready var spell: SpellUI = $SpellUI

func update_stats(stats: Stats) -> void:
	block_label.text = str(stats.block)
	spell.update_stats(stats)
	health_bar_ui.update_stats(stats)
	
	block.visible = stats.block > 0
	spell.visible = stats.max_spell > 0
	health_bar_ui.visible = stats.health > 0
