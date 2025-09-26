extends Control

const RUN_SCENE := preload("res://scenes/run/run.tscn")

func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_packed(RUN_SCENE)
	queue_free()
