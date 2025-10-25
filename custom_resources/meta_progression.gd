class_name MetaProgression
extends Resource

const META_SAVE_PATH := "user://meta_progression.tres"

# Persistent data that carries over between runs
@export var persistent_gold: int = 0
@export var health_upgrades_purchased: int = 0  # Max 5
@export var discovered_cards: Array[String] = []

# Starting deck composition (card IDs with quantities)
@export var starting_deck_composition: Dictionary = {}


func save_meta() -> void:
	var err := ResourceSaver.save(self, META_SAVE_PATH)
	assert(err == OK, "Couldn't save meta progression!")


static func load_meta() -> MetaProgression:
	if FileAccess.file_exists(META_SAVE_PATH):
		return ResourceLoader.load(META_SAVE_PATH) as MetaProgression
	
	# Return new meta progression with default values
	return MetaProgression.new()


static func delete_meta() -> void:
	if FileAccess.file_exists(META_SAVE_PATH):
		DirAccess.remove_absolute(META_SAVE_PATH)


func get_total_health_bonus() -> int:
	return health_upgrades_purchased * 10


func can_purchase_health_upgrade() -> bool:
	return health_upgrades_purchased < 5 and persistent_gold >= 100


func purchase_health_upgrade() -> bool:
	if can_purchase_health_upgrade():
		persistent_gold -= 100
		health_upgrades_purchased += 1
		save_meta()
		return true
	return false


func add_gold(amount: int) -> void:
	persistent_gold += amount
	save_meta()


func spend_gold(amount: int) -> bool:
	if persistent_gold >= amount:
		persistent_gold -= amount
		save_meta()
		return true
	return false


func add_discovered_card(card_id: String) -> void:
	if card_id not in discovered_cards:
		discovered_cards.append(card_id)
		save_meta()


func is_card_discovered(card_id: String) -> bool:
	return card_id in discovered_cards


# Initialize starting deck from character's default deck
func initialize_starting_deck(default_deck: CardPile) -> void:
	starting_deck_composition.clear()
	for card in default_deck.cards:
		var card_id = card.id
		if card_id in starting_deck_composition:
			starting_deck_composition[card_id] += 1
		else:
			starting_deck_composition[card_id] = 1
	save_meta()


# Build a CardPile from the composition dictionary
func build_starting_deck_pile(card_database: Array[Card]) -> CardPile:
	var deck := CardPile.new()
	
	for card_id in starting_deck_composition:
		var count = starting_deck_composition[card_id]
		# Find the card in the database
		for card in card_database:
			if card.id == card_id:
				for i in count:
					deck.add_card(card.duplicate())
				break
	
	return deck


func add_card_to_starting_deck(card_id: String) -> bool:
	# Check if we already have 3 copies
	var current_count = starting_deck_composition.get(card_id, 0)
	if current_count >= 3:
		return false
	
	starting_deck_composition[card_id] = current_count + 1
	save_meta()
	return true


func remove_card_from_starting_deck(card_id: String) -> bool:
	if card_id not in starting_deck_composition:
		return false
	
	starting_deck_composition[card_id] -= 1
	if starting_deck_composition[card_id] <= 0:
		starting_deck_composition.erase(card_id)
	
	save_meta()
	return true


func get_card_count_in_starting_deck(card_id: String) -> int:
	return starting_deck_composition.get(card_id, 0)
