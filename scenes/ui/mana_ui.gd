class_name ManaUI
extends Panel

@export var char_stats: CharacterStats : set = _set_char_stats

@onready var mana_label: Label = $ManaLabel
@onready var particles: CPUParticles2D = $ManaParticles
@onready var audio_player: AudioStreamPlayer = $ManaGainAudio
@onready var glow_tween: Tween

var previous_mana: int = 0

func _ready() -> void:
	# Setup particles and audio
	setup_particles()
	setup_audio()

func setup_particles() -> void:
	# Create particles node if it doesn't exist
	if not has_node("ManaParticles"):
		particles = CPUParticles2D.new()
		particles.name = "ManaParticles"
		add_child(particles)
		particles.position = Vector2(9, 9)  # Center of the 18x18 panel
	
	# Configure particle properties for clean, simple effect
	particles.emitting = false
	particles.amount = 8
	particles.lifetime = 1.0
	particles.one_shot = true
	
	# Shape and direction
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 8.0
	particles.direction = Vector2(0, -1)
	particles.spread = 45.0
	
	# Movement
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 40.0
	particles.gravity = Vector2(0, -10)
	particles.linear_accel_min = -5.0
	particles.linear_accel_max = 5.0
	
	# Appearance
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.2
	particles.scale_amount_curve = create_fade_curve()
	
	# Color (bright blue/cyan for energy theme)
	particles.color = Color.CYAN
	particles.color_ramp = create_color_ramp()

func create_fade_curve() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(0.8, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	return curve

func create_color_ramp() -> Gradient:
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.CYAN)
	gradient.add_point(0.7, Color(0.5, 0.8, 1.0, 0.8))
	gradient.add_point(1.0, Color(0.3, 0.6, 1.0, 0.0))
	return gradient

func setup_audio() -> void:
	# Create audio player if it doesn't exist
	if not has_node("ManaGainAudio"):
		audio_player = SFXPlayer.new()
		audio_player.name = "ManaGainAudio"
		add_child(audio_player)
	
	# Create a simple beep sound using AudioStreamRandomPitch with a basic tone
	# For now, we'll set it up without a stream - you can add your own audio file
	audio_player.volume_db = -10.0  # Adjust volume as needed
	audio_player.pitch_scale = 1.0
	
	# If you want to test with a placeholder, you could add:
	# audio_player.stream = preload("res://path/to/your/beep_sound.ogg")

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	
	if not char_stats.stats_changed.is_connected(_on_stats_changed):
		char_stats.stats_changed.connect(_on_stats_changed)
	
	if not is_node_ready():
		await ready
	
	previous_mana = char_stats.mana
	_on_stats_changed()

func _on_stats_changed() -> void:
	var current_mana = char_stats.mana
	mana_label.text = "%s/%s" % [current_mana, char_stats.max_mana]
	
	# Check if mana increased
	if current_mana > previous_mana:
		play_mana_gain_effect(current_mana - previous_mana)
	
	previous_mana = current_mana

func play_mana_gain_effect(mana_gained: int) -> void:
	# Scale particle amount based on mana gained
	particles.amount = mini(mana_gained * 4, 16)
	
	# Trigger particles
	particles.restart()
	particles.emitting = true
	
	# Play sound effect with pitch variation based on mana gained
	if audio_player and audio_player.stream:
		audio_player.pitch_scale = 1.0 + (mana_gained * 0.1)  # Higher pitch for more mana
		audio_player.play()
	elif audio_player:
		# Debug: Print when trying to play without a stream
		print("ManaUI: No audio stream set - add your sound file!")
	
	# Create glow effect on the mana label
	if glow_tween:
		glow_tween.kill()
	glow_tween = create_tween()
	glow_tween.set_parallel(true)
	
	# Scale pulse
	glow_tween.tween_method(_set_label_scale, 1.0, 1.3, 0.1)
	glow_tween.tween_method(_set_label_scale, 1.3, 1.0, 0.2).set_delay(0.1)
	
	# Color flash
	var original_color = mana_label.modulate
	glow_tween.tween_property(mana_label, "modulate", Color.CYAN, 0.05)
	glow_tween.tween_property(mana_label, "modulate", original_color, 0.3).set_delay(0.05)

func _set_label_scale(scale_value: float) -> void:
	mana_label.scale = Vector2(scale_value, scale_value)
