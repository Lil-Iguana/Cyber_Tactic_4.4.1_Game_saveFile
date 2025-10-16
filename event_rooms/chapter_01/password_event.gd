extends EventRoom

# ——— Configurable in Inspector ———
@export var time_limit: int = 15  # secAonds before timeout
# (you can tweak time_limit per-scene in the editor)

signal event_finished(success: bool)

# ——— Node References ———
@onready var start_button    : EventRoomButton  = %StartButton
@onready var title_label     : Label            = %title_label
@onready var password_input  : LineEdit         = %password_input
@onready var check_button    : EventRoomButton  = %check_button
@onready var timer_bar       : ProgressBar      = %timer_bar
@onready var result_label    : RichTextLabel    = %result_label
@onready var countdown_timer : Timer            = %CountdownTimer
@onready var aftermath_box   : VBoxContainer    = %EventAfterMath
@onready var aftermath_text  : RichTextLabel    = %aftermath_text

# ——— Internal state ———
var time_left: int
var current_stage: int = 0

# ——— Define stages with method names ———
var stages = [
	{
		"prompt": "At least 10 characters.",
		"method": "_check_length",
		"pass_text": "✅ Length OK!",
		"fail_text": "❌ Need at least 10 characters."
	},
	{
		"prompt": "Include at least one number.",
		"method": "_check_number",
		"pass_text": "✅ Number found!",
		"fail_text": "❌ No number yet."
	},
	{
		"prompt": "Include at least one symbol/special character.",
		"method": "_check_symbol",
		"pass_text": "✅ Symbol found!",
		"fail_text": "❌ No symbol yet."
	}
]

func _ready() -> void:
	# wire up callbacks
	start_button.event_button_callback    = _on_start_pressed
	check_button.event_button_callback    = _on_check_pressed
	countdown_timer.timeout.connect(_on_timer_tick)

	# initial visibility
	$EventTitle.visible    = true
	$EventGame.visible     = false
	$EventAfterMath.visible = false

# ——— STEP 1: Start the mini‑game ———
func _on_start_pressed() -> void:
	$EventTitle.visible = false
	$EventGame.visible  = true
	_start_timer()

func _start_timer() -> void:
	time_left = time_limit
	timer_bar.max_value = time_limit
	timer_bar.value     = time_left

	current_stage = 0
	result_label.bbcode_enabled = true
	result_label.text = "[color=orange]Requirement:[/color] %s" % stages[current_stage]["prompt"]

	check_button.disabled = false
	countdown_timer.start()

# ——— STEP 2: Timer countdown ———
func _on_timer_tick() -> void:
	time_left -= 1
	if time_left > 0:
		timer_bar.value = time_left
	else:
		countdown_timer.stop()
		_show_aftermath(false, "[center][color=red]⏰ Time’s up! You failed.\nThe main cons of a bad password include unauthorized access to accounts, which can lead to data breaches, identity theft, and financial losses.[/color][/center]")

# ——— STEP 3: Check current requirement ———
func _on_check_pressed() -> void:
	var pwd = password_input.text
	var stage = stages[current_stage]

	# call the check method by name
	if call(stage.method, pwd):
		# passed this stage
		result_label.bbcode_enabled = true
		result_label.text = stage.pass_text
		current_stage += 1

		if current_stage < stages.size():
			# slight pause before next
			var t = get_tree().create_timer(0.7)
			await t.timeout
			result_label.bbcode_enabled = true
			result_label.text = "[color=orange]Requirement:[/color] %s" % stages[current_stage].prompt
		else:
			# all done — success
			countdown_timer.stop()
			_show_aftermath(true)
			check_button.disabled = true
	else:
		# failed this stage
		result_label.bbcode_enabled = true
		result_label.text = stage.fail_text

# ——— STEP 4: Show aftermath & cleanup ———
func _show_aftermath(success: bool, override_text: String = "") -> void:
	$EventGame.visible = false

	aftermath_text.bbcode_enabled = true
	if override_text != "":
		aftermath_text.text = override_text
	else:
		if success:
			aftermath_text.text = "[center]\"Success! Here is your award!\"[/center] [center]\n[color=green]+200 cache[/color][/center]
			[center]\nDo not reuse passwords or variations of the same password. Instead use a slight variation of the same password (Password1, Password2, etc.), practice good password hygiene by creating strong and unique passwords for each of your accounts. [/center]"
			run_stats.gold += 200
		else:
			aftermath_text.text = "[center]\"You failed the challenge. Better luck next time!\"[/center]"

	$EventAfterMath.visible = true

func _on_continue_pressed() -> void:
	emit_signal("event_finished", current_stage == stages.size())
	queue_free()

# ———————— Helpers ————————
func _check_length(pwd: String) -> bool:
	return pwd.length() >= 10

func _check_number(pwd: String) -> bool:
	for c in pwd:
		if c >= "0" and c <= "9":
			return true
	return false

func _check_symbol(pwd: String) -> bool:
	for c in pwd:
		if not ((c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or (c >= "0" and c <= "9")):
			return true
	return false


func _on_password_input_text_submitted(_new_text: String) -> void:
	_on_check_pressed()
