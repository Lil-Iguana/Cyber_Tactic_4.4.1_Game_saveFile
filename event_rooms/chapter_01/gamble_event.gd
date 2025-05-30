extends EventRoom

@onready var fifty_button: EventRoomButton = %FiftyButton
@onready var thirty_button: EventRoomButton = %ThirtyButton
@onready var skip_button: EventRoomButton = %SkipButton
@onready var event_menu: VBoxContainer = %EventMenu
@onready var event_aftermath: VBoxContainer = %EventAfterMath
@onready var aftermath_text: RichTextLabel = %AftermathText

var text: String = "[center]\"Wrong! The correct answer is B. The Melissa virus caused USD 80 Million of damages.\"[/center]"

func setup() -> void:

	fifty_button.event_button_callback = bet_50
	thirty_button.event_button_callback = bet_30
	skip_button.event_button_callback = conclude_event


func bet_30() -> void:
	thirty_button.disabled = true
	
	conclude_event()


func bet_50() -> void:
	fifty_button.disabled = true
	text = "[center]\"Correct! Here is your award!\"[/center]"
	run_stats.gold += 200
	
	conclude_event()

func conclude_event() -> void:
	event_menu.hide()
	aftermath_text.text = text
	event_aftermath.show()
