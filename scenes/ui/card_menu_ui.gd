class_name CardMenuUI
extends CenterContainer

signal tooltip_requested(card: Card)

const BASE_STYLEBOX  := preload("res://scenes/card_ui/card_base_stylebox.tres")
const HOVER_STYLEBOX := preload("res://scenes/card_ui/card_hover_stylebox.tres")

@export var card: Card : set = set_card

@onready var visuals: CardVisuals = $Visuals

# helper to duplicate + tint any StyleBoxFlat template
func apply_tinted_style(template: StyleBoxFlat) -> void:
	if card == null:
		return
	var sb = template.duplicate() as StyleBoxFlat
	sb.bg_color = Card.type_color(card.type)
	visuals.panel.set("theme_override_styles/panel", sb)

# mouse‐enter => hover style
func _on_visuals_mouse_entered() -> void:
	apply_tinted_style(HOVER_STYLEBOX)

# mouse‐exit  => back to base style
func _on_visuals_mouse_exited() -> void:
	apply_tinted_style(BASE_STYLEBOX)

# click => tooltip emit
func _on_visuals_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse") and card != null:
		tooltip_requested.emit(card)

# when a new card is assigned, update visuals & tint base
func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	card = value
	visuals.card = card
	apply_tinted_style(BASE_STYLEBOX)
