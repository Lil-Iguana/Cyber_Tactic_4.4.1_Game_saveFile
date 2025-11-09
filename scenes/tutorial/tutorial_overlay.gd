class_name TutorialOverlay
extends CanvasLayer

@onready var highlight_border: Panel = $HighlightBorder

var highlighted_node: Control = null
var pulse_tween: Tween
var scale_tween: Tween
var input_blocker_active: bool = false
var tutorial_pointer: Node2D = null


func _ready() -> void:
	layer = 5  # Above everything else
	hide()
	
	# Setup highlight border
	highlight_border.hide()
	
	# Setup tutorial pointer
	var pointer_scene := preload("res://scenes/tutorial/tutorial_pointer.tscn")
	tutorial_pointer = pointer_scene.instantiate()
	add_child(tutorial_pointer)


func show_overlay() -> void:
	show()
	# No dim overlays - just show the canvas layer


func hide_overlay() -> void:
	if pulse_tween:
		pulse_tween.kill()
	if scale_tween:
		scale_tween.kill()
	
	# Just hide everything
	hide()
	highlight_border.hide()
	highlighted_node = null


func highlight_node(node: Control) -> void:
	if not node or not is_instance_valid(node):
		clear_highlight()
		return
	
	highlighted_node = node
	
	# Show and position highlight border
	_update_highlight_border()
	
	# Start pulsing animation
	_start_pulse_animation()


func clear_highlight() -> void:
	if pulse_tween:
		pulse_tween.kill()
	if scale_tween:
		scale_tween.kill()
	
	highlight_border.hide()
	highlighted_node = null
	
	# Hide pointer too
	if tutorial_pointer:
		tutorial_pointer.call("hide_pointer")


func _update_highlight_border() -> void:
	if not highlighted_node:
		return
	
	var node_rect := highlighted_node.get_global_rect()
	var padding := 15.0  # Increased from 8 to make it more visible
	
	highlight_border.global_position = node_rect.position - Vector2(padding, padding)
	highlight_border.size = node_rect.size + Vector2(padding * 2, padding * 2)
	highlight_border.show()


func _start_pulse_animation() -> void:
	if pulse_tween:
		pulse_tween.kill()
	if scale_tween:
		scale_tween.kill()
	
	# More exaggerated pulsing animation
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	pulse_tween.set_trans(Tween.TRANS_SINE)
	
	# Pulse opacity more dramatically (0.3 to 1.0 instead of 0.6 to 1.0)
	pulse_tween.tween_property(highlight_border, "modulate:a", 0.3, 0.6)
	pulse_tween.tween_property(highlight_border, "modulate:a", 1.0, 0.6)
	
	# Add scale pulse for extra emphasis
	scale_tween = create_tween()
	scale_tween.set_loops()
	scale_tween.set_ease(Tween.EASE_IN_OUT)
	scale_tween.set_trans(Tween.TRANS_ELASTIC)
	
	# Scale pulse
	scale_tween.tween_property(highlight_border, "scale", Vector2(1.05, 1.05), 0.6)
	scale_tween.tween_property(highlight_border, "scale", Vector2(1.0, 1.0), 0.6)


func _process(_delta: float) -> void:
	# Update highlight position if node moves
	if highlighted_node and is_instance_valid(highlighted_node):
		_update_highlight_border()


func show_drag_pointer(start_pos: Vector2, end_pos: Vector2) -> void:
	if tutorial_pointer:
		tutorial_pointer.call("show_pointer", 1, start_pos, end_pos)  # 1 = DRAG type


func hide_drag_pointer() -> void:
	if tutorial_pointer:
		tutorial_pointer.call("hide_pointer")


func block_input_except_node(_node: Control) -> void:
	# Only manage input blocking state
	input_blocker_active = true


func allow_all_input() -> void:
	# Allow all input to pass through
	input_blocker_active = false
	print("TutorialOverlay: Allowing all input - cards should be draggable")


func _input(event: InputEvent) -> void:
	# If input blocker is not active, don't block anything
	if not input_blocker_active:
		return
	
	# Block all input except clicks on highlighted node or its children
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if highlighted_node and is_instance_valid(highlighted_node):
			var mouse_pos := get_viewport().get_mouse_position()
			var node_rect := highlighted_node.get_global_rect()
			
			# Allow input if mouse is over highlighted node
			if node_rect.has_point(mouse_pos):
				return  # Don't block!
			
			# IMPORTANT: Also allow input for children of highlighted node (like cards in hand)
			if highlighted_node.get_child_count() > 0:
				for child in highlighted_node.get_children():
					if child is Control:
						var child_rect := (child as Control).get_global_rect()
						if child_rect.has_point(mouse_pos):
							return  # Don't block!
					elif child is Node2D:
						# For Node2D children (might be card nodes), check approximate bounds
						var child_node2d := child as Node2D
						var approx_rect := Rect2(child_node2d.global_position - Vector2(50, 50), Vector2(100, 100))
						if approx_rect.has_point(mouse_pos):
							return  # Don't block!
		
		# Block all other input
		get_viewport().set_input_as_handled()
