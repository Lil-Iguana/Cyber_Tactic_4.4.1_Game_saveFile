class_name CardVisuals
extends Control

@export var card: Card : set = set_card

@onready var panel: Panel = $Panel
@onready var cost: Label = $Cost
@onready var icon: TextureRect = $Icon
@onready var rarity: TextureRect = $Rarity


func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready

	card = value
	cost.text = str(card.cost)
	icon.texture = card.icon
	rarity.modulate = card.RARITY_COLORS[card.rarity]
	
	# — duplicate & tint *once*, right after we get a real Card —
	var base_sb = panel.get_theme_stylebox("panel") as StyleBoxFlat
	var tinted  = base_sb.duplicate() as StyleBoxFlat
	tinted.bg_color = Card.type_color(card.type)
	panel.set("theme_override_styles/panel", tinted)
