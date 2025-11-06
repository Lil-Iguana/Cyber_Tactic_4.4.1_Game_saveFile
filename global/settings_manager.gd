extends Node

# Settings file path
const SETTINGS_FILE = "user://settings.cfg"

# Available resolutions
const RESOLUTIONS = {
	"2560×1440": Vector2i(2560, 1440),
	"1920x1080": Vector2i(1920, 1080),
	"1280x720": Vector2i(1280, 720),
	"640x360": Vector2i(640, 360)
}

# Default settings
var config = {
	"fullscreen": false,
	"resolution": "1280x720",
	"master_volume": 0.8,
	"music_volume": 0.8,
	"sfx_volume": 0.8
}

# Audio bus indices
var master_bus = AudioServer.get_bus_index("Master")
var music_bus = AudioServer.get_bus_index("Music")
var sfx_bus = AudioServer.get_bus_index("SFX")

func _ready():
	load_settings()
	apply_settings()

# Save settings to file
func save_settings():
	var config_file = ConfigFile.new()
	
	config_file.set_value("display", "fullscreen", config.fullscreen)
	config_file.set_value("display", "resolution", config.resolution)
	config_file.set_value("audio", "master_volume", config.master_volume)
	config_file.set_value("audio", "music_volume", config.music_volume)
	config_file.set_value("audio", "sfx_volume", config.sfx_volume)
	
	var err = config_file.save(SETTINGS_FILE)
	if err != OK:
		push_error("Failed to save settings: " + str(err))

# Load settings from file
func load_settings():
	var config_file = ConfigFile.new()
	var err = config_file.load(SETTINGS_FILE)
	
	if err != OK:
		print("No settings file found, using defaults")
		return
	
	config.fullscreen = config_file.get_value("display", "fullscreen", false)
	config.resolution = config_file.get_value("display", "resolution", "1280x720")
	config.master_volume = config_file.get_value("audio", "master_volume", 0.8)
	config.music_volume = config_file.get_value("audio", "music_volume", 0.8)
	config.sfx_volume = config_file.get_value("audio", "sfx_volume", 0.8)

# Apply all settings
func apply_settings():
	set_resolution(config.resolution)
	set_fullscreen(config.fullscreen)
	set_master_volume(config.master_volume)
	set_music_volume(config.music_volume)
	set_sfx_volume(config.sfx_volume)

# Display settings
func set_fullscreen(value: bool):
	config.fullscreen = value
	if value:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_resolution(resolution_key: String):
	if not RESOLUTIONS.has(resolution_key):
		push_error("Invalid resolution: " + resolution_key)
		return
	
	config.resolution = resolution_key
	var new_size = RESOLUTIONS[resolution_key]
	
	# Only change window size if not in fullscreen
	if not config.fullscreen:
		DisplayServer.window_set_size(new_size)
		center_window()

func center_window():
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	var centered_position = (screen_size - window_size) / 2
	DisplayServer.window_set_position(centered_position)

# Audio settings
func set_master_volume(value: float):
	config.master_volume = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(config.master_volume))
	AudioServer.set_bus_mute(master_bus, config.master_volume <= 0.0)

func set_music_volume(value: float):
	config.music_volume = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(config.music_volume))
	AudioServer.set_bus_mute(music_bus, config.music_volume <= 0.0)

func set_sfx_volume(value: float):
	config.sfx_volume = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(config.sfx_volume))
	AudioServer.set_bus_mute(sfx_bus, config.sfx_volume <= 0.0)

# Helper function to convert linear volume (0-1) to decibels
func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)
