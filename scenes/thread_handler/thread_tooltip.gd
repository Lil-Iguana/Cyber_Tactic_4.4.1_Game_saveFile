class_name ThreadTooltip
extends Control

@onready var thread_icon: TextureRect = %ThreadIcon
@onready var thread_tooltip: RichTextLabel = %ThreadDescription
@onready var back_button: Button = %BackButton


func _ready() -> void:
	back_button.pressed.connect(hide)
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		hide()


func show_tooltip(thread: ThreadPassive) -> void:
	thread_icon.texture = thread.icon
	thread_tooltip.text = thread.get_tooltip()
	show()


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		hide()
