extends Node

signal dialogue_started(dialogue: Dictionary)
signal dialogue_finished()

var _ui_node: Control = null
var _persist_key: String = ""
var _pending_callback: Callable = Callable()
var _post_scene: String = ""      # optional scene file path to change to after dialogue
var _post_delay_seconds: float = 0.0  # optional small delay before scene change (seconds)
# Add an exported whitelist array near the top of the file (so you can edit it in the Inspector)
@export var root_protected_nodes: Array = ["DialogueManager", "PortraitRegistry", "Events", "Shaker", "MusicPlayer", "SFXPlayer", "RNG", "GlobalTurnNumber", "CardLibrary", "CodexManager", "DialogueState", "ModelRegistry", "SettingsManager"]

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

func _find_node_in_tree_by_name(start_node: Node, target_name: String) -> Node:
	if start_node == null:
		return null
	# check the node itself first
	if start_node.name == target_name:
		return start_node
	# then recurse children
	for child in start_node.get_children():
		# cast to Node to satisfy typed analyzer
		var cnode: Node = child as Node
		if cnode == null:
			continue
		var found: Node = _find_node_in_tree_by_name(cnode, target_name)
		if found:
			return found
	return null

# Called when UI finished emitting its signal
func _on_ui_finished() -> void:
	# Try to resolve the UI reference if we don't have one
	if _ui_node == null:
		_try_resolve_ui_by_search()

	# Force unblock DialogueUI (deferred in case it's being freed)
	if _ui_node and _ui_node.has_method("force_hide_block"):
		_ui_node.call_deferred("force_hide_block")

	_write_debug("DialogueManager: _on_ui_finished called; persist_key=%s" % _persist_key)

	# persist the dialog state if requested
	if _persist_key != "":
		if typeof(DialogueState) != TYPE_NIL and DialogueState and DialogueState.has_method("mark_shown"):
			DialogueState.mark_shown(_persist_key)
	_persist_key = ""

	# call callback if provided
	if _pending_callback.is_valid():
		_pending_callback.call()
	_pending_callback = Callable()

	if _post_scene != "":
		_write_debug("DialogueManager: post_scene requested: %s (delay=%f)" % [_post_scene, _post_delay_seconds])
		# ensure not paused before waiting for post delay
		get_tree().paused = false
		if _post_delay_seconds > 0.0:
			await get_tree().create_timer(_post_delay_seconds).timeout

		# ensure unblocked before scene change: search root for DialogueUI safely
		var root_node: Node = get_tree().get_root()
		var root_ui_node: Node = _find_node_in_tree_by_name(root_node, "DialogueUI")
		var root_ui: Control = root_ui_node as Control
		if root_ui and root_ui.has_method("force_hide_block"):
			root_ui.call_deferred("force_hide_block")

		call_deferred("_perform_scene_change", _post_scene)
	else:
		_write_debug("DialogueManager: no post_scene to change to")

	_post_scene = ""
	_post_delay_seconds = 0.0

	emit_signal("dialogue_finished")


# Robust scene changer: tries change_scene_to_file, falls back to PackedScene instantiate, and cleans leftovers.
func _perform_scene_change(scene_path: String) -> void:
	_write_debug("DialogueManager: _perform_scene_change -> %s" % scene_path)

	# unpause to be safe
	get_tree().paused = false

	# try engine API first
	var err: int = get_tree().change_scene_to_file(scene_path)
	if err == OK:
		_write_debug("DialogueManager: change_scene_to_file succeeded for %s" % scene_path)
		return
	else:
		_write_debug("DialogueManager: change_scene_to_file returned %s; falling back" % str(err))

	# fallback: manual load/instantiate
	if not ResourceLoader.exists(scene_path):
		_write_debug("DialogueManager: ResourceLoader.exists false for %s" % scene_path)
		return

	var packed: Resource = ResourceLoader.load(scene_path)
	if packed == null or not (packed is PackedScene):
		_write_debug("DialogueManager: ResourceLoader.load failed or returned not PackedScene for %s" % scene_path)
		return

	var old_scene: Node = get_tree().current_scene
	var new_scene: Node = (packed as PackedScene).instantiate()
	if new_scene == null:
		_write_debug("DialogueManager: instantiate returned null for %s" % scene_path)
		return

	# Add and set current
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

	# let a frame pass to settle
	await get_tree().process_frame

	# Remove leftover DialogueUI nodes not in new_scene
	var collected: Array = []
	_collect_dialogue_ui_nodes(get_tree().root, collected)
	for ui in collected:
		if ui and ui.is_inside_tree():
			# ensure typed var
			var ui_node: Node = ui as Node
			var ancestor: Node = ui_node
			var is_descendant: bool = false
			while ancestor != null:
				if ancestor == new_scene:
					is_descendant = true
					break
				ancestor = ancestor.get_parent()
			if not is_descendant:
				_write_debug("DialogueManager: freeing leftover DialogueUI at %s" % ui_node.get_path())
				ui_node.queue_free()

	# free old scene if different
	if old_scene and old_scene != new_scene and old_scene.is_inside_tree():
		_write_debug("DialogueManager: queue_free old_scene %s" % old_scene.get_path())
		old_scene.queue_free()

	_write_debug("DialogueManager: finished scene change to %s" % scene_path)


func _write_debug(msg: String) -> void:
	var path: String = "user://dialogue_debug.log"
	var ts_text: String = ""

	# Get OS singleton dynamically to avoid static method references
	if Engine.has_singleton("OS"):
		var os_singleton := Engine.get_singleton("OS")
		# call guarded methods dynamically (call avoids static analyzer errors)
		if os_singleton and os_singleton.has_method("get_unix_time"):
			ts_text = str(os_singleton.call("get_unix_time"))
		elif os_singleton and os_singleton.has_method("get_unix_time_msec"):
			ts_text = str(os_singleton.call("get_unix_time_msec"))
		elif os_singleton and os_singleton.has_method("get_ticks_msec"):
			ts_text = str(os_singleton.call("get_ticks_msec"))

	# Final fallback: frames drawn (always available)
	if ts_text == "":
		ts_text = "frame:%s" % str(Engine.get_frames_drawn())

	var line: String = "[%s] %s\n" % [ts_text, msg]

	# Append to the user:// log file. Try WRITE_READ then WRITE.
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE_READ)
	if not f:
		f = FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.seek_end()
		f.store_string(line)
		f.close()
	else:
		# In editor you'll still see this if writing fails
		push_error("Failed to open debug log '%s' — msg: %s" % [path, msg])
