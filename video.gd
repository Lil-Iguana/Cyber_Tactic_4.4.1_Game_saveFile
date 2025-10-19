extends Control

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout

	if not DialogueState.has_shown("Scene1"):
		# pass a callback that will be invoked when the UI finishes
		DialogueManager.start_dialogue_from_file(
			"res://dialogues/Cutscene1_Part1.json",
			"Scene1",
			Callable(self, "_on_dialogue_complete"),
			0.0
		)
	else:
		# If dialogue already shown, just go straight to run
		_go_to_run_and_free()

func _on_skip_button_pressed() -> void:
	# immediate skip behaviour (same as finished callback)
	_go_to_run_and_free()

# Callback when DialogueManager finishes the UI
func _on_dialogue_complete() -> void:
	_go_to_run_and_free()

# Helper: change to run scene then queue_free this node safely
func _go_to_run_and_free() -> void:

	# Wait one frame to let the scene system settle (defensive; prevents race in exported builds)
	await get_tree().process_frame

	# Defer queue_free so we don't free while Godot is iterating the tree
	call_deferred("queue_free")
