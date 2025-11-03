class_name HealthBarUI
extends Control

@export var show_max_hp: bool

@onready var health_label: Label = %HealthLabel
@onready var max_health_label: Label = %MaxHealthLabel
@onready var health_bar: ProgressBar = %HealthBar

# Bar colors
const HP_COLOR = Color("#ff0000")  # Red
const SHIELD_COLOR = Color("#383858")  # Dark blue/purple


func update_stats(stats: Stats) -> void:
	health_label.text = str(stats.health)
	max_health_label.text = "/%s" % str(stats.max_health)
	max_health_label.visible = show_max_hp
	
	# Update progress bar
	health_bar.max_value = stats.max_health
	health_bar.value = stats.health
	
	# Change bar color based on shield
	if stats.block > 0:
		health_bar.modulate = SHIELD_COLOR
	else:
		health_bar.modulate = HP_COLOR
