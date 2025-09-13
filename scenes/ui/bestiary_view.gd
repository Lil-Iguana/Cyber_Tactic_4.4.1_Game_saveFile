class_name BestiaryView
extends Control

const ENTRY_BTN_SCENE := preload("res://scenes/ui/bestiary_entry_button.tscn")
const GRAY_MATERIAL := preload("res://art/gray_sprite_material.tres")

@onready var list_root: VBoxContainer = %EntryList
@onready var icon: TextureRect = %IconPreview
@onready var name_label: Label = %NameLabel
@onready var short_desc: RichTextLabel = %ShortDesc
@onready var full_desc: RichTextLabel = %FullDesc
@onready var back_button: Button = %BackButton


func _ready() -> void:
	back_button.pressed.connect(hide)
	_populate_list()
	CodexManager.entry_unlocked.connect(_on_entry_unlocked)
	# Initialize detail pane as locked
	_show_locked_detail()

func _populate_list() -> void:
	# Clear previous entries
	for child in list_root.get_children():
		child.queue_free()
	
	for entry in CodexManager.entries.values():
		print("  Entry -> id:'%s' unlocked:%s name:'%s'" % [entry.id, entry.is_unlocked, entry.name])
		var btn: Button = null

		# Try the custom button scene if available
		if ENTRY_BTN_SCENE is PackedScene:
			var inst = null
			# Safe instantiate
			inst = ENTRY_BTN_SCENE.instantiate()
			if inst:
				# If the instantiated node is a Button (or inherits Button), use it
				if inst is Button:
					btn = inst
				else:
					# If it's a different root type (e.g., Control), try to find the Button root
					# but fall back gracefully below
					btn = inst if inst is Button else null
			else:
				print("Bestiary: Failed to instantiate ENTRY_BTN_SCENE for entry id '%s'. Falling back to plain Button." % entry.id)
		else:
			print("Bestiary: ENTRY_BTN_SCENE is not a PackedScene. Falling back to plain Button.")

		# Fallback: plain Button (guaranteed to exist)
		if not btn:
			btn = Button.new()
			btn.rect_min_size = Vector2(240, 48)

		# If using custom scene, fill its children; otherwise, set plain button text
		if btn.has_node("HBoxContainer/EntryLabel"):
			var lbl = btn.get_node("HBoxContainer/EntryLabel") as Label
			lbl.text = entry.name if entry.is_unlocked else "???"
		else:
			btn.text = entry.name if entry.is_unlocked else "???"

		# Icon handling for custom button (only when node has Icon)
		if btn.has_node("HBoxContainer/Icon"):
			var ic = btn.get_node("HBoxContainer/Icon") as TextureRect
			ic.texture = entry.art
			ic.visible = entry.is_unlocked
			# ensure we can see something even if texture missing
			if not ic.texture:
				ic.rect_min_size = Vector2(48, 48)

		# Hook up press safely (avoid duplicate connections by using is_connected check)
		if not btn.is_connected("pressed", Callable(self, "_on_entry_selected")):
			btn.pressed.connect(Callable(self, "_on_entry_selected").bind(entry.id))

		list_root.add_child(btn)
		print("Bestiary: Added button for id '%s' (unlocked=%s)" % [entry.id, entry.is_unlocked])


func _on_entry_unlocked(_id: String) -> void:
	_populate_list()

func _on_entry_selected(id: String) -> void:
	var entry = CodexManager.entries[id]
	if entry.is_unlocked:
		# Show actual data
		icon.texture      = entry.art
		icon.visible      = true
		icon.material     = null
		name_label.text   = entry.name
		short_desc.bbcode_text = entry.tooltip_text
		full_desc.bbcode_text  = entry.tooltip_text_real
	else:
		# Locked – question marks + gray icon
		_show_locked_detail()

func _show_locked_detail() -> void:
	# Hide real icon texture and force grayscale
	icon.texture    = icon.texture   # (keep last or a placeholder)
	icon.visible    = true
	icon.material   = GRAY_MATERIAL

	# Show question marks
	name_label.text      = "???"
	short_desc.text      = "???"
	full_desc.text       = "???"
