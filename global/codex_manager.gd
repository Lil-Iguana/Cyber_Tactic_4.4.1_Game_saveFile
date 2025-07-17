extends Node

# Holds CodexEntry resources by id
var entries: Dictionary = {}
# For runtime unlocking tracking
var discovered_ids: Array = []

signal entry_unlocked(id: String)

func _ready():
	load_all_entries()
	load_state()

# Load all `.tres` files placed under res://custom_resources/codex/
func load_all_entries():
	entries.clear()
	var dir = DirAccess.open("res://custom_resources/codex/")
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var res = ResourceLoader.load("res://custom_resources/codex/%s" % file_name)
				if res is CodexEntry:
					entries[res.id] = res
			file_name = dir.get_next()
		dir.list_dir_end()

# Unlock and save state
func unlock(id: String) -> void:
	if entries.has(id) and not entries[id].is_unlocked:
		entries[id].is_unlocked = true
		discovered_ids.append(id)
		emit_signal("entry_unlocked", id)
		save_state()

# Persist to SaveGame resource file
func save_state() -> void:
	# Load existing save or create new
	var save_res: SaveGame = SaveGame.load_data() if SaveGame.load_data() else SaveGame.new()
	# Update codex field
	save_res.codex_discovered = []
	for eid in entries.keys():
		if entries[eid].is_unlocked:
			save_res.codex_discovered.append(eid)
	# Write out
	save_res.save_data()

# Restore from SaveGame
func load_state() -> void:
	var save_res: SaveGame = SaveGame.load_data()
	if not save_res:
		return
	for eid in save_res.codex_discovered:
		if entries.has(eid):
			entries[eid].is_unlocked = true
			discovered_ids.append(eid)
