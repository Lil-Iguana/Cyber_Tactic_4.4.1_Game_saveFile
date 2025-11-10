class_name TutorialOverlay
extends CanvasLayer

@onready var highlight_border: ReferenceRect = $HighlightBorder

var highlighted_node: Control = null
var pulse_tween: Tween
var tutorial_pointer: Node2D = null


func _ready() -> void:
	layer = 100
	hide()
	
	# Setup highlight border - make sure it NEVER blocks input
	highlight_border.hide()
	highlight_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Setup tutorial pointer
	var pointer_scene := preload("res://scenes/tutorial/tutorial_pointer.tscn")
	tutorial_pointer = pointer_scene.instantiate()
	add_child(tutorial_pointer)


func show_overlay() -> void:
	show()


func hide_overlay() -> void:
	if pulse_tween:
		pulse_tween.kill()
	
	hide()
	highlight_border.hide()
	highlighted_node = null


func highlight_node(node: Control) -> void:
	if not node or not is_instance_valid(node):
		clear_highlight()
		return
	
	highlighted_node = node
	_update_highlight_border()
	_start_pulse_animation()


func clear_highlight() -> void:
	if pulse_tween:
		pulse_tween.kill()
	
	highlight_border.hide()
	highlighted_node = null
	
	if tutorial_pointer:
		tutorial_pointer.call("hide_pointer")


func _update_highlight_border() -> void:
	if not highlighted_node:
		return
	
	var node_rect := highlighted_node.get_global_rect()
	var padding := 10.0
	
	highlight_border.global_position = node_rect.position - Vector2(padding, padding)
	highlight_border.size = node_rect.size + Vector2(padding * 2, padding * 2)
	highlight_border.show()


func _start_pulse_animation() -> void:
	if pulse_tween:
		pulse_tween.kill()
	
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	pulse_tween.set_trans(Tween.TRANS_SINE)
	
	pulse_tween.tween_property(highlight_border, "modulate:a", 0.3, 0.6)
	pulse_tween.tween_property(highlight_border, "modulate:a", 1.0, 0.6)


func _process(_delta: float) -> void:
	if highlighted_node and is_instance_valid(highlighted_node):
		_update_highlight_border()


func show_drag_pointer(start_pos: Vector2, end_pos: Vector2) -> void:
	if tutorial_pointer:
		tutorial_pointer.call("show_pointer", 1, start_pos, end_pos)


func hide_drag_pointer() -> void:
	if tutorial_pointer:
		tutorial_pointer.call("hide_pointer")


# These functions are called by TutorialManager but don't actually block input here
# Input blocking is handled by TutorialManager disabling UI elements
func block_input_except_node(_node: Control) -> void:
	pass  # No input blocking at overlay level


func allow_all_input() -> void:
	pass  # No input blocking at overlay level
