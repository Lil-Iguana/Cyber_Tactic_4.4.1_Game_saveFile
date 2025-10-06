class_name DialogueUI
extends Control

signal dialogue_finished()

# Expose node paths so you can set them in the inspector if your tree differs
@export var transparent_block_path: NodePath = NodePath("TransparentBlock")
@export var black_block_path: NodePath = NodePath("BlackBlock")
@export var panel_path: NodePath = NodePath("Panel")
@export var speaker_icon_path: NodePath = NodePath("Panel/HBoxContainer/Icon")  # TextureRect for small portrait
@export var name_label_path: NodePath = NodePath("Panel/HBoxContainer/VBoxContainer/NameLabel")
@export var dialogue_label_path: NodePath = NodePath("Panel/HBoxContainer/VBoxContainer/DialogueLabel")
@export var image_panel_path: NodePath = NodePath("ImagePanel") # TextureRect for tutorial image
@export var next_button_path: NodePath = NodePath("NextButton")
@export var skip_button_path: NodePath = NodePath("SkipButton")

@export_range(0.001, 0.2, 0.001) var char_delay: float = 0.02

# Typed onready nodes
@onready var transparent_block: ColorRect = get_node(transparent_block_path) as ColorRect
@onready var black_block: ColorRect = get_node(black_block_path) as ColorRect
@onready var panel: Control = get_node(panel_path) as Control
@onready var speaker_icon: TextureRect = get_node(speaker_icon_path) as TextureRect
@onready var name_label: Label = get_node(name_label_path) as Label
@onready var dialogue_label: RichTextLabel = get_node(dialogue_label_path) as RichTextLabel
@onready var image_panel: TextureRect = get_node(image_panel_path) as TextureRect
@onready var next_button: Button = get_node(next_button_path) as Button
@onready var skip_button: Button = get_node(skip_button_path) as Button

@onready var default_portrait: Texture2D = preload("res://art/question_mark.png")
@onready var _debug_log_path: String = "user://dialogue_assets_debug.log"
@onready var default_tutorial_image: Texture2D = preload("res://art/question_mark.png")

var _lines: Array = []
var _index: int = 0
var _full_bbcode_text: String = ""
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

func show_block_immediately() -> void:
	# Show the whole UI root (so BlackBlock is visible)
	visible = true
	# Make sure TransparentBlock is visible immediately
	if transparent_block:
		transparent_block.visible = true
	
	if black_block:
		black_block.visible = false
	# Hide the actual dialogue panel and other visual elements until reveal
	if panel:
		panel.visible = false
	# Clear any existing textures/text so nothing flashes
	if image_panel:
		image_panel.visible = false
	
	if next_button:
		next_button.visible = false
	if skip_button:
		skip_button.visible = false

func show_dialogue(dialogue_data: Dictionary) -> void:
	_lines = dialogue_data.get("lines", [])
	_index = 0
	if _lines.size() == 0:
		_emit_finished()
		return
	
	if panel:
		panel.visible = true
	# Clear any existing textures/text so nothing flashes
	if black_block:
		black_block.visible = true
	if image_panel:
		image_panel.visible = true
	
	if next_button:
		next_button.visible = true
	if skip_button:
		skip_button.visible = true

	# Show entire UI (root Control). This hides/show everything at once.
	visible = true
	_show_current_line()

func _show_current_line() -> void:
	if _index < 0 or _index >= _lines.size():
		_emit_finished()
		return

	var line: Dictionary = _lines[_index] as Dictionary

	# 1) Speaker name
	if name_label:
		name_label.text = str(line.get("speaker", ""))

	# 2) Portrait (small icon) - use the helper (handles registry/fallback/logging)
	var portrait_key_or_path: String = str(line.get("portrait", ""))
	_set_portrait_from_key_or_path(portrait_key_or_path)

	if image_panel:
		image_panel.texture = null
	# 3) Tutorial image (large image panel) - use the helper
	var image_key_or_path: String = str(line.get("image", ""))
	_set_image_from_key_or_path(image_key_or_path)

	# text typewriter
	_full_bbcode_text = str(line.get("text", ""))
	_start_typing_bbcode(_full_bbcode_text)

func _start_typing_bbcode(full_bbcode_text: String) -> void:
	if not dialogue_label:
		return
	# 1) Set full text first so layout and wrapping are computed once
	dialogue_label.bbcode_enabled = true
	dialogue_label.bbcode_text = full_bbcode_text
	# 2) start invisible
	dialogue_label.visible_characters = 0
	_typing = true

	# 3) reveal by visible_characters (this will NOT change layout because engine already computed it)
	var total_chars: int = dialogue_label.get_total_character_count()
	if total_chars <= 0:
		_typing = false
		return

	for i in range(1, total_chars + 1):
		if not _typing:
			break
		dialogue_label.visible_characters = i
		await get_tree().create_timer(char_delay).timeout

	# ensure fully visible at the end
	dialogue_label.visible_characters = total_chars
	_typing = false

func _typewriter_bbcode() -> void:
	if dialogue_label == null:
		_typing = false
		return

	# number of visible (rendered) characters (BBCode tags excluded)
	var total_chars: int = dialogue_label.get_total_character_count()
	# if there are no visible characters, just finish
	if total_chars <= 0:
		_typing = false
		return

	for i in range(1, total_chars + 1):
		# If typing was cancelled externally (by input), break and show everything
		if not _typing:
			break
		dialogue_label.visible_characters = i
		# yield a short delay between characters
		await get_tree().create_timer(char_delay).timeout

	# Make sure everything is visible at the end
	dialogue_label.visible_characters = total_chars
	_typing = false

func _on_next_pressed() -> void:
	# finish typing if still typing
	if _typing:
		_typing = false
		if dialogue_label:
			dialogue_label.visible_characters = dialogue_label.get_total_character_count()
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
	_full_bbcode_text = ""
	_typing = false
	emit_signal("dialogue_finished")

func _write_debug(msg: String) -> void:
	var f: FileAccess = FileAccess.open(_debug_log_path, FileAccess.WRITE_READ)
	if f:
		f.seek_end()
		f.store_string(msg + "\n")
		f.close()

func _get_texture_from_registry_or_path(key_or_path: String) -> Texture2D:
	# Attempt 1: static class (requires `class_name PortraitRegistry` inside portrait_registry.gd)
	if ClassDB.class_exists("PortraitRegistry"):
		# Safe static call: returns Texture2D or null
		var t_static := PortraitRegistry.get_portrait(key_or_path) if typeof(PortraitRegistry.get_portrait) != TYPE_NIL else null
		if t_static and t_static is Texture2D:
			_write_debug("RESOLVE(stat): '%s' -> static registry" % key_or_path)
			return t_static

	# Attempt 2: autoload instance (if you registered the registry as an autoload singleton named 'PortraitRegistry')
	# When an autoload is present, its name is available as a global variable.
	if typeof(PortraitRegistry) != TYPE_NIL and PortraitRegistry is Object:
		# avoid static-on-instance warning by calling instance method if available
		if PortraitRegistry.has_method("get_portrait"):
			var t_inst := PortraitRegistry.get_portrait(key_or_path)
			if t_inst and t_inst is Texture2D:
				_write_debug("RESOLVE(autoload): '%s' -> autoload instance" % key_or_path)
				return t_inst

	# Attempt 3: treat argument as res:// path and try to load
	if key_or_path != "" and ResourceLoader.exists(key_or_path):
		var loaded: Resource = ResourceLoader.load(key_or_path)
		if loaded and loaded is Texture2D:
			_write_debug("RESOLVE(path): '%s' -> loaded from path" % key_or_path)
			return loaded

	# Not found
	_write_debug("MISS: '%s' -> falling back to default" % key_or_path)
	return null

# Helper that returns a Texture2D OR null.
func _resolve_tutorial_texture(key_or_path: String) -> Texture2D:
	# 1) If the key is empty, explicitly return null (clear the panel).
	if key_or_path == "" or key_or_path == null:
		_write_debug("RESOLVE: image key empty -> returning NULL")
		return null

	# 2) If a static registry class exists, try it (must expose get_tutorial_image)
	if ClassDB.class_exists("PortraitRegistry"):
		# static method:
		if PortraitRegistry.has_method("get_tutorial_image"):
			var from_static := PortraitRegistry.get_tutorial_image(key_or_path)
			if from_static and from_static is Texture2D:
				_write_debug("RESOLVE: '%s' -> static registry" % key_or_path)
				return from_static

	# 3) If an autoload instance exists with same name, try calling instance method.
	#    This covers projects where registry was autoloaded but class_name may be missing.
	if typeof(PortraitRegistry) != TYPE_NIL and PortraitRegistry is Object:
		if PortraitRegistry.has_method("get_tutorial_image"):
			var from_instance := PortraitRegistry.get_tutorial_image(key_or_path)
			if from_instance and from_instance is Texture2D:
				_write_debug("RESOLVE: '%s' -> autoload registry instance" % key_or_path)
				return from_instance

	# 4) Try to treat the value as a res:// path and load it.
	if ResourceLoader.exists(key_or_path):
		var loaded := ResourceLoader.load(key_or_path)
		if loaded and loaded is Texture2D:
			_write_debug("RESOLVE: '%s' -> loaded from res path" % key_or_path)
			return loaded
		else:
			_write_debug("FOUND path but not a Texture2D: '%s'" % key_or_path)
			return null

	# 5) Not found: log and return null (do NOT return portrait default)
	_write_debug("MISS: tutorial image '%s' not found; will clear image panel" % key_or_path)
	return null


func _set_portrait_from_key_or_path(key_or_path: String) -> void:
	var tex: Texture2D = _get_texture_from_registry_or_path(key_or_path)
	if tex == null:
		# Use default portrait if nothing resolved
		tex = default_portrait
	# assign
	if speaker_icon:
		speaker_icon.texture = tex

# Sets or clears the image_panel texture (no portrait-default fallback).
func _set_image_from_key_or_path(key_or_path: String) -> void:
	# Always clear previous texture first (prevents stale images)
	if image_panel:
		image_panel.texture = null

	var tex := _resolve_tutorial_texture(key_or_path)
	if tex:
		if image_panel:
			image_panel.texture = tex
	else:
		# If you want a visual default banner instead of empty, uncomment next line:
		# if image_panel: image_panel.texture = default_tutorial_image
		# Otherwise leave it cleared (preferred).
		pass
