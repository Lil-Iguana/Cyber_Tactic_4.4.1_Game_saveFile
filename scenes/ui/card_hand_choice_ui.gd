class_name CardHandChoiceUI
extends CenterContainer

signal hand_choice_tooltip_requested(card: Card)

const BASE_STYLEBOX := preload("res://scenes/card_ui/card_base_stylebox.tres")
const HOVER_STYLEBOX := preload("res://scenes/card_ui/card_hover_stylebox.tres")

@export var card: Card : set = set_card

@onready var visuals: CardVisuals = $Visuals

# Helper to duplicate + tint a StyleBoxFlat according to card.type
func apply_tinted_style(template: StyleBoxFlat) -> void:
	if card == null:
		return
	var sb = template.duplicate() as StyleBoxFlat
	sb.bg_color = Card.type_color(card.type)
	visuals.panel.set("theme_override_styles/panel", sb)

func _on_visuals_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse") and card != null:
		hand_choice_tooltip_requested.emit(card)

func _on_visuals_mouse_entered() -> void:
	apply_tinted_style(HOVER_STYLEBOX)

func _on_visuals_mouse_exited() -> void:
	apply_tinted_style(BASE_STYLEBOX)

func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready

	card = value
	visuals.card = card
	# apply initial tinted base once the card is assigned
	apply_tinted_style(BASE_STYLEBOX)
