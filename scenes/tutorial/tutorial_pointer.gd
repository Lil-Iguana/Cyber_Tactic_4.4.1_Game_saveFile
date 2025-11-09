class_name TutorialPointer
extends Node2D

enum PointerType {
	CLICK,      # Points and bounces
	DRAG,       # Shows drag motion
	SWIPE,      # Shows swipe motion
}

@onready var arrow: Polygon2D = $Arrow
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var pointer_type: PointerType = PointerType.CLICK
var target_position: Vector2 = Vector2.ZERO
var drag_end_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	hide()
	_setup_arrow()


func _setup_arrow() -> void:
	# Create arrow shape pointing down
	var arrow_points := PackedVector2Array([
		Vector2(0, -20),      # Top point
		Vector2(-10, -10),    # Left middle
		Vector2(-5, -10),     # Left inner
		Vector2(-5, 10),      # Left bottom
		Vector2(5, 10),       # Right bottom
		Vector2(5, -10),      # Right inner
		Vector2(10, -10),     # Right middle
	])
	arrow.polygon = arrow_points
	arrow.color = Color(1, 0.85, 0, 1)  # Golden color


func show_pointer(type: PointerType, start_pos: Vector2, end_pos: Vector2 = Vector2.ZERO) -> void:
	pointer_type = type
	target_position = start_pos
	drag_end_position = end_pos
	
	global_position = start_pos
	show()
	
	match type:
		PointerType.CLICK:
			_play_click_animation()
		PointerType.DRAG:
			_play_drag_animation()
		PointerType.SWIPE:
			_play_swipe_animation()


func hide_pointer() -> void:
	if animation_player.is_playing():
		animation_player.stop()
	hide()


func _play_click_animation() -> void:
	# Create bouncing animation
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Bounce down and up
	tween.tween_property(self, "position:y", target_position.y + 20, 0.5)
	tween.tween_property(self, "position:y", target_position.y, 0.5)
	
	# Pulse scale
	var scale_tween := create_tween()
	scale_tween.set_loops()
	scale_tween.set_trans(Tween.TRANS_SINE)
	scale_tween.tween_property(arrow, "scale", Vector2(1.2, 1.2), 0.5)
	scale_tween.tween_property(arrow, "scale", Vector2(1.0, 1.0), 0.5)


func _play_drag_animation() -> void:
	# Animate dragging motion from start to end
	var tween := create_tween()
	tween.set_loops()
	
	# Start position
	tween.tween_property(self, "global_position", target_position, 0.0)
	tween.tween_property(arrow, "modulate:a", 1.0, 0.0)
	
	# Wait a moment
	tween.tween_interval(0.5)
	
	# Drag to end position
	tween.tween_property(self, "global_position", drag_end_position, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Fade out at end
	tween.tween_property(arrow, "modulate:a", 0.3, 0.3)
	
	# Wait before restarting
	tween.tween_interval(0.5)
	
	# Fade back in
	tween.tween_property(arrow, "modulate:a", 1.0, 0.0)


func _play_swipe_animation() -> void:
	# Quick swipe motion
	var tween := create_tween()
	tween.set_loops()
	
	tween.tween_property(self, "global_position", target_position, 0.0)
	tween.tween_interval(0.3)
	tween.tween_property(self, "global_position", drag_end_position, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.5)
