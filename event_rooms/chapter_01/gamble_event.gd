extends EventRoom

@onready var fifty_button: EventRoomButton = %FiftyButton
@onready var thirty_button: EventRoomButton = %ThirtyButton
@onready var skip_button: EventRoomButton = %SkipButton
@onready var event_menu: VBoxContainer = %EventMenu
@onready var event_aftermath: VBoxContainer = %EventAfterMath
@onready var aftermath_text: RichTextLabel = %AftermathText

var text: String = "[center]\"Playing safe? Never thought you were the type.\"[/center]"

func setup() -> void:
	fifty_button.disabled = run_stats.gold < 50
	thirty_button.disabled = run_stats.gold < 50

	fifty_button.event_button_callback = bet_50
	thirty_button.event_button_callback = bet_30
	skip_button.event_button_callback = conclude_event


func bet_30() -> void:
	thirty_button.disabled = true
	run_stats.gold -= 50
	text = "[center]\"Too bad...\"[/center]"
	if RNG.instance.randf() < 0.3:
		run_stats.gold += 200
		text = "[center]\"Nice going!\"[/center]"
	
	conclude_event()


func bet_50() -> void:
	fifty_button.disabled = true
	run_stats.gold -= 50
	text = "[center]\"Too bad...\"[/center]"
	if RNG.instance.randf() < 0.5:
		run_stats.gold += 100
		text = "[center]\"Nice going!\"[/center]"
	
	conclude_event()

func conclude_event() -> void:
	event_menu.hide()
	aftermath_text.text = text
	event_aftermath.show()
