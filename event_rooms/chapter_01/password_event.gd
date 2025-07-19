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

var time_left: int
var strength: int

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
	_on_check_pressed()

func _start_timer() -> void:
	time_left = time_limit
	timer_bar.max_value = time_limit
	timer_bar.value     = time_left
	result_label.clear()
	check_button.disabled = false
	countdown_timer.start()

func _on_timer_tick() -> void:
	time_left -= 1
	if time_left > 0:
		timer_bar.value = time_left
	else:
		countdown_timer.stop()
		_on_time_up()

func _on_time_up() -> void:
	_show_aftermath(false, "[center][color=red]⏰ Time’s up![/color]\nYou failed to meet the requirements.")

# ——— STEP 3: Player presses “Check” ———
func _on_check_pressed() -> void:
	var pwd = password_input.text
	var feedback = "[b]Password Strength Check:[/b]\n"
	strength = 0

	# Length check (weak)
	if pwd.length() >= 10:
		feedback += "✅ At least 10 chars (Weak)\n"
	else:
		feedback += "❌ Less than 10 chars\n"

	# Number check (strong)
	if _contains_digit(pwd):
		feedback += "✅ Contains number (Strong)\n"
		strength += 1
	else:
		feedback += "❌ No number\n"

	# Symbol check (strong)
	if _contains_symbol(pwd):
		feedback += "✅ Contains symbol (Strong)\n"
		strength += 1
	else:
		feedback += "❌ No symbol\n"

	var passed = (strength >= 2 and pwd.length() >= 10)
	if passed:
		countdown_timer.stop()
		feedback += "\n[color=green]🎉 You passed![/green]"
		_show_aftermath(true)
	else:
		feedback += "[color=orange]Keep trying until time runs out!"

	result_label.bbcode_enabled = true
	result_label.text = feedback

	# only disable on success
	check_button.disabled = passed

# ——— STEP 4: Show aftermath & cleanup ———
func _show_aftermath(success: bool, override_text: String = "") -> void:
	$EventGame.visible = false

	aftermath_text.bbcode_enabled = true
	if override_text != "":
		aftermath_text.text = override_text
	else:
		if success:
			aftermath_text.text = "[center]\"Success! Here is your award!\"[/center] [center]\n[color=green]+200 cache[/color][/center]
			[center]\nDon’t reuse passwords or variations of the same password. Instead of reusing your passwords, or a slight variation of the same password (Password1, Password2, etc.), practice good password hygiene by creating strong and unique passwords for each of your accounts. [/center]"
			run_stats.gold += 200
		else:
			aftermath_text.text = "[center]\"You failed the challenge. Better luck next time!\"[/center]"

	$EventAfterMath.visible = true

func _on_continue_pressed() -> void:
	emit_signal("event_finished", strength >= 2)
	queue_free()

# ———————— Helpers ————————
func _contains_digit(pwd: String) -> bool:
	for c in pwd:
		if c >= "0" and c <= "9":
			return true
	return false

func _contains_symbol(pwd: String) -> bool:
	for c in pwd:
		if not ((c >= "a" and c <= "z")
			 or (c >= "A" and c <= "Z")
			 or (c >= "0" and c <= "9")):
			return true
	return false
