class_name CardMenuLibraryUI
extends CenterContainer

signal tooltip_requested(card: Card)

const BASE_STYLEBOX  := preload("res://scenes/card_ui/card_base_stylebox.tres")
const HOVER_STYLEBOX := preload("res://scenes/card_ui/card_hover_stylebox.tres")

@export var card: Card : set = set_card
@onready var visuals: CardVisuals = $Visuals

func _ready() -> void:
	# React when a card becomes discovered
	CardLibrary.connect("card_discovered", Callable(self, "_on_card_discovered"))

# Helper: duplicate + tint a StyleBoxFlat
func apply_tinted_style(template: StyleBoxFlat) -> void:
	if card == null:
		return
	var sb = template.duplicate() as StyleBoxFlat
	sb.bg_color = Card.type_color(card.type)
	visuals.panel.set("theme_override_styles/panel", sb)

func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	card = value
	visuals.card = card
	_update_discovery_state()
	# initial tint
	apply_tinted_style(BASE_STYLEBOX)

func _update_discovery_state() -> void:
	# grey-out if not discovered
	var discovered = CardLibrary.is_discovered(card.id)
	modulate = Color(1, 1, 1, 1) if discovered else Color(1, 1, 1, 0.3)

func _on_card_discovered(unlocked_id: String) -> void:
	if unlocked_id == card.id:
		modulate = Color(1,1,1,1)

func _on_visuals_mouse_entered() -> void:
	apply_tinted_style(HOVER_STYLEBOX)

func _on_visuals_mouse_exited() -> void:
	apply_tinted_style(BASE_STYLEBOX)

func _on_visuals_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse") and card != null:
		tooltip_requested.emit(card)
