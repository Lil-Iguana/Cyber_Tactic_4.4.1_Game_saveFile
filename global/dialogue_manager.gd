extends Node

signal dialogue_started(dialogue: Dictionary)
signal dialogue_finished()

var _ui_node: Control = null
var _persist_key: String = ""
var _pending_callback: Callable = Callable()

func _ready() -> void:
	# Fallback listener: when the active scene changes, the root viewport gets a new child.
	var root: Node = get_tree().root
	if root:
		root.child_entered_tree.connect(_on_child_entered_tree)

# Manual registration (DialogueUI can call this in its _ready)
func register_ui(ui: Control) -> void:
	_ui_node = ui

func _on_child_entered_tree(node: Node) -> void:
	# Only react when the node is the new current scene
	if node == get_tree().current_scene:
		_try_resolve_ui_by_search()

func _try_resolve_ui_by_search() -> void:
	var cs: Node = get_tree().current_scene
	if not cs:
		return
	var ui: Node = cs.find_child("DialogueUI", true, false)
	if ui and ui is Control:
		_ui_node = ui as Control

# Public API: start from a JSON file
func start_dialogue_from_file(file_path: String, state_key: String = "", callback: Callable = Callable()) -> void:
	if _ui_node == null:
		_try_resolve_ui_by_search()
	if _ui_node == null:
		push_error("DialogueManager: No DialogueUI found in the current scene!")
		return

	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("DialogueManager: Failed to open dialogue file: %s" % file_path)
		return

	var txt: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("DialogueManager: Invalid dialogue JSON format in %s" % file_path)
		return

	var dialogue_data: Dictionary = parsed as Dictionary
	
	await get_tree().create_timer(1.0).timeout
	
	start_dialogue(dialogue_data, state_key, callback)

# Public API: start from a Dictionary
func start_dialogue(dialogue_data: Dictionary, state_key: String = "", callback: Callable = Callable()) -> void:
	if _ui_node == null:
		_try_resolve_ui_by_search()
	if _ui_node == null:
		push_error("DialogueManager: No DialogueUI found to show dialogue.")
		return

	_persist_key = state_key
	_pending_callback = callback

	emit_signal("dialogue_started", dialogue_data)

	# Ensure we only respond once per dialogue
	if not _ui_node.is_connected("dialogue_finished", Callable(self, "_on_ui_finished")):
		_ui_node.connect("dialogue_finished", Callable(self, "_on_ui_finished"), CONNECT_ONE_SHOT)

	# Defer to next frame so the UI has time to enter the tree/become ready
	_ui_node.call_deferred("show_dialogue", dialogue_data)

func _on_ui_finished() -> void:
	if _persist_key != "":
		if DialogueState and not DialogueState.has_shown(_persist_key):
			DialogueState.mark_shown(_persist_key)
	_persist_key = ""

	if _pending_callback.is_valid():
		_pending_callback.call()
	_pending_callback = Callable()

	emit_signal("dialogue_finished")
