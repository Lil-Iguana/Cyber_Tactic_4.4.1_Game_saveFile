extends Control

const CARD_HAND_CHOICE_UI := preload("res://scenes/ui/card_hand_choice_ui.tscn")

@onready var title: Label = %Title
@onready var hand_copy: HBoxContainer = %HandCopy
@onready var card_tooltip_popup: CardTooltipPopup = %CardTooltipPopUp
@onready var hand := get_tree().get_first_node_in_group("ui_layer").get_child(0)


func _ready() -> void:
	Events.hand_choice_requested.connect(_on_hand_choice_requested)
	Events.card_chosen.connect(_on_card_chosen)
	Events.battle_over_screen_requested.connect(_on_battle_over_screen_requested)
	
	# Delete placeholder cards
	for card: CardHandChoiceUI in hand_copy.get_children():
		card.queue_free()
	

func _on_hand_choice_requested(reason: String = "test") -> void:
	hand.visible = false
	
	for card: CardHandChoiceUI in hand_copy.get_children():
		card.queue_free()
	
	if hand.get_child_count() == 0:
		await get_tree().process_frame
		Events.card_chosen.emit(null)
		print("no card to choose from")
	
	elif hand.get_child_count() == 1:
		var only_card := hand.get_child(0)
		await get_tree().process_frame
		Events.card_chosen.emit(only_card.card)
		print("only card to choose from: ", only_card.card)
	else:
		for card_ui: CardUI in hand.get_children():
			var new_card := CARD_HAND_CHOICE_UI.instantiate() as CardHandChoiceUI
			hand_copy.add_child(new_card)
			new_card.set_card(card_ui.card)
			new_card.hand_choice_tooltip_requested.connect(card_tooltip_popup.show_tooltip.bind(true))
			
		title.text = reason
		show()
	


func _on_card_chosen(_card: Card) -> void:
	hand.visible = true
	for card: CardHandChoiceUI in hand_copy.get_children():
		card.queue_free()
	hide()


func _on_battle_over_screen_requested(_text, _type) -> void:
	hand.visible = true
	hide()
