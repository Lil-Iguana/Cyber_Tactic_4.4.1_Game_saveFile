# Player turn order:
# 1. START_OF_TURN Threads 
# 2. START_OF_TURN Statuses
# 3. Draw Hand
# 4. End Turn 
# 4.5. Special signal for certain cards and threads that must activate before END_OF_TURN threads
# 5. END_OF_TURN Threads 
# 6. END_OF_TURN Statuses
# 6.5. End of turn effects of cards 
# 7. Discard Hand
class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25

@export var threads: ThreadHandler
@export var player: Player
@export var hand: Hand

var character: CharacterStats


func _ready() -> void:
	Events.card_played.connect(_on_card_played)


func start_battle(char_stats: CharacterStats) -> void:
	character = char_stats
	character.draw_pile = character.deck.custom_duplicate()
	character.draw_pile.shuffle()
	character.discard = CardPile.new()
	character.exhaust_pile = CardPile.new()
	threads.threads_activated.connect(_on_threads_activated)
	player.status_handler.statuses_applied.connect(_on_statuses_applied)
	Events.player_turn_ended.connect(_on_player_turn_ended)
	start_turn()



func start_turn() -> void:
	character.block = 0
	character.reset_mana()
	threads.activate_threads_by_type(ThreadPassive.Type.START_OF_TURN)
	Events.start_of_turn_relics_activated.emit()


func end_turn() -> void:
	hand.disable_hand()
	threads.activate_threads_by_type(ThreadPassive.Type.END_OF_TURN)
	Events.end_of_turn_relics_activated.emit()


func draw_card() -> void:
	reshuffle_deck_from_discard()
	hand.add_card(character.draw_pile.draw_card())
	reshuffle_deck_from_discard()


func draw_cards(amount: int) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(
		func(): Events.player_hand_drawn.emit()
	)


func draw_cards_from_effect(amount: int) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_interval(HAND_DRAW_INTERVAL)
		tween.tween_callback(draw_card)
	tween.finished.connect(
		func(): Events.player_multiple_cards_drawn.emit()
	)
	


func discard_cards() -> void:
	if hand.get_child_count() == 0:
		Events.player_hand_discarded.emit()
		return
	
	var tween := create_tween()
	for card_ui in hand.get_children():
		tween.tween_callback(character.discard.add_card.bind(card_ui.card))
		tween.tween_callback(hand.discard_card.bind(card_ui))
		tween.tween_interval(HAND_DISCARD_INTERVAL)
	
	tween.finished.connect(
		func():
			Events.player_hand_discarded.emit()
	)


func reshuffle_deck_from_discard() -> void:
	if not character.draw_pile.empty():
		return

	while not character.discard.empty():
		character.draw_pile.add_card(character.discard.draw_card())

	character.draw_pile.shuffle()


func _on_card_played(card: Card) -> void:
	if card.remove or card.type == Card.Type.POWER:
		return
	
	character.discard.add_card(card)


func _on_statuses_applied(type: Status.Type) -> void:
	match type:
		Status.Type.START_OF_TURN:
			draw_cards(character.cards_per_turn)
		Status.Type.END_OF_TURN:
			Events.player_turn_ended.emit()


func _on_threads_activated(type: ThreadPassive.Type) -> void:
	match type:
		ThreadPassive.Type.START_OF_TURN:
			player.status_handler.apply_statuses_by_type(Status.Type.START_OF_TURN)
		ThreadPassive.Type.END_OF_TURN:
			player.status_handler.apply_statuses_by_type(Status.Type.END_OF_TURN)


func _on_player_turn_ended() -> void:
	discard_cards()
