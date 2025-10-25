class_name Enemy
extends Area2D

const ARROW_OFFSET := 5
const WHITE_SPRITE_MATERIAL := preload("res://art/white_sprite_material.tres")
const HOVER_DELAY := 1.5  # seconds to wait before showing tooltip

@export var stats: EnemyStats : set = set_enemy_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui: StatsUI = $StatsUI
@onready var intent_ui: IntentUI = $IntentUI
@onready var status_handler: StatusHandler = $StatusHandler
@onready var modifier_handler: ModifierHandler = $ModifierHandler
@onready var model_3d: SubViewport = $SubViewportContainer/SubViewport
@onready var model_3d_flash: Control = $SubViewportContainer

var enemy_action_picker: EnemyActionPicker
var current_action: EnemyAction : set = set_current_action
var hover_timer: Timer = null
var is_showing_tooltip := false


func _replace_editor_placeholder_with_model() -> void:
	if model_3d.has_node("VirusMExp"):
		model_3d.get_node("VirusMExp").queue_free()
	
	if stats and stats.model:
		var real_model_3d = stats.model.instantiate()
		model_3d.add_child(real_model_3d)


func set_current_action(value: EnemyAction) -> void:
	current_action = value
	update_intent()


func set_enemy_stats(value: EnemyStats) -> void:
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
		stats.stats_changed.connect(update_action)
	
	update_enemy()


func setup_ai() -> void:
	if enemy_action_picker:
		enemy_action_picker.queue_free()
	
	var new_action_picker: EnemyActionPicker = stats.ai.instantiate()
	add_child(new_action_picker)
	enemy_action_picker = new_action_picker
	enemy_action_picker.enemy = self


func update_stats() -> void:
	stats_ui.update_stats(stats)


func update_action() -> void:
	if not enemy_action_picker:
		return
	
	if not current_action:
		current_action = enemy_action_picker.get_action()
		return
	
	var new_conditional_action := enemy_action_picker.get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		current_action = new_conditional_action


func update_enemy() -> void:
	if not stats is Stats:
		return
	if not is_inside_tree():
		await ready
	
	sprite_2d.texture = stats.art
	arrow.position = Vector2.RIGHT * (sprite_2d.get_rect().size.x / 2 + ARROW_OFFSET)
	setup_ai()
	update_stats()


func update_intent() -> void:
	if current_action:
		current_action.update_intent_text()
		intent_ui.update_intent(current_action.intent)


func do_turn() -> void:
	stats.block = 0
	
	if not current_action:
		return
	
	current_action.perform_action()


func take_damage(damage: int, which_modifier: Modifier.Type) -> void:
	if stats.health <= 0:
		return
	
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	model_3d_flash.material = WHITE_SPRITE_MATERIAL
	var modified_damage := modifier_handler.get_modified_value(damage, which_modifier)
	
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(stats.take_damage.bind(modified_damage))
	tween.tween_interval(0.17)
	play_hurt()
	
	tween.finished.connect(
		func():
			sprite_2d.material = null
			model_3d_flash.material = null
			play_idle()
			
			if stats.health <= 0:
				Events.enemy_died.emit(self)
				queue_free()
	)


func take_pure_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(stats.take_pure_damage.bind(damage))
	tween.tween_interval(0.17)
	
	tween.finished.connect(
		func():
			sprite_2d.material = null
			
			if stats.health <= 0:
				Events.enemy_died.emit(self)
				queue_free()
	)


func gain_block(block: int, which_modifier: Modifier.Type) -> void:
	var modified_block := modifier_handler.get_modified_value(block, which_modifier)
	stats.block += modified_block


func _setup_hover_timer() -> void:
	hover_timer = Timer.new()
	hover_timer.wait_time = HOVER_DELAY
	hover_timer.one_shot = true
	hover_timer.timeout.connect(_on_hover_timer_timeout)
	add_child(hover_timer)


func _on_hover_timer_timeout() -> void:
	if stats:
		is_showing_tooltip = true
		Events.enemy_tooltip_requested.emit(stats.art, stats.enemy_name, stats.intent_icons, stats.intent_descriptions)


func _show_tooltip_immediately() -> void:
	if hover_timer:
		hover_timer.stop()
	if stats:
		is_showing_tooltip = true
		Events.enemy_tooltip_requested.emit(stats.art, stats.enemy_name, stats.intent_icons, stats.intent_descriptions)


func _on_enemy_hovered(enemy: Enemy) -> void:
	# Another enemy is being hovered
	if enemy != self:
		# Stop our timer if it's running
		if hover_timer and not hover_timer.is_stopped():
			hover_timer.stop()
		
		# Hide our tooltip if it's showing
		if is_showing_tooltip:
			is_showing_tooltip = false
			Events.tooltip_hide_requested.emit()


func _on_mouse_entered() -> void:
	# Notify all enemies that this one is being hovered
	Events.enemy_hovered.emit(self)
	
	# Check if any tooltip is currently visible
	var any_tooltip_showing := false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Enemy and enemy.is_showing_tooltip:
			any_tooltip_showing = true
			break
	
	# If a tooltip is already showing, show ours immediately
	if any_tooltip_showing:
		_show_tooltip_immediately()
	else:
		# Otherwise, start the hover timer
		if hover_timer:
			hover_timer.start()


func _on_mouse_exited() -> void:
	# Stop the timer if it's running
	if hover_timer and not hover_timer.is_stopped():
		hover_timer.stop()
	
	# Hide tooltip if it's showing
	if is_showing_tooltip:
		is_showing_tooltip = false
		Events.tooltip_hide_requested.emit()


func _on_area_entered(_area: Area2D) -> void:
	arrow.show()


func _on_area_exited(_area: Area2D) -> void:
	arrow.hide()


# --- model / animation helpers -------------------------------------------

func _get_model_node():
	# return first meaningful child (placeholder or real model)
	if model_3d.get_child_count() > 0:
		return model_3d.get_child(0)
	return null


func _find_animation_player(model_node):
	if not model_node:
		return null
	# try direct child first
	var ap = model_node.get_node_or_null("AnimationPlayer")
	if ap:
		return ap
	# search recursively for AnimationPlayer (works if nested)
	var found = model_node.find_node("AnimationPlayer", true, false)
	return found as AnimationPlayer


func _setup_model_animation() -> void:
	var model_node = _get_model_node()
	var anim = _find_animation_player(model_node)
	if anim:
		# ensure Idle plays by default if available
		if anim.has_animation("Idle"):
			anim.play("Idle")
	else:
		push_warning("No AnimationPlayer found on model.")


# public helpers to trigger animations ------------------------------------

func play_idle() -> void:
	var model_node = _get_model_node()
	var anim = _find_animation_player(model_node)
	if not anim:
		push_warning("Can't play idle – no AnimationPlayer found.")
		return
	if anim.has_animation("Idle"):
		anim.play("Idle")
	else:
		push_warning("No 'Idle' animation found; falling back to Idle.")
		if anim.has_animation("Idle"):
			anim.play("Idle")

func play_attack() -> void:
	var model_node = _get_model_node()
	var anim = _find_animation_player(model_node)
	if not anim:
		push_warning("Can't play attack – no AnimationPlayer found.")
		return
	if anim.has_animation("Attack"):
		anim.play("Attack")
	elif anim.has_animation("Attacking"):
		anim.play("Attacking")
	else:
		push_warning("No 'Attacking' animation found; falling back to Idle.")
		if anim.has_animation("Idle"):
			anim.play("Idle")


func play_casting() -> void:
	var model_node = _get_model_node()
	var anim = _find_animation_player(model_node)
	if not anim:
		push_warning("Can't play casting – no AnimationPlayer found.")
		return
	if anim.has_animation("Casting"):
		anim.play("Casting")
	else:
		push_warning("No 'Casting' animation found; falling back to Idle.")
		if anim.has_animation("Idle"):
			anim.play("Idle")


func play_hurt() -> void:
	var model_node = _get_model_node()
	var anim = _find_animation_player(model_node)
	if not anim:
		push_warning("Can't play hurt – no AnimationPlayer found.")
		return
	if anim.has_animation("Hurt"):
		anim.play("Hurt")
	else:
		push_warning("No 'Hurt' animation found; falling back to Idle.")
		if anim.has_animation("Idle"):
			anim.play("Idle")


func _ready() -> void:
	if not Engine.is_editor_hint():
		_replace_editor_placeholder_with_model()
	
	play_idle()
	
	_setup_hover_timer()
	status_handler.status_owner = self
	
	# Connect mouse signals for tooltip hovering
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Listen for other enemies being hovered
	Events.enemy_hovered.connect(_on_enemy_hovered)
