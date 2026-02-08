class_name IntentTooltip
extends Control

@export var fade_seconds := 0.15
@export var offset_from_mouse := Vector2(-10, 0)  # Offset to the left of mouse

@onready var description_label: Label = %DescriptionLabel

var tween: Tween
var is_visible_now := false


func _ready() -> void:
	Events.intent_tooltip_requested.connect(show_tooltip)
	Events.intent_tooltip_hide_requested.connect(hide_tooltip)
	Events.intent_tooltip_position_updated.connect(update_position)
	modulate = Color.TRANSPARENT
	hide()


func show_tooltip(description: String, mouse_pos: Vector2) -> void:
	is_visible_now = true
	if tween:
		tween.kill()
	
	description_label.text = description
	
	# Position to the left of the mouse
	global_position = mouse_pos + offset_from_mouse
	# Adjust if tooltip would go off-screen to the left
	if global_position.x < 0:
		global_position.x = mouse_pos.x + 10  # Show on right side instead
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(show)
	tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)


func update_position(mouse_pos: Vector2) -> void:
	if is_visible_now:
		# Position to the left of the mouse
		global_position = mouse_pos + offset_from_mouse
		# Adjust if tooltip would go off-screen to the left
		if global_position.x < 0:
			global_position.x = mouse_pos.x + 10  # Show on right side instead


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
