class_name Player
extends Node2D

const WHITE_SPRITE_MATERIAL := preload("res://art/white_sprite_material.tres")

@export var stats: CharacterStats : set = set_character_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var stats_ui: StatsUI = $StatsUI
@onready var status_handler: StatusHandler = $StatusHandler
@onready var modifier_handler: ModifierHandler = $ModifierHandler
@onready var model_3d: SubViewport = $SubViewportContainer/SubViewport
@onready var model_3d_flash: Control = $SubViewportContainer


func _replace_editor_placeholder_with_model() -> void:
	if model_3d.has_node("StudentMExp"):
		model_3d.get_node("StudentMExp").queue_free()
	
	if stats and stats.model:
		var real_model_3d = stats.model.instantiate()
		model_3d.add_child(real_model_3d)


func _ready() -> void:
	status_handler.status_owner = self


func set_character_stats(value: CharacterStats) -> void:
	stats = value
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
	
	update_player()


func update_player() -> void:
	if not stats is CharacterStats:
		return
	if not is_inside_tree():
		await ready
	
	sprite_2d.texture = stats.art
	update_stats()


func update_stats() -> void:
	stats_ui.update_stats(stats)


func gain_block(block: int, which_modifier: Modifier.Type) -> void:
	var modified_block := modifier_handler.get_modified_value(block, which_modifier)
	stats.block += modified_block
	Events.player_gain_block.emit()


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
				Events.player_died.emit()
				queue_free()
	)


func take_pure_damage(damage: int, which_modifier: Modifier.Type) -> void:
	if stats.health <= 0:
		return
	
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	model_3d_flash.material = WHITE_SPRITE_MATERIAL
	var modified_damage := modifier_handler.get_modified_value(damage, which_modifier)
	
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(stats.take_pure_damage.bind(modified_damage))
	tween.tween_interval(0.17)
	play_hurt_animation()
	
	tween.finished.connect(
		func():
			sprite_2d.material = null
			model_3d_flash.material = null
			play_idle_animation()
			
			if stats.health <= 0:
				Events.player_died.emit(self)
				queue_free()
	)


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
