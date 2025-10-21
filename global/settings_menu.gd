extends CanvasLayer

@onready var full_screen_check: CheckBox = %FullScreenCheck
@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var master_value_label: Label = %MasterValueLabel
@onready var music_value_label: Label = %MusicValueLabel
@onready var sfx_value_label: Label = %SFXValueLabel
@onready var back_button: Button = %BackButton


func _ready() -> void:
	# Load current settings into UI
	load_current_settings()
	
	# Connect signals
	full_screen_check.toggled.connect(_on_fullscreen_toggled)
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Update value labels
	update_value_labels()


func load_current_settings() -> void:
	# Load values from SettingsManager
	full_screen_check.button_pressed = SettingsManager.config.fullscreen
	master_slider.value = SettingsManager.config.master_volume * 100
	music_slider.value = SettingsManager.config.music_volume * 100
	sfx_slider.value = SettingsManager.config.sfx_volume * 100


func update_value_labels() -> void:
	master_value_label.text = str(int(master_slider.value)) + "%"
	music_value_label.text = str(int(music_slider.value)) + "%"
	sfx_value_label.text = str(int(sfx_slider.value)) + "%"


# Signal callbacks
func _on_fullscreen_toggled(toggled: bool) -> void:
	SettingsManager.set_fullscreen(toggled)
	SettingsManager.save_settings()


func _on_master_volume_changed(value: float) -> void:
	SettingsManager.set_master_volume(value / 100.0)
	SettingsManager.save_settings()
	master_value_label.text = str(int(value)) + "%"


func _on_music_volume_changed(value: float) -> void:
	SettingsManager.set_music_volume(value / 100.0)
	SettingsManager.save_settings()
	music_value_label.text = str(int(value)) + "%"


func _on_sfx_volume_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value / 100.0)
	SettingsManager.save_settings()
	sfx_value_label.text = str(int(value)) + "%"


func _on_back_pressed() -> void:
	hide()
