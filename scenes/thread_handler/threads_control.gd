class_name ThreadsControl
extends Control

const THREADS_PER_PAGE := 5
const TWEEN_SCROLL_DURATION := 0.2

@export var left_button: = TextureButton
@export var right_button: = TextureButton

@onready var threads: HBoxContainer = %ThreadsHold
@onready var page_width = self.custom_minimum_size.x

var num_of_threads := 0
var current_page := 1
var max_page := 0
var tween: Tween


func _ready() -> void:
	left_button.pressed.connect(_on_left_button_pressed)
	right_button.pressed.connect(_on_right_button_pressed)
	
	for thread_ui: ThreadUI in threads.get_children():
		thread_ui.free()
	
	threads.child_order_changed.connect(_on_threads_child_order_changed)


func update() -> void:
	if not is_instance_valid(left_button) or not is_instance_valid(right_button):
		return
		
	num_of_threads = threads.get_child_count()
	max_page = ceili(num_of_threads / float(THREADS_PER_PAGE))
	
	left_button.disabled = current_page <= 1
	right_button.disabled = current_page >= max_page


func _tween_to(x_position: float) -> void:
	if tween:
		tween.kill()
		
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(threads, "position:x", x_position, TWEEN_SCROLL_DURATION)


func _on_left_button_pressed() -> void:
	if current_page > 1:
		current_page -= 1
		update()
		_tween_to(threads.position.x + page_width)


func _on_right_button_pressed() -> void:
	if current_page < max_page:
		current_page += 1
		update()
		_tween_to(threads.position.x - page_width)


func _on_threads_child_order_changed() -> void:
	update()
