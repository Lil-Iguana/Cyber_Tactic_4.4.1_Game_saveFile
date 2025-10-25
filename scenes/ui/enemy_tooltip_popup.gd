class_name EnemyTooltip
extends Control

@export var fade_seconds := 0.2

@onready var tooltip_icon: TextureRect = %EnemyIcon
@onready var enemy_name: Label = %EnemyName
@onready var intent_grid: GridContainer = %IntentGrid

var tween: Tween
var is_visible_now := false


func _ready() -> void:
	Events.enemy_tooltip_requested.connect(show_tooltip)
	Events.tooltip_hide_requested.connect(hide_tooltip)
	modulate = Color.TRANSPARENT


func show_tooltip(icon: Texture, name_text: String, icons: Array, descs: Array) -> void:
	is_visible_now = true
	if tween:
		tween.kill()
	
	for child in intent_grid.get_children():
		intent_grid.remove_child(child)
		child.queue_free()
	
	tooltip_icon.texture = icon
	enemy_name.text = name_text
	
	intent_grid.columns = 2
	var count = min(icons.size(), descs.size())
	for i in count:
		var iconS = TextureRect.new()
		iconS.texture = icons[i]
		iconS.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		intent_grid.add_child(iconS)

		# – Description cell as RichTextLabel –
		var rt = RichTextLabel.new()
		rt.bbcode_enabled = true
		rt.fit_content = true
		rt.scroll_active = false
		rt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rt.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		rt.bbcode_text = descs[i]

		intent_grid.add_child(rt)

	# Reset scroll to top if wrapped in ScrollContainer
	if has_node("IntentScroll"):
		$IntentScroll.scroll_vertical = 0
		$IntentScroll.scroll_horizontal = 0
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(show)
	tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)


func hide_tooltip() -> void:
	is_visible_now = false
	if tween:
		tween.kill()
	
	get_tree().create_timer(fade_seconds, false).timeout.connect(hide_animation)


func hide_animation() -> void:
	if not is_visible_now:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_seconds)
		tween.tween_callback(hide)
