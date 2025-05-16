class_name CardTooltipPopup
extends Control

const CARD_MENU_UI_SCENE := preload("res://scenes/ui/card_menu_ui.tscn")

@export var background_color: Color = Color("000000b0")

@onready var background: ColorRect = $Background
@onready var tooltip_card: CenterContainer = %TooltipCard
@onready var card_name = %CardName
@onready var card_type = %CardType
@onready var rarity_type = %RarityType
@onready var card_description: RichTextLabel = %CardDescription
@onready var choose_button: Button = %ChooseButton

var current_card: Card


func _ready() -> void:
	for card: CardMenuUI in tooltip_card.get_children():
		card.queue_free()
		
	background.color = background_color


func show_tooltip(card: Card, _is_choice: bool = false) -> void:
	var new_card := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
	tooltip_card.add_child(new_card)
	new_card.card = card
	new_card.tooltip_requested.connect(hide_tooltip.unbind(1))
	card_name.text = card.name
	card_type.text = "(" + Card.Type.keys()[card.type].capitalize() + ")"
	rarity_type.text = "(" + Card.Rarity.keys()[card.rarity].capitalize() + ")"
	card_description.text = card.get_default_tooltip()
	current_card = card
	choose_button.visible = _is_choice
	show()


func hide_tooltip() -> void:
	if not visible:
		return
	
	for card: CardMenuUI in tooltip_card.get_children():
		card.queue_free()
	
	hide()


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		hide_tooltip()


func _on_choose_button_pressed() -> void:
	Events.card_chosen.emit(current_card)
	hide_tooltip()


func _on_back_button_pressed() -> void:
	hide_tooltip()
