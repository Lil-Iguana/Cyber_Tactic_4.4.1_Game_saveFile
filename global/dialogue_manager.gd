extends Node

signal dialogue_started(dialogue: Dictionary)
signal dialogue_finished()

var _ui_node: Control = null
var _persist_key: String = ""
var _pending_callback: Callable = Callable()
var _post_scene: String = ""      # optional scene file path to change to after dialogue
var _post_delay_seconds: float = 0.0  # optional small delay before scene change (seconds)
# Add an exported whitelist array near the top of the file (so you can edit it in the Inspector)
@export var root_protected_nodes: Array = ["DialogueManager", "PortraitRegistry", "Events", "Shaker", "MusicPlayer", "SFXPlayer", "RNG", "GlobalTurnNumber", "CardLibrary", "CodexManager", "DialogueState", "ModelRegistry"]

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

# Try to find DialogueUI inside the current scene subtree
func _try_resolve_ui_by_search() -> void:
	var cs: Node = get_tree().current_scene
	if not cs:
		return
	var found: Control = _find_dialogue_ui_in(cs)
	if found:
		_ui_node = found

# Recursive search helper - returns first Control named "DialogueUI" under given node, or null
func _find_dialogue_ui_in(node: Node) -> Control:
	for child in node.get_children():
		if child and child is Control and child.name == "DialogueUI":
			return child as Control
		var nested := _find_dialogue_ui_in(child)
		if nested:
			return nested
	return null

# Populate an array with all nodes named DialogueUI under a node (recursive)
func _collect_dialogue_ui_nodes(node: Node, out_nodes: Array) -> void:
	for child in node.get_children():
		if child and child is Control and child.name == "DialogueUI":
			out_nodes.append(child)
		_collect_dialogue_ui_nodes(child, out_nodes)

# Start dialogue from file (parses JSON and reads optional post_scene keys)
func start_dialogue_from_file(file_path: String, state_key: String = "", callback: Callable = Callable(), delay_seconds: float = 1.0) -> void:
	# Ensure UI present (attempt auto-resolve if not)
	if _ui_node == null:
		_try_resolve_ui_by_search()
	if _ui_node == null:
		push_error("DialogueManager: No DialogueUI found in the current scene!")
		return

	# Validate file exists
	if not FileAccess.file_exists(file_path):
		push_error("DialogueManager: dialogue file missing: %s" % file_path)
		return

	# Read file
	var txt: String = FileAccess.get_file_as_string(file_path)

	# Parse JSON
	var parsed: Variant = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("DialogueManager: JSON parse error or wrong format in %s" % file_path)
		return
	var dialogue_data: Dictionary = parsed as Dictionary

	# Look for optional post_scene and post_scene_delay inside the JSON
	var post_scene_path: String = ""
	var post_scene_delay: float = 0.0
	if dialogue_data.has("post_scene"):
		post_scene_path = str(dialogue_data.get("post_scene", ""))
	if dialogue_data.has("post_scene_delay"):
		post_scene_delay = float(dialogue_data.get("post_scene_delay", 0.0))

	# Forward to main start method
	start_dialogue(dialogue_data, state_key, callback, delay_seconds, post_scene_path, post_scene_delay)

# Start dialogue from a Dictionary (supports optional delay + post-scene)
func start_dialogue(dialogue_data: Dictionary, state_key: String = "", callback: Callable = Callable(), delay_seconds: float = 1.0, post_scene: String = "", post_scene_delay: float = 0.0) -> void:
	# Ensure UI present
	if _ui_node == null:
		_try_resolve_ui_by_search()
	if _ui_node == null:
		push_error("DialogueManager: No DialogueUI found to show dialogue.")
		return

	_persist_key = state_key
	_pending_callback = callback
	_post_scene = post_scene
	_post_delay_seconds = post_scene_delay

	emit_signal("dialogue_started", dialogue_data)

	# Connect to UI finished (one-shot)
	if not _ui_node.is_connected("dialogue_finished", Callable(self, "_on_ui_finished")):
		_ui_node.connect("dialogue_finished", Callable(self, "_on_ui_finished"), CONNECT_ONE_SHOT)

	# Show black block immediately (if the UI supports it)
	if _ui_node.has_method("show_block_immediately"):
		_ui_node.call_deferred("show_block_immediately")

	# Optional delay before revealing dialogue (non-blocking)
	if delay_seconds > 0.0:
		await get_tree().create_timer(delay_seconds).timeout

	# Finally show the dialogue (deferred to be safe)
	_ui_node.call_deferred("show_dialogue", dialogue_data)

# Handler when DialogueUI signals it finished
func _on_ui_finished() -> void:
	# Mark persistent key
	if _persist_key != "":
		if DialogueState and not DialogueState.has_shown(_persist_key):
			DialogueState.mark_shown(_persist_key)
	_persist_key = ""

	# Call any pending callback (user-provided custom action)
	if _pending_callback.is_valid():
		_pending_callback.call()
	_pending_callback = Callable()

	# If a post_scene was specified, wait optional delay then change scene
	if _post_scene != "":
		if _post_delay_seconds > 0.0:
			await get_tree().create_timer(_post_delay_seconds).timeout

		if FileAccess.file_exists(_post_scene):
			# Defer scene changing to avoid doing it inside this signal handler
			call_deferred("_change_scene_deferred", _post_scene)
		else:
			push_error("DialogueManager: Requested post_scene not found: %s" % _post_scene)

	_post_scene = ""
	_post_delay_seconds = 0.0

	emit_signal("dialogue_finished")

# Diagnostic helper: prints where DialogueUI is parented (useful for debugging leftovers)
func _diag_print_dialogueui_location() -> void:
	var found_ui: Control = _find_dialogue_ui_in(get_tree().root)
	if found_ui:
		var parent_node: Node = found_ui.get_parent()
		@warning_ignore("incompatible_ternary")
		var parent_path: String = parent_node.get_path() if parent_node else "null"
		print("DialogueUI found at: ", found_ui.get_path(), " parent: ", parent_path)
	else:
		print("DialogueUI not found in the root tree.")

# Robust scene changer (force cleanup of leftover root children not on whitelist)
func _change_scene_deferred(scene_path: String) -> void:
	# Load PackedScene
	var packed: PackedScene = ResourceLoader.load(scene_path) as PackedScene
	if packed == null:
		push_error("DialogueManager: _change_scene_deferred - scene not found or not a PackedScene: %s" % scene_path)
		return

	# Remember old current scene
	var old_scene: Node = get_tree().current_scene

	# Instantiate new scene
	var new_scene: Node = packed.instantiate()
	if new_scene == null:
		push_error("DialogueManager: Failed to instantiate scene: %s" % scene_path)
		return

	# Add new scene to root and set as current
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

	# Wait one frame for visuals/input to stabilize
	await get_tree().process_frame

	# --- 1) Remove leftover DialogueUI nodes that are NOT descendants of new_scene (as before) ---
	var found_ui_nodes: Array = []
	_collect_dialogue_ui_nodes(get_tree().root, found_ui_nodes)

	for ui in found_ui_nodes:
		if ui and ui.is_inside_tree():
			# check if ui is a descendant of new_scene
			var ancestor: Node = ui
			var is_descendant: bool = false
			while ancestor:
				if ancestor == new_scene:
					is_descendant = true
					break
				ancestor = ancestor.get_parent()
			if not is_descendant:
				print("DialogueManager: Removing leftover DialogueUI at ", ui.get_path())
				ui.queue_free()

	# --- 2) Free the old scene subtree if it still exists and is different from new_scene ---
	if old_scene and old_scene != new_scene and old_scene.is_inside_tree():
		print("DialogueManager: queue_free old scene: ", old_scene.get_path())
		old_scene.queue_free()

	# Wait a frame to let old_scene and UI nodes be removed
	await get_tree().process_frame

	# --- 3) FORCE cleanup of root children (only remove those NOT on whitelist and NOT new_scene) ---
	# This is aggressive: it removes leftover root children that would otherwise remain visible.
	# Be sure to add autoload names (singletons) to `root_protected_nodes` to avoid removing them.
	var root_children := get_tree().root.get_children()
	for child in root_children:
		# skip the newly created scene
		if child == new_scene:
			continue
		# skip protected nodes by name
		if child and child.name in root_protected_nodes:
			continue
		# skip nodes that are likely singletons by checking their script path? (optional)
		# If you need to preserve more nodes, add their names to the root_protected_nodes array.
		# Remove anything else that is still a direct child of root (these are likely leftovers)
		print("DialogueManager: FORCE removing root child: ", child.get_path())
		child.queue_free()

	# final small delay to let frees apply
	await get_tree().process_frame
