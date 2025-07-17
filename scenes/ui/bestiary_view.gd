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
	for child in list_root.get_children():
		child.queue_free()

	for entry in CodexManager.entries.values():
		var btn = ENTRY_BTN_SCENE.instantiate()
		var lbl = btn.get_node("HBoxContainer/EntryLabel") as Label
		var ic  = btn.get_node("HBoxContainer/Icon")        as TextureRect

		lbl.text    = entry.name if entry.is_unlocked else "???"
		ic.texture  = entry.art
		ic.visible  = entry.is_unlocked

		btn.pressed.connect(Callable(self, "_on_entry_selected").bind(entry.id))
		list_root.add_child(btn)

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
