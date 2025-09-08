class_name Battle
extends Node2D

@export var battle_stats: BattleStats
@export var char_stats: CharacterStats
@export var music: AudioStream
@export var boss_music: AudioStream
@export var threads: ThreadHandler

@onready var battle_ui: BattleUI = $BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler 
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var player: Player = $Player
@onready var hand: HBoxContainer = %Hand

@onready var map: Map = get_node_or_null("../../Map")


func _ready() -> void:
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	
	Events.player_press_end_turn_button.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	Events.player_died.connect(_on_player_died)
	
	Events.music_set.connect(_on_music_set)


func start_battle() -> void:
	get_tree().paused = false
	
	if battle_stats.battle_tier == 2:
		boss_music = map.boss_music
		MusicPlayer.play_music(boss_music, true)
	
	battle_ui.char_stats = char_stats
	player.stats = char_stats
	player_handler.threads = threads
	enemy_handler.setup_enemies(battle_stats)
	enemy_handler.reset_enemy_actions()
	
	threads.threads_activated.connect(_on_threads_activated)
	threads.activate_threads_by_type(ThreadPassive.Type.START_OF_COMBAT)


func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0 and is_instance_valid(threads):
		threads.activate_threads_by_type(ThreadPassive.Type.END_OF_COMBAT)
	else:
		for enemy: Enemy in enemy_handler.get_children():
			enemy.update_action()


func _on_enemy_turn_ended() -> void:
	GlobalTurnNumber.turn_number_increase()
	player_handler.start_turn()
	enemy_handler.reset_enemy_actions()


func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Game Over!", BattleOverPanel.Type.LOSE)
	SaveGame.delete_data()


func _on_threads_activated(type: ThreadPassive.Type) -> void:
	match type:
		ThreadPassive.Type.START_OF_COMBAT:
			player_handler.start_battle(char_stats)
			battle_ui.initialize_card_pile_ui()
		ThreadPassive.Type.END_OF_COMBAT:
			Events.battle_over_screen_requested.emit("Victorious!", BattleOverPanel.Type.WIN)


func _on_music_set() -> void:
	music = map.music
	boss_music = map.boss_music
	#print("music copied from map")
	
	if battle_stats.battle_tier == 2:
		#print("playing boss music")
		MusicPlayer.play_music(boss_music, true)
	elif not MusicPlayer.already_playing_music():
		MusicPlayer.play_music(music, true)
	else:
		pass
		#print("music already playing")
