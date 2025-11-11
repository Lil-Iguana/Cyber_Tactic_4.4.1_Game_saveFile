class_name MetaProgression
extends Resource

const META_SAVE_PATH := "user://meta_progression.tres"

# Persistent data that carries over between runs
@export var persistent_gold: int = 0
@export var knowledge_points: int = 0  # Currency for meta upgrades
@export var health_upgrades_purchased: int = 0  # Max 5
@export var discovered_cards: Array[String] = []

# Starting deck composition (card IDs with quantities)
@export var starting_deck_composition: Dictionary = {}

# First-time playthrough tracking
@export var has_seen_intro: bool = false

# Lifetime stats across all runs
@export var total_enemies_defeated: int = 0
@export var total_floors_climbed: int = 0
@export var total_runs_started: int = 0
@export var total_runs_won: int = 0
@export var total_runs_lost: int = 0
@export var total_knowledge_points_earned: int = 0  # Lifetime KP
@export var total_perfect_battles: int = 0  # NEW
@export var total_trivia_correct: int = 0  # NEW
@export var total_trivia_attempted: int = 0  # NEW
@export var best_rank_tier: String = "Bronze"  # NEW: Best rank achieved
@export var highest_kp_single_run: int = 0  # NEW: Highest KP in a single run

# Codex/Bestiary unlocks (persistent across runs)
@export var codex_discovered: Array[String] = []


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


# Knowledge Points management
func add_knowledge_points(amount: int) -> void:
	knowledge_points += amount
	total_knowledge_points_earned += amount
	
	# Track highest KP in a single run
	if amount > highest_kp_single_run:
		highest_kp_single_run = amount
	
	save_meta()


func spend_knowledge_points(amount: int) -> bool:
	if knowledge_points >= amount:
		knowledge_points -= amount
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


# ===== STATS TRACKING =====

func mark_intro_seen() -> void:
	has_seen_intro = true
	save_meta()


func increment_enemies_defeated(count: int = 1) -> void:
	total_enemies_defeated += count
	save_meta()


func increment_floors_climbed(count: int = 1) -> void:
	total_floors_climbed += count
	save_meta()


func increment_runs_started() -> void:
	total_runs_started += 1
	save_meta()


func increment_runs_won() -> void:
	total_runs_won += 1
	save_meta()


func increment_runs_lost() -> void:
	total_runs_lost += 1
	save_meta()


# NEW: Track run completion stats from RunStatsTracker
func record_run_completion(stats_tracker: RunStatsTracker, rank_data: Dictionary) -> void:
	# Add perfect battles to lifetime total
	total_perfect_battles += stats_tracker.perfect_battles
	
	# Add trivia stats to lifetime total
	total_trivia_correct += stats_tracker.trivia_correct
	total_trivia_attempted += stats_tracker.trivia_total
	
	# Update best rank if this run's rank is better
	var rank_tier = rank_data["tier"]
	if _is_rank_better(rank_tier, best_rank_tier):
		best_rank_tier = rank_tier
	
	save_meta()


# Helper function to compare ranks
func _is_rank_better(new_rank: String, current_rank: String) -> bool:
	var rank_values = {
		"Bronze": 0,
		"Silver": 1,
		"Gold": 2,
		"Platinum": 3
	}
	
	var new_value = rank_values.get(new_rank, 0)
	var current_value = rank_values.get(current_rank, 0)
	
	return new_value > current_value


# Get win rate percentage
func get_win_rate() -> float:
	if total_runs_started == 0:
		return 0.0
	return (float(total_runs_won) / float(total_runs_started)) * 100.0


# Get trivia accuracy percentage
func get_trivia_accuracy() -> float:
	if total_trivia_attempted == 0:
		return 0.0
	return (float(total_trivia_correct) / float(total_trivia_attempted)) * 100.0


# ===== CODEX PERSISTENCE =====

func unlock_codex_entry(id: String) -> void:
	if id not in codex_discovered:
		codex_discovered.append(id)
		save_meta()


func is_codex_entry_unlocked(id: String) -> bool:
	return id in codex_discovered


func get_all_unlocked_codex_entries() -> Array[String]:
	return codex_discovered.duplicate()
