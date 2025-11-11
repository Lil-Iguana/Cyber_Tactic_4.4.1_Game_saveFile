extends EventRoom

@onready var answer_a_button: EventRoomButton = %AnswerAButton
@onready var answer_b_button: EventRoomButton = %AnswerBButton
@onready var answer_c_button: EventRoomButton = %AnswerCButton
@onready var intro_screen: VBoxContainer = %IntroScreen
@onready var event_menu: VBoxContainer = %EventMenu
@onready var event_aftermath: VBoxContainer = %EventAfterMath
@onready var aftermath_text: RichTextLabel = %AftermathText
@onready var question_label: Label = %QuestionLabel
@onready var timer_label: Label = %TimerLabel
@onready var event_title_label: Label = %EventTitleLabel
@onready var event_description: RichTextLabel = %EventDescription
@onready var start_quiz_button: EventRoomButton = %StartQuizButton

var timer: Timer
var time_remaining: int = 30
var correct_answer: String = ""
var question_answered: bool = false

# NEW: Stats tracker reference (passed from run.gd)
var stats_tracker: RunStatsTracker

# Quiz data
var question: String = ""
var answer_a: String = ""
var answer_b: String = ""
var answer_c: String = ""
var reward_gold: int = 100
var explanation: String = ""

# Quiz metadata
var quiz_title: String = "Cybersecurity Quiz"
var quiz_description: String = "[center]Test your knowledge of cybersecurity!\n\nAnswer the question correctly before time runs out to earn gold rewards.\n\n[color=yellow]Time Bonus:[/color] Answer quickly for extra gold![/center]"
var quiz_difficulty: String = "medium"

func setup() -> void:
	# Show intro screen first
	show_intro_screen()
	
	# Set up the start button
	start_quiz_button.event_button_callback = start_quiz
	
	# Load question data but don't display yet
	load_question_data()

func show_intro_screen() -> void:
	event_title_label.text = quiz_title
	event_description.text = quiz_description
	intro_screen.show()
	event_menu.hide()
	event_aftermath.hide()

func start_quiz() -> void:
	# Hide intro, show quiz
	intro_screen.hide()
	event_menu.show()
	
	# Set up the question and answers
	question_label.text = question
	answer_a_button.text = "A.) " + answer_a
	answer_b_button.text = "B.) " + answer_b
	answer_c_button.text = "C.) " + answer_c
	
	# Set up button callbacks
	answer_a_button.event_button_callback = func(): answer_selected("A")
	answer_b_button.event_button_callback = func(): answer_selected("B")
	answer_c_button.event_button_callback = func(): answer_selected("C")
	
	# Set up and start timer
	setup_timer()
	start_timer()

func load_question_data() -> void:
	# Override this in child classes or set the data here
	# This is a default example
	question = "What is a malware that replicates itself without a host program or user intervention called?"
	answer_a = "Trojan"
	answer_b = "Virus"
	answer_c = "Computer Worm"
	correct_answer = "c"
	reward_gold = 100
	explanation = "A computer worm is a type of malicious software that can replicate and spread across networks independently, without needing to attach to a host program or requiring a user to manually spread it."

func setup_timer() -> void:
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func start_timer() -> void:
	time_remaining = 30
	update_timer_display()
	timer.start()

func _on_timer_timeout() -> void:
	if question_answered:
		timer.stop()
		return
	
	time_remaining -= 1
	update_timer_display()
	
	if time_remaining <= 0:
		timer.stop()
		time_up()

func update_timer_display() -> void:
	timer_label.text = "Time: %d" % time_remaining

func answer_selected(selected_answer: String) -> void:
	if question_answered:
		return
	
	question_answered = true
	timer.stop()
	
	# Disable all buttons
	answer_a_button.disabled = true
	answer_b_button.disabled = true
	answer_c_button.disabled = true
	
	if selected_answer == correct_answer:
		correct_answer_given()
	else:
		wrong_answer_given(selected_answer)

func correct_answer_given() -> void:
	var bonus_time: int = max(0, time_remaining - 10)
	var time_bonus: int = bonus_time * 2
	var total_reward: int = reward_gold + time_bonus
	
	run_stats.gold += total_reward
	
	# NEW: Track correct trivia answer
	if is_instance_valid(stats_tracker):
		stats_tracker.record_trivia_answer(true)
	
	var result_text: String = "[center][color=green]Correct![/color]\n\n"
	result_text += explanation + "\n\n"
	result_text += "Base Reward: %d gold\n" % reward_gold
	
	if time_bonus > 0:
		result_text += "Time Bonus: %d gold\n" % time_bonus
	
	result_text += "Total Earned: %d gold[/center]" % total_reward
	
	show_aftermath(result_text)

func wrong_answer_given(selected_answer: String) -> void:
	# NEW: Track incorrect trivia answer
	if is_instance_valid(stats_tracker):
		stats_tracker.record_trivia_answer(false)
	
	var result_text: String = "[center][color=red]Incorrect![/color]\n\n"
	result_text += "You selected: %s\n" % selected_answer
	result_text += "The correct answer was: %s\n\n" % correct_answer
	result_text += explanation + "\n\n"
	result_text += "[color=gray]No reward this time.[/color][/center]"
	
	show_aftermath(result_text)

func time_up() -> void:
	question_answered = true
	
	# NEW: Track incorrect trivia answer (time ran out)
	if is_instance_valid(stats_tracker):
		stats_tracker.record_trivia_answer(false)
	
	# Disable all buttons
	answer_a_button.disabled = true
	answer_b_button.disabled = true
	answer_c_button.disabled = true
	
	var result_text: String = "[center][color=orange]Time's Up![/color]\n\n"
	result_text += "The correct answer was: %s\n\n" % correct_answer
	result_text += explanation + "\n\n"
	result_text += "[color=gray]No reward this time.[/color][/center]"
	
	show_aftermath(result_text)

func show_aftermath(text: String) -> void:
	event_menu.hide()
	aftermath_text.text = text
	event_aftermath.show()
