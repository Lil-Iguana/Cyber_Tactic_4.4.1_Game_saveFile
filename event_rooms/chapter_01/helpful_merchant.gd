extends EventRoom

@onready var duplicate_last_card_button: EventRoomButton = %DuplicateCardButton
@onready var plus_max_hp_button: EventRoomButton = %PlusMaxHPButton
@onready var skip_button: EventRoomButton = %SkipButton
@onready var event_menu: VBoxContainer = %EventMenu
@onready var event_aftermath: VBoxContainer = %EventAftermath
@onready var aftermath_text: RichTextLabel = %AftermathText
@onready var deck_view: CardPileView = %DeckView

var card: Card
var text: String = "[center]\"That's a shame.\nOh well, your funeral.\"[/center]"

func setup() -> void:
	duplicate_last_card_button.event_button_callback = duplicate_card
	#duplicate_last_card_button.event_button_callback = duplicate_last_card
	plus_max_hp_button.event_button_callback = plus_max_hp
	skip_button.event_button_callback = conclude_event
	
	Events.card_chosen.connect(_on_card_chosen_in_card_pile)

func duplicate_card() -> void:
	deck_view.card_pile = character_stats.deck
	deck_view.show_current_view("Choose a card", false, true)

func _on_card_chosen_in_card_pile(card_1: Card) -> void:
	deck_view.hide()
	character_stats.deck.add_card(card_1.duplicate())
	text = "[center]\"Here, enjoy this new power.\nI hope it'll help you.\"[/center]"
	conclude_event()

#todo: function that could be used in another event, do not delete yet
func duplicate_last_card() -> void:
	character_stats.deck.add_card(character_stats.deck.cards[-1].duplicate())
	text = "[center]\"Here, enjoy this new power.\nI hope it'll help you.\"[/center]"
	conclude_event()
# ======

func plus_max_hp() -> void:
	character_stats.max_health += 5
	text = "[center]\"You should feel stronger now.\nYou're welcome.\"[/center]"
	conclude_event()

func conclude_event() -> void:
	event_menu.hide()
	aftermath_text.text = text
	event_aftermath.show()
