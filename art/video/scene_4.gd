extends Control

const RUN_SCENE := preload("res://scenes/run/run.tscn")
const SCENE5 := preload("res://art/video/Scene5.tscn")


func _on_skip_button_pressed() -> void:
	get_tree().change_scene_to_packed(RUN_SCENE)
	queue_free()


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_packed(SCENE5)
	queue_free()
