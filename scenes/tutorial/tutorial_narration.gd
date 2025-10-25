class_name TutorialNarration
extends CenterContainer

signal narration_finished

@onready var panel: PanelContainer = $PanelContainer
@onready var label: Label = $PanelContainer/MarginContainer/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_text: String = ""
var is_visible_now: bool = false


func _ready() -> void:
	hide()
	panel.modulate.a = 0.0


func show_narration(text: String) -> void:
	current_text = text
	label.text = text
	is_visible_now = true
	show()
	
	# Fade in animation
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)


func hide_narration() -> void:
	if not is_visible_now:
		return
	
	is_visible_now = false
	
	# Fade out animation
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(panel, "modulate:a", 0.0, 0.2)
	tween.finished.connect(
		func():
			hide()
			narration_finished.emit()
	)


func update_text(text: String) -> void:
	current_text = text
	
	# Quick fade for text change
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func(): label.text = text)
	tween.tween_property(label, "modulate:a", 1.0, 0.1)
