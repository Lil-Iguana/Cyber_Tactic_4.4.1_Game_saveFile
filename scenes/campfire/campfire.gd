class_name Campfire
extends Control

@export var char_stats: CharacterStats

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rest_button: Button = %RestButton
@onready var remove_button: Button = %RemoveButton
@onready var deck_view: CardPileView = %DeckView


func _ready() -> void:
	Events.card_chosen.connect(_on_card_chosen_in_card_pile)


func _on_rest_button_pressed() -> void:
	rest_button.disabled = true
	remove_button.disabled = true
	char_stats.heal(ceili(char_stats.max_health * 0.3))
	animation_player.play("fade_out")


func _on_remove_button_pressed() -> void:
	deck_view.card_pile = char_stats.deck
	deck_view.show_current_view("Choose a card", false, true)


func _on_card_chosen_in_card_pile(card: Card) -> void:
	rest_button.disabled = true
	remove_button.disabled = true
	char_stats.deck.remove_card(card)
	deck_view.hide()
	animation_player.play("fade_out")


# This is called by the AnimationPlayer 
# at the end of the 'fade_out'.
func _on_fade_out_finished() -> void:
	Events.campfire_exited.emit()
