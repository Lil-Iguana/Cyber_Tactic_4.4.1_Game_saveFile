class_name BattleSim
extends Node2D

@export var char_stats: CharacterStats
@export var music: AudioStream

@onready var battle_ui: BattleUISim = $BattleUI 
@onready var player_handler: PlayerHandlerSim = $PlayerHandler
@onready var enemy_handler: EnemyHandlerSim = $EnemyHandler
@onready var player: Player = $Player

var tutorial_manager: TutorialManager


func _ready() -> void:
	# Check if tutorial should be shown
	if not DialogueState.has_shown("battle_sim_tutorial"):
		_setup_tutorial()
	
	var new_stats: CharacterStats = char_stats.create_instance()
	battle_ui.char_stats = new_stats
	player.stats = new_stats
	
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	
	Events.player_press_end_turn_button.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	Events.player_died.connect(_on_player_died)
	
	Events.music_set.connect(_on_music_set)
	
	start_battle(new_stats)


func _setup_tutorial() -> void:
	# Load the tutorial steps script
	var tutorial_steps_script = preload("res://scenes/tutorial/battle_sim_tutorial_steps.gd")
	var tutorial_steps := tutorial_steps_script.create_steps()
	
	# Create tutorial manager
	tutorial_manager = TutorialManager.new()
	tutorial_manager.steps = tutorial_steps
	tutorial_manager.tutorial_key = "battle_sim_tutorial"
	add_child(tutorial_manager)
	
	# Start tutorial after a short delay
	await get_tree().create_timer(1.0).timeout
	tutorial_manager.start_tutorial()


func start_battle(stats: CharacterStats) -> void:
	get_tree().paused = false
	MusicPlayer.play(music, true)
	enemy_handler.reset_enemy_actions()
	player_handler.start_battle(stats)


func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0:
		Events.battle_over_screen_requested.emit("Victorious!", BattleOverPanel.Type.WIN)


func _on_enemy_turn_ended() -> void:
	GlobalTurnNumber.turn_number_increase()
	player_handler.start_turn()
	enemy_handler.reset_enemy_actions()


func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Game Over!", BattleOverPanel.Type.LOSE)
	SaveGame.delete_data()


func _on_music_set() -> void:
	if not MusicPlayer.already_playing_music():
		MusicPlayer.play_music(music, true)
	else:
		pass
		#print("music already playing")
