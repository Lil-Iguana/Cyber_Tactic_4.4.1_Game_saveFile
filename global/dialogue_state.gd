extends Node

var _path: String = "user://dialogue_state.json"
var data: Dictionary = {
	"intro_shown": false,
	"Scene1": false,
	"first_battle_shown": false,
	"post_battle_shown": false,
	"campfire_shown": false,
	"boss_post_shown": false
}

func _ready() -> void:
	_load()

func _load() -> void:
	if FileAccess.file_exists(_path):
		var f: FileAccess = FileAccess.open(_path, FileAccess.READ)
		if f:
			var txt: String = f.get_as_text()
			f.close()
			var parsed: Variant = JSON.parse_string(txt)
			if typeof(parsed) == TYPE_DICTIONARY:
				var parsed_dict: Dictionary = parsed as Dictionary
				for k in parsed_dict.keys():
					data[k] = parsed_dict[k]

func _save() -> void:
	var f: FileAccess = FileAccess.open(_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func has_shown(key: String) -> bool:
	return bool(data.get(key, false))

func mark_shown(key: String) -> void:
	data[key] = true
	_save()

# Reset all tutorial flags so the tutorials will play again.
func reset_all() -> void:
	data = {
		"intro_shown": false,
		"first_battle_shown": false,
		"post_battle_shown": false
	}
	_save()

# Mark all tutorial flags as shown so tutorials are skipped.
func complete_all() -> void:
	data = {
		"intro_shown": true,
		"first_battle_shown": true,
		"post_battle_shown": true
	}
	_save()
