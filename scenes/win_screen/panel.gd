extends Control

const PANELS := {
	"panel_placeholder" : preload("res://art/illustrations/testing_placeholder.png"),
	"panel_student_01" : preload("res://art/illustrations/student_panel0.png"),
	"panel_student_02" : preload("res://art/illustrations/student_panel0.png"),
	"panel_student_03" : preload("res://art/illustrations/student_panel0.png"),
	"panel_student_04" : preload("res://art/illustrations/student_panel0.png")
	
}

@onready var texture_rect: TextureRect = $TextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func set_texture(panel_name: String) -> void:
	texture_rect.texture = PANELS[panel_name]
