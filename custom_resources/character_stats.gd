class_name CharacterStats
extends Stats

@export_group("Visuals")
@export var character_name: String
@export_multiline var description: String
@export var portrait: Texture

@export_group("Gameplay Data")
@export var starting_deck: CardPile
@export var draftable_cards: CardPile
@export var library_cards: CardPile
@export var cards_per_turn: int
@export var max_mana: int
@export var starting_thread: ThreadPassive

var mana: int : set = set_mana
var deck: CardPile
var discard: CardPile
var draw_pile: CardPile
var exhaust_pile: CardPile
var card_library: CardPile
var max_hand_size := 5


func set_mana(value: int) -> void:
	mana = value
	stats_changed.emit()


func reset_mana() -> void:
	mana = max_mana
	stats_changed.emit()


func take_damage(damage: int) -> void:
	var initial_health := health
	super.take_damage(damage)
	if initial_health > health:
		Events.player_hit.emit()


func can_play_card(card: Card) -> bool:
	return mana >= card.cost


func create_instance() -> Resource:
	var instance: CharacterStats = self.duplicate()
	instance.health = max_health
	instance.block = 0
	instance.reset_mana()
	instance.deck = instance.starting_deck.duplicate()
	instance.card_library = instance.library_cards.duplicate()
	instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()
	instance.exhaust_pile = CardPile.new()
	return instance
