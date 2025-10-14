extends Control

const RUN_SCENE := preload("res://scenes/run/run.tscn")

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	
	if not DialogueState.has_shown("Scene1"):
		DialogueManager.start_dialogue_from_file(
	"res://dialogues/Cutscene1_Part1.json",
	"Scene1",
	Callable(),            # no custom callback
	1.0                   # optional small delay before scene change
)

func _on_skip_button_pressed() -> void:
	get_tree().change_scene_to_packed(RUN_SCENE)
	queue_free()
