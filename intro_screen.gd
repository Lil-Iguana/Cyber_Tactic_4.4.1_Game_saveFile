class_name IntroScreen
extends Control

const RUN_SCENE := preload("res://scenes/run/run.tscn")

@export var character: CharacterStats

@onready var begin_button: Button = %BeginButton
@onready var panel_1 := %Panel1
@onready var panel_2 := %Panel2
@onready var panel_3 := %Panel3
@onready var panel_4 := %Panel4


func _ready() -> void:
	MusicPlayer.stop()
	
	match character.character_name:
		"Student":
			panel_1.set_texture("panel_student_01")
			panel_2.set_texture("panel_student_02")
			panel_3.set_texture("panel_student_03")
			panel_4.set_texture("panel_student_04")
		_:
			print("Unknown character name. This shouldn't happen.")
	
	var tween = create_tween().set_trans(Tween.TRANS_QUINT)
	
	tween.tween_interval(1)
	tween.tween_callback(panel_1.animation_player.play.bind("fadein"))
	tween.tween_interval(2)
	tween.tween_callback(panel_2.animation_player.play.bind("fadein"))
	tween.tween_interval(2)
	tween.tween_callback(panel_3.animation_player.play.bind("fadein"))
	tween.tween_interval(2)
	tween.tween_callback(panel_4.animation_player.play.bind("fadein"))
	tween.tween_interval(2)
	tween.tween_property(begin_button, "visible", true, 0.4)


func _on_begin_button_pressed() -> void:
	get_tree().change_scene_to_packed(RUN_SCENE)
	queue_free()
