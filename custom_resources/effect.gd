class_name Effect
extends RefCounted

var sound: AudioStream
@warning_ignore("unused_signal")
signal completed

func execute(_targets: Array[Node]) -> void:
	pass

func should_wait() -> bool:
	return false  # Override for effects that need time
