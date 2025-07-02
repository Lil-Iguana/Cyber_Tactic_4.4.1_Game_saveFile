class_name CardPileLibraryView
extends Control

const CARD_MENU_UI_LIBRARY_SCENE := preload("res://scenes/ui/card_menu_library_ui.tscn")

@export var card_pile: CardPile
@export var back_button_invisible := false

@onready var title: Label = %Title
@onready var cards: GridContainer = %Cards
@onready var card_tooltip_popup: CardTooltipPopup = %CardTooltipPopUp
@onready var back_button: Button = %BackButton


func _ready() -> void:
	back_button.pressed.connect(hide)
	back_button.visible = !back_button_invisible
	
	for card: Node in cards.get_children():
		card.queue_free()
	
	card_tooltip_popup.hide_tooltip()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if card_tooltip_popup.visible:
			card_tooltip_popup.hide_tooltip()
		else:
			hide()


func show_current_view(new_title: String, randomized: bool = false, _is_choice: bool = false) -> void:
	for card: Node in cards.get_children():
		card.queue_free()
		
	card_tooltip_popup.hide_tooltip()
	title.text = new_title
	_update_view.call_deferred(randomized, _is_choice)


func _update_view(randomized: bool, is_choice: bool) -> void:
	if not card_pile:
		return

	# Clear previous entries
	for child in cards.get_children():
		child.queue_free()
	card_tooltip_popup.hide_tooltip()

	# Duplicate and shuffle if needed
	var all_cards := card_pile.cards.duplicate()
	if randomized:
		RNG.array_shuffle(all_cards)

	# Instantiate discovery-enabled CardMenuLibraryUI
	for card in all_cards:
		var card_ui: CardMenuLibraryUI = CARD_MENU_UI_LIBRARY_SCENE.instantiate()
		card_ui.card = card  # applies modulate via CardLibrary
		card_ui.tooltip_requested.connect(card_tooltip_popup.show_tooltip.bind(is_choice))
		cards.add_child(card_ui)

	show()
