extends Control

const PANELS := {
	"panel_placeholder" : preload("res://art/illustrations/testing_placeholder.png"),
	"panel_student_01" : preload("res://art/illustrations/student_panel0.png"),
	"panel_student_02" : preload("res://art/illustrations/student_panel1.png"),
	"panel_student_03" : preload("res://art/illustrations/student_panel2.png"),
	"panel_student_04" : preload("res://art/illustrations/student_panel3.png"),
	"panel_student_05" : preload("res://art/illustrations/student_panel4.png"),
	"panel_student_06" : preload("res://art/illustrations/student_panel5.png"),
	"panel_student_07" : preload("res://art/illustrations/student_panel6.png"),
	"panel_student_08" : preload("res://art/illustrations/student_panel7.png"),
	"panel_student_09" : preload("res://art/illustrations/student_panel8.png"),
	"panel_student_10" : preload("res://art/illustrations/student_panel9.png"),
	"panel_student_11" : preload("res://art/illustrations/student_panel10.png"),
	"panel_student_12" : preload("res://art/illustrations/student_panel11.png"),
	"panel_student_13" : preload("res://art/illustrations/student_panel12.png"),
	"panel_student_14" : preload("res://art/illustrations/student_panel13.png"),
	"panel_student_15" : preload("res://art/illustrations/student_panel14.png")
	
}

@onready var texture_rect: TextureRect = $TextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dialog_text: RichTextLabel = $Panel/DialogText
@export_multiline var dialog: String


func set_texture(panel_name: String) -> void:
	texture_rect.texture = PANELS[panel_name]

func set_text() -> void:
	dialog_text.text = dialog
