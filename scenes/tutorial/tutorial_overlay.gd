class_name TutorialOverlay
extends CanvasLayer

@onready var dim_overlay: ColorRect = $DimOverlay
@onready var spotlight: ColorRect = $Spotlight
@onready var highlight_border: NinePatchRect = $HighlightBorder

var highlighted_node: Control = null
var spotlight_material: ShaderMaterial
var pulse_tween: Tween
var input_blocker_active: bool = false


func _ready() -> void:
	layer = 5  # Above everything else
	hide()
	
	# Setup spotlight shader
	_setup_spotlight_shader()
	
	# Setup highlight border
	highlight_border.hide()


func _setup_spotlight_shader() -> void:
	# Create a shader material for the spotlight effect
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform vec2 spotlight_position = vec2(0.5, 0.5);
uniform float spotlight_radius = 0.2;
uniform float spotlight_softness = 0.1;

void fragment() {
	vec2 uv = SCREEN_UV;
	float dist = distance(uv, spotlight_position);
	float alpha = smoothstep(spotlight_radius - spotlight_softness, spotlight_radius + spotlight_softness, dist);
	COLOR = vec4(0.0, 0.0, 0.0, alpha * 0.7);
}
"""
	
	spotlight_material = ShaderMaterial.new()
	spotlight_material.shader = shader
	spotlight.material = spotlight_material


func show_overlay() -> void:
	show()
	
	# Fade in dim overlay
	dim_overlay.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(dim_overlay, "modulate:a", 1.0, 0.3)


func hide_overlay() -> void:
	if pulse_tween:
		pulse_tween.kill()
	
	# Fade out
	var tween := create_tween()
	tween.tween_property(dim_overlay, "modulate:a", 0.0, 0.2)
	tween.finished.connect(hide)
	
	highlight_border.hide()
	highlighted_node = null


func highlight_node(node: Control) -> void:
	if not node or not is_instance_valid(node):
		clear_highlight()
		return
	
	highlighted_node = node
	
	# Update spotlight position based on node
	_update_spotlight_position()
	
	# Show and position highlight border
	_update_highlight_border()
	
	# Start pulsing animation
	_start_pulse_animation()


func clear_highlight() -> void:
	if pulse_tween:
		pulse_tween.kill()
	
	highlight_border.hide()
	highlighted_node = null
	
	# Reset spotlight to center
	if spotlight_material:
		spotlight_material.set_shader_parameter("spotlight_radius", 1.0)


func _update_spotlight_position() -> void:
	if not highlighted_node or not spotlight_material:
		return
	
	# Get node's global rect
	var node_rect := highlighted_node.get_global_rect()
	var screen_size := get_viewport().get_visible_rect().size
	
	# Calculate center position in screen UV coordinates (0-1)
	var center := node_rect.get_center()
	var uv_pos := Vector2(center.x / screen_size.x, center.y / screen_size.y)
	
	# Calculate radius to cover the node
	var node_size := node_rect.size
	var max_dimension: float = max(node_size.x, node_size.y)
	var radius: float = (max_dimension / max(screen_size.x, screen_size.y)) * 1.5
	
	spotlight_material.set_shader_parameter("spotlight_position", uv_pos)
	spotlight_material.set_shader_parameter("spotlight_radius", radius)
	spotlight_material.set_shader_parameter("spotlight_softness", radius * 0.3)


func _update_highlight_border() -> void:
	if not highlighted_node:
		return
	
	var node_rect := highlighted_node.get_global_rect()
	var padding := 8.0
	
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
	
	pulse_tween.tween_property(highlight_border, "modulate:a", 0.6, 0.8)
	pulse_tween.tween_property(highlight_border, "modulate:a", 1.0, 0.8)


func _process(_delta: float) -> void:
	# Update spotlight and highlight if node moves
	if highlighted_node and is_instance_valid(highlighted_node):
		_update_spotlight_position()
		_update_highlight_border()


func block_input_except_node(node: Control) -> void:
	# Make dim overlay consume input except at highlighted node position
	dim_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	spotlight.mouse_filter = Control.MOUSE_FILTER_STOP
	input_blocker_active = true


func allow_all_input() -> void:
	dim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spotlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	input_blocker_active = false


func _input(event: InputEvent) -> void:
	if not input_blocker_active:
		return
	
	# Block all input except clicks on highlighted node
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if highlighted_node and is_instance_valid(highlighted_node):
			var mouse_pos := get_viewport().get_mouse_position()
			var node_rect := highlighted_node.get_global_rect()
			
			# Allow input if mouse is over highlighted node
			if node_rect.has_point(mouse_pos):
				return
		
		# Block all other input
		get_viewport().set_input_as_handled()
