class_name RunSummaryScreen
extends Control

const MAIN_MENU_PATH := "res://scenes/ui/main_menu.tscn"

@onready var result_label: Label = %ResultLabel
@onready var stats_container: VBoxContainer = %StatsContainer
@onready var kp_earned_label: Label = %KPEarnedLabel
@onready var rank_label: Label = %RankLabel
@onready var rank_title_label: Label = %RankTitleLabel
@onready var return_button: Button = %ReturnButton

var stats_tracker: RunStatsTracker
var was_victory: bool = false


func _ready() -> void:
	return_button.pressed.connect(_on_return_pressed)


func show_summary(tracker: RunStatsTracker, victory: bool) -> void:
	stats_tracker = tracker
	was_victory = victory
	
	# Set result text
	if victory:
		result_label.text = "RUN COMPLETE!"
		result_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		result_label.text = "SECURITY BREACH"
		result_label.add_theme_color_override("font_color", Color.RED)
	
	# Display statistics
	_display_statistics()
	
	# Calculate and display Knowledge Points
	var kp_earned := tracker.calculate_knowledge_points()
	kp_earned_label.text = "Knowledge Points Earned: %d KP" % kp_earned
	
	# Display rank
	var rank_data := tracker.get_rank(kp_earned)
	
	# Award Knowledge Points and record run stats to meta progression
	var meta := MetaProgression.load_meta()
	meta.add_knowledge_points(kp_earned)
	meta.record_run_completion(tracker, rank_data)
	rank_label.text = rank_data["tier"]
	rank_title_label.text = rank_data["title"]
	
	# Color code rank
	match rank_data["tier"]:
		"Platinum":
			rank_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
		"Gold":
			rank_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
		"Silver":
			rank_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
		"Bronze":
			rank_label.add_theme_color_override("font_color", Color(0.8, 0.5, 0.2))
	
	show()


func _display_statistics() -> void:
	# Clear previous stats
	for child in stats_container.get_children():
		child.queue_free()
	
	# Only add stat labels if the value is greater than 0
	if stats_tracker.enemies_defeated > 0:
		_add_stat_label("Enemies Defeated: %d" % stats_tracker.enemies_defeated)
		
		# Show breakdown by tier (only if > 0)
		if stats_tracker.enemies_by_tier.get(0, 0) > 0:
			_add_stat_label("  - Easy: %d" % stats_tracker.enemies_by_tier.get(0, 0))
		if stats_tracker.enemies_by_tier.get(1, 0) > 0:
			_add_stat_label("  - Medium: %d" % stats_tracker.enemies_by_tier.get(1, 0))
		if stats_tracker.enemies_by_tier.get(2, 0) > 0:
			_add_stat_label("  - Hard: %d" % stats_tracker.enemies_by_tier.get(2, 0))
		if stats_tracker.enemies_by_tier.get(3, 0) > 0:
			_add_stat_label("  - Bosses: %d" % stats_tracker.enemies_by_tier.get(3, 0))
	
	if stats_tracker.floors_cleared > 0:
		_add_stat_label("Floors Cleared: %d" % stats_tracker.floors_cleared)
	
	if stats_tracker.perfect_battles > 0:
		_add_stat_label("Perfect Battles: %d" % stats_tracker.perfect_battles)
	
	# Show trivia stats if any questions were attempted
	if stats_tracker.trivia_total > 0:
		_add_stat_label("Trivia Questions: %d/%d correct" % [stats_tracker.trivia_correct, stats_tracker.trivia_total])


func _add_stat_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats_container.add_child(label)


func _on_return_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
