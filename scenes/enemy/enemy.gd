class_name Enemy
extends Area2D

const ARROW_OFFSET := 5
const WHITE_SPRITE_MATERIAL := preload("res://art/white_sprite_material.tres")

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
	play_hurt_animation()
	
	tween.finished.connect(
		func():
			sprite_2d.material = null
			model_3d_flash.material = null
			play_idle_animation()
			
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


func _on_area_entered(_area: Area2D) -> void:
	arrow.show()


func _on_area_exited(_area: Area2D) -> void:
	arrow.hide()


func play_idle_animation() -> void:
	if model_3d.get_child_count() > 0:
		var model_node = model_3d.get_child(0)
		if model_node.has_node("AnimationPlayer"):
			var anim = model_node.get_node("AnimationPlayer") as AnimationPlayer
			if anim.has_animation("Idle"):
				anim.play("Idle")


func play_hurt_animation() -> void:
	if model_3d.get_child_count() > 0:
		var model_node = model_3d.get_child(0)
		if model_node.has_node("AnimationPlayer"):
			var anim = model_node.get_node("AnimationPlayer") as AnimationPlayer
			if anim.has_animation("Hurt"):
				anim.play("Hurt")
			else:
				push_warning("No ‘Hurt’ on this AnimationPlayer!")
		else:
			push_warning("Model has no AnimationPlayer!")


func play_animation(animation_name: String) -> void:
	if model_3d.get_child_count() > 0:
		var model_node = model_3d.get_child(0)
		if model_node.has_node("AnimationPlayer"):
			var anim = model_node.get_node("AnimationPlayer") as AnimationPlayer
			if anim.has_animation(animation_name):
				anim.play(animation_name)
			else:
				push_warning("No animation named '%s' found!" % animation_name)
		else:
			push_warning("Model has no AnimationPlayer!")


func _ready() -> void:
	if not Engine.is_editor_hint():
		_replace_editor_placeholder_with_model()
	
	play_idle_animation()
	
	connect("input_event", Callable(self, "_on_input_event"))
	status_handler.status_owner = self


func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 2 and event.pressed:
			if stats:
				Events.enemy_tooltip_requested.emit(stats.art, stats.enemy_name, stats.intent_icons, stats.intent_descriptions)
