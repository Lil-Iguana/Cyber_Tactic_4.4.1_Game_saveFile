class_name EnemyTooltip
extends Control

@export var fade_seconds := 0.2

@onready var close_button: TextureButton = %CloseButton
@onready var tooltip_icon: TextureRect = %EnemyIcon
@onready var enemy_name: Label = %EnemyName
@onready var intent_grid: GridContainer  = %IntentGrid

var tween: Tween
var is_visible_now := false


func _ready() -> void:
	Events.enemy_tooltip_requested.connect(show_tooltip)
	Events.tooltip_hide_requested.connect(hide_tooltip)
	close_button.pressed.connect(hide)
	modulate = Color.TRANSPARENT


func show_tooltip(icon: Texture, name_text: String, icons: Array, descs: Array) -> void:
	is_visible_now = true
	if tween:
		tween.kill()
	
	for child in intent_grid.get_children():
		intent_grid.remove_child(child)
		child.queue_free()
	
	tooltip_icon.texture = icon
	enemy_name.text = name_text
	
	intent_grid.columns = 2
	var count = min(icons.size(), descs.size())
	for i in count:
		var iconS = TextureRect.new()
		iconS.texture = icons[i]
		iconS.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		intent_grid.add_child(iconS)

		var lbl = Label.new()
		lbl.text = descs[i]
		lbl.vertical_alignment = 1
		lbl.horizontal_alignment = 1
		intent_grid.add_child(lbl)
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(show)
	tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)


func hide_tooltip() -> void:
	is_visible_now = false
	if tween:
		tween.kill()
	
	get_tree().create_timer(fade_seconds, false).timeout.connect(hide_animation)


func hide_animation() -> void:
	if not is_visible_now:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_seconds)
		tween.tween_callback(hide)
