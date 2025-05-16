class_name ThreadHandler
extends HBoxContainer

signal threads_activated(type: ThreadPassive.Type)

const THREAD_APPLY_INTERVAL := 0.5
const THREAD_UI = preload("res://scenes/thread_handler/thread_ui.tscn")

@onready var threads_control: ThreadsControl = $ThreadsControl
@onready var threads_hold: HBoxContainer = %ThreadsHold


func _ready() -> void:
	threads_hold.child_exiting_tree.connect(_on_threads_child_exiting_tree)


func activate_threads_by_type(type: ThreadPassive.Type) -> void:
	if type == ThreadPassive.Type.EVENT_BASED:
		return
		
	var thread_queue: Array[ThreadUI] = _get_all_thread_ui_nodes().filter(
		func(thread_ui: ThreadUI):
			return thread_ui.thread_passive.type == type
	)
	if thread_queue.is_empty():
		threads_activated.emit(type)
		return
	
	var tween := create_tween()
	for thread_ui: ThreadUI in thread_queue:
		tween.tween_callback(thread_ui.thread_passive.activate_thread.bind(thread_ui))
		tween.tween_interval(THREAD_APPLY_INTERVAL)
	
	tween.finished.connect(func(): threads_activated.emit(type))


func add_threads(threads_array: Array[ThreadPassive]) -> void:
	for thread: ThreadPassive in threads_array:
		add_thread(thread)


func add_thread(thread: ThreadPassive) -> void:
	if has_thread(thread.id):
		return
	
	var new_thread_ui := THREAD_UI.instantiate() as ThreadUI
	threads_hold.add_child(new_thread_ui)
	new_thread_ui.thread_passive = thread
	new_thread_ui.thread_passive.initialize_thread(new_thread_ui)


func has_thread(id: String) -> bool:
	for thread_ui: ThreadUI in threads_hold.get_children():
		if is_instance_valid(thread_ui) and thread_ui.thread_passive.id == id:
			return true
	
	return false


func get_all_threads() -> Array[ThreadPassive]:
	var thread_ui_nodes := _get_all_thread_ui_nodes()
	var threads_array: Array[ThreadPassive] = []
	
	for thread_ui: ThreadUI in thread_ui_nodes:
		threads_array.append(thread_ui.thread_passive)
	
	return threads_array


func _get_all_thread_ui_nodes() -> Array[ThreadUI]:
	var all_threads: Array[ThreadUI] = []
	for thread_ui: ThreadUI in threads_hold.get_children():
		all_threads.append(thread_ui)
		
	return all_threads


func _on_threads_child_exiting_tree(thread_ui: ThreadUI) -> void:
	if not thread_ui:
		return
	
	if thread_ui.thread_passive:
		thread_ui.thread_passive.deactivate_thread(thread_ui)
