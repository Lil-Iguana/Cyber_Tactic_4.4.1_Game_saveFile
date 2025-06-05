class_name IntroScreen
extends Control

const RUN_SCENE := preload("res://scenes/run/run.tscn")

@export var character: CharacterStats

@onready var begin_button: Button = %BeginButton
@onready var panel_1 := %Panel1
@onready var panel_2 := %Panel2
@onready var panel_3 := %Panel3
@onready var panel_4 := %Panel4
@onready var panel_5 := %Panel5
@onready var panel_6 := %Panel6
@onready var panel_7 := %Panel7
@onready var panel_8 := %Panel8
@onready var panel_9 := %Panel9
@onready var panel_10 := %Panel10
@onready var panel_11 := %Panel11
@onready var panel_12 := %Panel12
@onready var panel_13 := %Panel13
@onready var panel_14 := %Panel14
@onready var panel_15 := %Panel15

@onready var skip_button: Button = %SkipButton


func _ready() -> void:
	MusicPlayer.stop()
	
	match character.character_name:
		"Student":
			panel_1.set_texture("panel_student_01")
			panel_1.set_text()
			panel_2.set_texture("panel_student_02")
			panel_2.set_text()
			panel_3.set_texture("panel_student_03")
			panel_3.set_text()
			panel_4.set_texture("panel_student_04")
			panel_4.set_text()
			panel_5.set_texture("panel_student_05")
			panel_5.set_text()
			panel_6.set_texture("panel_student_06")
			panel_6.set_text()
			panel_7.set_texture("panel_student_07")
			panel_7.set_text()
			panel_8.set_texture("panel_student_08")
			panel_8.set_text()
			panel_9.set_texture("panel_student_09")
			panel_9.set_text()
			panel_10.set_texture("panel_student_10")
			panel_10.set_text()
			panel_11.set_texture("panel_student_11")
			panel_11.set_text()
			panel_12.set_texture("panel_student_12")
			panel_12.set_text()
			panel_13.set_texture("panel_student_13")
			panel_13.set_text()
			panel_14.set_texture("panel_student_14")
			panel_14.set_text()
			panel_15.set_texture("panel_student_15")
			panel_15.set_text()
		_:
			print("Unknown character name. This shouldn't happen.")
	
	var tween = create_tween().set_trans(Tween.TRANS_QUINT)
	
	tween.tween_interval(1)
	tween.tween_callback(panel_1.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_1.animation_player.play.bind("fadeout"))
	tween.tween_property(skip_button, "visible", true, 0.4)
	
	tween.tween_interval(2)
	tween.tween_callback(panel_2.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_2.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_3.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_3.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_4.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_4.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_5.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_5.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_6.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_6.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_7.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_7.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_8.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_8.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_9.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_9.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_10.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_10.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_11.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_11.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_12.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_12.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_13.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_13.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_14.animation_player.play.bind("fadein"))
	
	tween.tween_interval(5)
	tween.tween_callback(panel_14.animation_player.play.bind("fadeout"))
	
	tween.tween_interval(2)
	tween.tween_callback(panel_15.animation_player.play.bind("fadein"))
	
	tween.tween_property(skip_button, "visible", false, 0.4)
	
	tween.tween_interval(2)
	tween.tween_property(begin_button, "visible", true, 0.4)


func _on_begin_button_pressed() -> void:
	get_tree().change_scene_to_packed(RUN_SCENE)
	queue_free()


func _on_skip_button_pressed() -> void:
	get_tree().change_scene_to_packed(RUN_SCENE)
	queue_free()
