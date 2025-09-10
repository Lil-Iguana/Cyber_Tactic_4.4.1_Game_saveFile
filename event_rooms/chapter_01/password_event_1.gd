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
var stages: Array = []

func _ready() -> void:
	start_button.event_button_callback    = _on_start_pressed
	check_button.event_button_callback    = _on_check_pressed
	countdown_timer.timeout.connect(_on_timer_tick)

	$EventTitle.visible     = true
	$EventGame.visible      = false
	$EventAfterMath.visible = false

# ——— STEP 1: Start ———
func _on_start_pressed() -> void:
	$EventTitle.visible = false
	$EventGame.visible  = true
	_start_timer()

func _start_timer() -> void:
	# build the three stages fresh each run
	stages.clear()
	stages.append({
		"prompt":    "Include a month of the year.",
		"method":    "_check_month",
		"pass_text": "✅ Month found!",
		"fail_text": "❌ No month found."
	})
	stages.append({
		"prompt":    "Include a Roman numeral.",
		"method":    "_check_roman",
		"pass_text": "✅ Roman numeral found!",
		"fail_text": "❌ No valid Roman numeral."
	})
	stages.append({
		"prompt":    "Include at least one prime number.",
		"method":    "_check_prime",
		"pass_text": "✅ Prime number found!",
		"fail_text": "❌ No prime number."
	})

	time_left = time_limit
	timer_bar.max_value = time_limit
	timer_bar.value     = time_left
	current_stage = 0

	result_label.bbcode_enabled = true
	result_label.text = "[color=orange]Requirement:[/color] %s" % stages[0]["prompt"]

	check_button.disabled = false
	countdown_timer.start()

# ——— STEP 2: Timer ———
func _on_timer_tick() -> void:
	time_left -= 1
	if time_left > 0:
		timer_bar.value = time_left
	else:
		countdown_timer.stop()
		_show_aftermath(false, "[center][color=red]⏰ Time’s up! You failed.[/color][/center]")

# ——— STEP 3: Check each stage ———
func _on_check_pressed() -> void:
	var pwd = password_input.text
	var stage = stages[current_stage]

	if call(stage["method"], pwd):
		# passed
		result_label.bbcode_enabled = true
		result_label.text = stage["pass_text"]
		current_stage += 1

		if current_stage < stages.size():
			# brief pause then next prompt
			var t = get_tree().create_timer(0.7)
			await t.timeout
			result_label.bbcode_enabled = true
			result_label.text = "[color=orange]Requirement:[/color] %s" % stages[current_stage]["prompt"]
		else:
			# all done
			countdown_timer.stop()
			_show_aftermath(true)
			check_button.disabled = true
	else:
		# failed this stage
		result_label.bbcode_enabled = true
		result_label.text = stage["fail_text"]

# ——— STEP 4: Aftermath ———
func _show_aftermath(success: bool, override_text: String = "") -> void:
	$EventGame.visible = false
	aftermath_text.bbcode_enabled = true

	if override_text != "":
		aftermath_text.text = override_text
	else:
		if success:
			aftermath_text.text = "[center]\"Success! Here is your award!\"[/center] [center]\n[color=green]+200 cache[/color][/center]
			[center]\nGenerally, it is not a good idea to share your password with colleagues. [/center]"
			run_stats.gold += 200
		else:
			aftermath_text.text = "[center]\"You failed the challenge. Better luck next time!\"[/center]"

	$EventAfterMath.visible = true

func _on_continue_pressed() -> void:
	emit_signal("event_finished", current_stage == stages.size())
	queue_free()

# ———— Helpers ————————

# 1. Month check (case‑insensitive)
func _check_month(pwd: String) -> bool:
	var lower = pwd.to_lower()
	for m in ["january","february","march","april","may","june",
			  "july","august","september","october","november","december"]:
		if lower.find(m) != -1:
			return true
	return false

# 2. Roman numeral check via RegEx
func _check_roman(pwd: String) -> bool:
	var rx = RegEx.new()
	# Matches valid Roman numerals from 1 to 3999
	rx.compile("(?i)\\bM{0,3}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})\\b")
	return rx.search(pwd) != null

# 3. Prime number check
func _check_prime(pwd: String) -> bool:
	var rx = RegEx.new()
	rx.compile("\\d+")
	for match in rx.search_all(pwd):
		# get the matched digits directly
		var num_str = match.get_string()
		var num = int(num_str)
		if _is_prime(num):
			return true
	return false

func _is_prime(n: int) -> bool:
	if n < 2:
		return false
	if n == 2:
		return true
	if n % 2 == 0:
		return false
	var r = int(sqrt(n))
	for i in range(3, r + 1, 2):
		if n % i == 0:
			return false
	return true


func _on_password_input_text_submitted(_new_text: String) -> void:
	_on_check_pressed()
