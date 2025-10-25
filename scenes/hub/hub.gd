class_name Hub
extends Node2D

const RUN_SCENE_PATH := "res://scenes/run/run.tscn"
const CARD_MENU_UI = preload("res://scenes/ui/card_menu_ui.tscn")
const CARD_MENU_LIBRARY_UI = preload("res://scenes/ui/card_menu_library_ui.tscn")

@export var character_stats: CharacterStats
@export var run_startup: RunStartup

@onready var gold_label: Label = %GoldLabel
@onready var health_label: Label = %HealthLabel
@onready var health_upgrade_button: Button = %HealthUpgradeButton
@onready var deck_grid: GridContainer = %DeckGrid
@onready var library_grid: GridContainer = %LibraryGrid
@onready var start_run_button: Button = %StartRunButton
@onready var deck_count_label: Label = %DeckCountLabel
@onready var deck_warning_label: Label = %DeckWarningLabel
@onready var card_tooltip_popup: CardTooltipPopup = %CardTooltipPopup

var meta_progression: MetaProgression
var all_cards_database: Array[Card] = []


func _ready() -> void:
	meta_progression = MetaProgression.load_meta()
	
	# Load all available cards from character
	_build_card_database()
	
	# Initialize if first time
	if meta_progression.starting_deck_composition.is_empty():
		meta_progression.initialize_starting_deck(character_stats.starting_deck)
		# Auto-unlock starter cards
		for card in character_stats.starting_deck.cards:
			if not meta_progression.is_card_discovered(card.id):
				meta_progression.add_discovered_card(card.id)
	
	# Sync CardLibrary with meta progression
	CardLibrary.discovered_cards = meta_progression.discovered_cards.duplicate()
	
	_update_ui()
	_populate_deck_grid()
	_populate_library_grid()
	
	health_upgrade_button.pressed.connect(_on_health_upgrade_pressed)
	start_run_button.pressed.connect(_on_start_run_pressed)
	
	# Card tooltip popup will handle its own signals via card_ui instances


func _build_card_database() -> void:
	# Combine all card sources into a single database
	all_cards_database.clear()
	
	# Add from starting deck
	for card in character_stats.starting_deck.cards:
		if not _card_in_database(card.id):
			all_cards_database.append(card)
	
	# Add from draftable cards
	if character_stats.draftable_cards:
		for card in character_stats.draftable_cards.cards:
			if not _card_in_database(card.id):
				all_cards_database.append(card)
	
	# Add from library cards
	if character_stats.library_cards:
		for card in character_stats.library_cards.cards:
			if not _card_in_database(card.id):
				all_cards_database.append(card)


func _card_in_database(card_id: String) -> bool:
	for card in all_cards_database:
		if card.id == card_id:
			return true
	return false


func _get_card_by_id(card_id: String) -> Card:
	for card in all_cards_database:
		if card.id == card_id:
			return card
	return null


func _get_total_deck_count() -> int:
	var total = 0
	for count in meta_progression.starting_deck_composition.values():
		total += count
	return total


func _update_ui() -> void:
	gold_label.text = "Gold: %d" % meta_progression.persistent_gold
	
	var base_hp = character_stats.max_health
	var bonus_hp = meta_progression.get_total_health_bonus()
	health_label.text = "Max HP: %d (+%d)" % [base_hp + bonus_hp, bonus_hp]
	
	# Update health upgrade button
	if meta_progression.health_upgrades_purchased >= 5:
		health_upgrade_button.text = "MAX UPGRADES"
		health_upgrade_button.disabled = true
	else:
		health_upgrade_button.text = "Upgrade HP (+10) - 100g"
		health_upgrade_button.disabled = not meta_progression.can_purchase_health_upgrade()
	
	_update_deck_count()


func _update_deck_count() -> void:
	var total_cards = 0
	for count in meta_progression.starting_deck_composition.values():
		total_cards += count
	
	# Show deck count with minimum requirement
	if total_cards < 11:
		deck_count_label.text = "Starting Deck (%d/11 cards) - MINIMUM REQUIRED" % total_cards
		deck_count_label.add_theme_color_override("font_color", Color.RED)
		start_run_button.disabled = true
		deck_warning_label.show()
	else:
		deck_count_label.text = "Starting Deck (%d cards)" % total_cards
		deck_count_label.add_theme_color_override("font_color", Color.WHITE)
		start_run_button.disabled = false
		deck_warning_label.hide()


func _populate_deck_grid() -> void:
	# Clear existing
	for child in deck_grid.get_children():
		child.queue_free()
	
	# Sort cards by ID for consistent display
	var sorted_cards = meta_progression.starting_deck_composition.keys()
	sorted_cards.sort()
	
	for card_id in sorted_cards:
		var count = meta_progression.starting_deck_composition[card_id]
		var card = _get_card_by_id(card_id)
		if not card:
			continue
		
		# Create multiple instances for each copy
		for i in count:
			var card_container = _create_deck_card_item(card, card_id)
			deck_grid.add_child(card_container)


func _create_deck_card_item(card: Card, card_id: String) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(80, 120)
	
	# Create card visual using your existing CardMenuUI
	var card_ui = CARD_MENU_UI.instantiate() as CardMenuUI
	card_ui.card = card
	card_ui.tooltip_requested.connect(_show_card_tooltip)
	vbox.add_child(card_ui)
	
	# Check if we can remove this card (must maintain 11 card minimum)
	var total_cards = _get_total_deck_count()
	var can_remove = total_cards > 11
	
	var remove_button = Button.new()
	remove_button.text = "Remove"
	remove_button.custom_minimum_size = Vector2(0, 20)
	remove_button.disabled = not can_remove
	remove_button.pressed.connect(_on_remove_card_from_deck.bind(card_id))
	vbox.add_child(remove_button)
	
	return vbox


func _populate_library_grid() -> void:
	# Clear existing
	for child in library_grid.get_children():
		child.queue_free()
	
	# Sort cards by ID for consistent display
	var sorted_cards = all_cards_database.duplicate()
	sorted_cards.sort_custom(func(a, b): return a.id < b.id)
	
	# Show all cards from database
	for card in sorted_cards:
		var item = _create_library_item(card)
		library_grid.add_child(item)


func _create_library_item(card: Card) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(80, 140)
	
	# Create card visual using CardMenuLibraryUI (handles discovered state)
	var card_ui = CARD_MENU_LIBRARY_UI.instantiate() as CardMenuLibraryUI
	card_ui.card = card
	card_ui.tooltip_requested.connect(_show_card_tooltip)
	vbox.add_child(card_ui)
	
	var discovered = meta_progression.is_card_discovered(card.id)
	var current_count = meta_progression.get_card_count_in_starting_deck(card.id)
	
	var status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.custom_minimum_size.y = 15
	if discovered:
		status_label.text = "%d/3" % current_count
		status_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		status_label.text = "???"
		status_label.add_theme_color_override("font_color", Color.DARK_GRAY)
	vbox.add_child(status_label)
	
	var add_button = Button.new()
	add_button.text = "Add"
	add_button.custom_minimum_size = Vector2(0, 20)
	add_button.disabled = not discovered or current_count >= 3
	add_button.pressed.connect(_on_add_card_to_deck.bind(card.id))
	vbox.add_child(add_button)
	
	return vbox


func _on_add_card_to_deck(card_id: String) -> void:
	if meta_progression.add_card_to_starting_deck(card_id):
		_populate_deck_grid()
		_populate_library_grid()
		_update_deck_count()


func _on_remove_card_from_deck(card_id: String) -> void:
	if meta_progression.remove_card_from_starting_deck(card_id):
		_populate_deck_grid()
		_populate_library_grid()
		_update_deck_count()


func _on_health_upgrade_pressed() -> void:
	if meta_progression.purchase_health_upgrade():
		_update_ui()


func _on_start_run_pressed() -> void:
	# Save current meta progression
	meta_progression.save_meta()
	
	# Create a fresh character instance with meta progression applied
	var run_character = character_stats.duplicate()
	
	# Apply meta progression bonuses
	run_character.max_health += meta_progression.get_total_health_bonus()
	run_character.health = run_character.max_health
	run_character.starting_deck = meta_progression.build_starting_deck_pile(all_cards_database)
	
	# Setup run startup for new run
	if not run_startup:
		run_startup = RunStartup.new()
	
	run_startup.type = RunStartup.Type.NEW_RUN
	run_startup.picked_character = run_character
	
	# Start new run
	get_tree().change_scene_to_file(RUN_SCENE_PATH)


func _show_card_tooltip(card: Card) -> void:
	card_tooltip_popup.show_tooltip(card, false)
