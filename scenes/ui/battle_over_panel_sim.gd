class_name BattleOverPanelSim
extends Panel

const RUN = "res://scenes/run/run.tscn"

enum Type {WIN, LOSE}

@onready var label: Label = %Label
@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	continue_button.pressed.connect(get_tree().change_scene_to_file.bind(RUN))
	Events.battle_over_screen_requested.connect(show_screen)


func show_screen(text: String, type: Type) -> void:
	label.text = text
	continue_button.visible = type == Type.WIN
	show()
