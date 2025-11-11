class_name RunStatsTracker
extends Resource

# Statistics tracked during a single run
@export var enemies_defeated: int = 0
@export var enemies_by_tier: Dictionary = {
	0: 0,  # Easy enemies
	1: 0,  # Medium enemies
	2: 0,  # Hard enemies
	3: 0   # Bosses
}
@export var floors_cleared: int = 0
@export var perfect_battles: int = 0  # Battles with no damage taken
@export var bosses_defeated: int = 0
@export var trivia_correct: int = 0
@export var trivia_total: int = 0
@export var total_damage_taken: int = 0
@export var total_damage_dealt: int = 0


# Track when a battle is won
func record_battle_won(battle_tier: int, was_perfect: bool = false) -> void:
	if battle_tier in enemies_by_tier:
		enemies_by_tier[battle_tier] += 1
	
	enemies_defeated += 1
	
	if battle_tier == 3:  # Boss tier
		bosses_defeated += 1
	
	if was_perfect:
		perfect_battles += 1


# Track floor progression
func record_floor_cleared() -> void:
	floors_cleared += 1


# Track damage
func record_damage_taken(amount: int) -> void:
	total_damage_taken += amount


func record_damage_dealt(amount: int) -> void:
	total_damage_dealt += amount


# Track trivia performance
func record_trivia_answer(correct: bool) -> void:
	trivia_total += 1
	if correct:
		trivia_correct += 1


# Calculate Knowledge Points based on performance
func calculate_knowledge_points() -> int:
	var points := 0
	
	# Points for enemies defeated (weighted by tier)
	points += enemies_by_tier.get(0, 0) * 10   # Easy enemies: 10 KP each
	points += enemies_by_tier.get(1, 0) * 20   # Medium enemies: 20 KP each
	points += enemies_by_tier.get(2, 0) * 40   # Hard enemies: 40 KP each
	points += enemies_by_tier.get(3, 0) * 100  # Bosses: 100 KP each
	
	# Bonus points for floors cleared
	points += floors_cleared * 15
	
	# Bonus points for perfect battles
	points += perfect_battles * 30
	
	# Bonus points for trivia
	points += trivia_correct * 20
	
	# Bonus for completing the run (if all floors cleared)
	if floors_cleared >= 15:  # Assuming max floors (adjust as needed)
		points += 200
	
	return points


# Get rank based on Knowledge Points
func get_rank(knowledge_points: int) -> Dictionary:
	if knowledge_points >= 1000:
		return {"tier": "Platinum", "title": "Chief Security Officer"}
	elif knowledge_points >= 600:
		return {"tier": "Gold", "title": "Penetration Tester"}
	elif knowledge_points >= 300:
		return {"tier": "Silver", "title": "Security Analyst"}
	else:
		return {"tier": "Bronze", "title": "Script Kiddie"}


# Reset stats for a new run
func reset() -> void:
	enemies_defeated = 0
	enemies_by_tier = {0: 0, 1: 0, 2: 0, 3: 0}
	floors_cleared = 0
	perfect_battles = 0
	bosses_defeated = 0
	trivia_correct = 0
	trivia_total = 0
	total_damage_taken = 0
	total_damage_dealt = 0
