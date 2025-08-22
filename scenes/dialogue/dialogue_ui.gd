class_name DialogueUI
extends Control

signal dialogue_finished()

# Expose node paths so you can set them in the inspector if your tree differs
@export var panel_path: NodePath = NodePath("Panel")
@export var speaker_icon_path: NodePath = NodePath("Panel/HBoxContainer/Icon")  # TextureRect for small portrait
@export var name_label_path: NodePath = NodePath("Panel/HBoxContainer/VBoxContainer/NameLabel")
@export var dialogue_label_path: NodePath = NodePath("Panel/HBoxContainer/VBoxContainer/DialogueLabel")
@export var image_panel_path: NodePath = NodePath("ImagePanel") # TextureRect for tutorial image
@export var next_button_path: NodePath = NodePath("NextButton")
@export var skip_button_path: NodePath = NodePath("SkipButton")

@export_range(0.001, 0.2, 0.001) var char_delay: float = 0.02

# Typed onready nodes
@onready var panel: Control = get_node(panel_path) as Control
@onready var speaker_icon: TextureRect = get_node(speaker_icon_path) as TextureRect
@onready var name_label: Label = get_node(name_label_path) as Label
@onready var dialogue_label: RichTextLabel = get_node(dialogue_label_path) as RichTextLabel
@onready var image_panel: TextureRect = get_node(image_panel_path) as TextureRect
@onready var next_button: Button = get_node(next_button_path) as Button
@onready var skip_button: Button = get_node(skip_button_path) as Button

var _lines: Array = []
var _index: int = 0
var _full_text: String = ""
var _typing: bool = false

func _ready() -> void:
	# Hide/show the entire DialogueUI root instead of individual children.
	# Set this Control invisible initially.
	visible = false

	# register UI so DialogueManager can find it
	if DialogueManager:
		DialogueManager.register_ui(self)

	# connect buttons (if found)
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)

func show_dialogue(dialogue_data: Dictionary) -> void:
	_lines = dialogue_data.get("lines", [])
	_index = 0
	if _lines.size() == 0:
		_emit_finished()
		return

	# Show entire UI (root Control). This hides/show everything at once.
	visible = true
	_show_current_line()

func _show_current_line() -> void:
	if _index < 0 or _index >= _lines.size():
		_emit_finished()
		return

	var line: Dictionary = _lines[_index] as Dictionary

	# name
	if name_label:
		name_label.text = str(line.get("speaker", ""))

	# small portrait / speaker icon (optional)
	var portrait_path: String = str(line.get("portrait", ""))
	if speaker_icon:
		if portrait_path != "" and FileAccess.file_exists(portrait_path):
			var tex := load(portrait_path)
			if tex and tex is Texture2D:
				speaker_icon.texture = tex
			else:
				# clear texture if it's not valid
				speaker_icon.texture = null
		else:
			# clear texture if missing (do not toggle visibility of nodes)
			speaker_icon.texture = null

	# large tutorial image (optional). Use key "image"
	var image_path: String = str(line.get("image", ""))
	if image_panel:
		if image_path != "" and FileAccess.file_exists(image_path):
			var itex := load(image_path)
			if itex and itex is Texture2D:
				image_panel.texture = itex
			else:
				image_panel.texture = null
		else:
			image_panel.texture = null

	# text typewriter
	_full_text = str(line.get("text", ""))
	_start_typing(_full_text)

func _start_typing(text: String) -> void:
	_typing = true
	if dialogue_label:
		dialogue_label.text = ""
	# run non-blocking coroutine
	_typewriter(text)

func _typewriter(text: String) -> void:
	var length := text.length()
	for i in range(1, length + 1):
		# if typing was canceled by input, break and show full
		if not _typing:
			break
		if dialogue_label:
			dialogue_label.text = text.substr(0, i)
		await get_tree().create_timer(char_delay).timeout
	# ensure full text shown
	if dialogue_label:
		dialogue_label.text = text
	_typing = false

func _on_next_pressed() -> void:
	# finish typing if still typing
	if _typing:
		_typing = false
		if dialogue_label:
			dialogue_label.text = _full_text
		return

	# advance
	_index += 1
	if _index >= _lines.size():
		_emit_finished()
	else:
		_show_current_line()

func _on_skip_pressed() -> void:
	_emit_finished()

func _emit_finished() -> void:
	# Hide entire UI root (children will be hidden automatically)
	visible = false

	# clear textures rather than toggling child visibility so next show is clean
	if speaker_icon:
		speaker_icon.texture = null
	if image_panel:
		image_panel.texture = null

	_lines = []
	_index = 0
	_full_text = ""
	_typing = false
	emit_signal("dialogue_finished")
