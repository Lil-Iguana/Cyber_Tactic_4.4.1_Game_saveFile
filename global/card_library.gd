extends Node

# Tracks IDs of all discovered cards
var discovered_cards: Array[String] = []

# Signal emitted when a new card is first discovered
signal card_discovered(card_id: String)

func _ready() -> void:
	# Connect to global reward/shop signals
	Events.shop_card_selected.connect(_on_card_unlocked)
	Events.card_reward_selected.connect(_on_card_unlocked)

func is_discovered(card_id: String) -> bool:
	return card_id in discovered_cards

func _on_card_unlocked(card: Card) -> void:
	var id_str: String = card.id
	if not is_discovered(id_str):
		discovered_cards.append(id_str)
		emit_signal("card_discovered", id_str)
