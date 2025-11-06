extends Label

enum Turn { PLAYER, ENEMY }
var current_turn: Turn = Turn.PLAYER

func _ready() -> void:
	modulate.a = 0.0
	Events.player_hand_drawn.connect(_on_player_turn_start)
	Events.player_hand_discarded.connect(_on_enemy_turn_start)


func _on_player_turn_start() -> void:
	set_turn(Turn.PLAYER)


func _on_enemy_turn_start() -> void:
	set_turn(Turn.ENEMY)


func set_turn(turn: Turn) -> void:
	current_turn = turn
	update_display()
	animate_turn_change()


func update_display() -> void:
	if current_turn == Turn.PLAYER:
		text = "YOUR TURN"
		modulate = Color(0.3, 0.8, 0.3, modulate.a) # Green
	else:
		text = "ENEMY TURN"
		modulate = Color(0.9, 0.3, 0.3, modulate.a) # Red


func animate_turn_change() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Fade in
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	
	# Hold for longer duration
	tween.tween_interval(1.0)
	
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
