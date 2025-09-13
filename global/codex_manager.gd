extends Node

# Holds CodexEntry resources by id
var entries: Dictionary = {}
# For runtime unlocking tracking
var discovered_ids: Array = []

const _FORCE_INCLUDE_CODEX := [
	preload("res://custom_resources/codex/malware_codex.tres"),
	preload("res://custom_resources/codex/toxic_ghost_codex.tres"),
	preload("res://custom_resources/codex/virus_codex.tres")
]

signal entry_unlocked(id: String)

func _ready():
	load_all_entries()
	load_state()

func load_all_entries() -> void:
	entries.clear()
	var dir = DirAccess.open("res://resources/codex")
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var path := "res://resources/codex/%s" % file_name
				var res = ResourceLoader.load(path)
				if res:
					entries[res.id] = res
				else:
					printerr("CodexManager: FAILED to load resource:", path)
			file_name = dir.get_next()
		dir.list_dir_end()

	# Fallback: if nothing loaded, use forced preloads (ensures exported builds have entries)
	if entries.size() == 0:
		for r in _FORCE_INCLUDE_CODEX:
			if r and r is Resource:
				if r.has_method("get") == false: # not safe check — but we want id property
					# assume it's a CodexEntry resource
					entries[r.id] = r
				else:
					entries[r.id] = r
		print("CodexManager: loaded entries via _FORCE_INCLUDE_CODEX, count:", entries.size())

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
		print("CodexManager: no savedata found")
		return
	print("CodexManager: savedata found, codex_discovered count:", save_res.codex_discovered.size())
	for eid in save_res.codex_discovered:
		print("  saved unlocked id:", eid)
		if entries.has(eid):
			entries[eid].is_unlocked = true
			discovered_ids.append(eid)
