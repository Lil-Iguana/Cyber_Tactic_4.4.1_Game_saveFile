class_name IntentUI
extends HBoxContainer

const HOVER_DELAY := 0.3  # seconds to wait before showing tooltip

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Label

var current_description: String = ""
var hover_timer: Timer = null
var is_showing_tooltip := false


func _ready() -> void:
	_setup_hover_timer()


func _setup_hover_timer() -> void:
	hover_timer = Timer.new()
	hover_timer.wait_time = HOVER_DELAY
	hover_timer.one_shot = true
	hover_timer.timeout.connect(_on_hover_timer_timeout)
	add_child(hover_timer)


func _on_hover_timer_timeout() -> void:
	if current_description.length() > 0:
		is_showing_tooltip = true
		Events.intent_tooltip_requested.emit(current_description, get_global_mouse_position())


func update_intent(intent: Intent, description: String = "") -> void:
	if not intent:
		hide()
		current_description = ""
		return
	
	icon.texture = intent.icon
	icon.visible = icon.texture != null
	label.text = str(intent.current_text)
	label.visible = intent.current_text.length() > 0
	current_description = description
	show()


func _on_mouse_entered() -> void:
	if current_description.length() > 0 and hover_timer:
		hover_timer.start()


func _on_mouse_exited() -> void:
	# Stop the timer if it's running
	if hover_timer and not hover_timer.is_stopped():
		hover_timer.stop()
	
	# Hide tooltip if it's showing
	if is_showing_tooltip:
		is_showing_tooltip = false
		Events.intent_tooltip_hide_requested.emit()


func _process(_delta: float) -> void:
	# Update tooltip position while hovering
	if is_showing_tooltip:
		Events.intent_tooltip_position_updated.emit(get_global_mouse_position())
