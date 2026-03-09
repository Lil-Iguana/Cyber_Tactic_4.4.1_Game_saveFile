extends Node

var _canvas_layer: CanvasLayer
var _color_rect: ColorRect
var _shader_material: ShaderMaterial
var _tween: Tween
var _pending_scene: String = ""
var _pending_packed: PackedScene = null


func _ready() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 100  # Always on top
	add_child(_canvas_layer)

	_color_rect = ColorRect.new()
	_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform float alpha : hint_range(0.0, 1.0) = 0.0;
uniform float seed : hint_range(0.0, 1000.0) = 0.0;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float noise = rand(UV + vec2(seed, seed * 0.7));
	COLOR = vec4(vec3(noise), alpha);
}
"""
	_shader_material = ShaderMaterial.new()
	_shader_material.shader = shader
	_color_rect.material = _shader_material
	_canvas_layer.add_child(_color_rect)

	_set_alpha(0.0)


func transition_to_file(scene_path: String) -> void:
	_pending_scene = scene_path
	_pending_packed = null
	_play_static_in(_do_file_change)


func transition_to_packed(scene: PackedScene) -> void:
	_pending_packed = scene
	_pending_scene = ""
	_play_static_in(_do_packed_change)


func _play_static_in(callback: Callable) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	# Flicker the noise seed while fading in for extra static feel
	_tween.tween_method(_set_alpha_and_flicker, 0.0, 1.0, 0.35)
	_tween.tween_callback(callback)


func _do_file_change() -> void:
	get_tree().change_scene_to_file(_pending_scene)
	_fade_out_after_load()


func _do_packed_change() -> void:
	get_tree().change_scene_to_packed(_pending_packed)
	_fade_out_after_load()


func _fade_out_after_load() -> void:
	# Wait two frames for the new scene to initialize
	await get_tree().process_frame
	await get_tree().process_frame
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_alpha_and_flicker, 1.0, 0.0, 0.4)


func _set_alpha(value: float) -> void:
	_shader_material.set_shader_parameter("alpha", value)


func _set_alpha_and_flicker(value: float) -> void:
	_shader_material.set_shader_parameter("alpha", value)
	# Randomize the noise seed each frame for a flickering static look
	_shader_material.set_shader_parameter("seed", randf() * 1000.0)
