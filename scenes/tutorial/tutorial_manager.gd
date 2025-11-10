class_name TutorialManager
extends Node

signal tutorial_started
signal tutorial_completed
signal step_changed(step_index: int)

@export var steps: Array[TutorialStep] = []
@export var tutorial_key: String = ""  # Key for DialogueState
@export var overlay_scene: PackedScene = preload("res://scenes/tutorial/tutorial_overlay.tscn")
@export var narration_scene: PackedScene = preload("res://scenes/tutorial/tutorial_narration.tscn")

var current_step_index: int = -1
var is_active: bool = false
var overlay: TutorialOverlay
var narration: TutorialNarration
var battle_node: Node
var auto_advance_timer: Timer


func _ready() -> void:
	# Don't start automatically, wait for explicit start_tutorial() call
	pass


func start_tutorial() -> void:
	# Check if tutorial was already shown - if so, clean up and exit immediately
	if tutorial_key != "" and DialogueState.has_shown(tutorial_key):
		print("Tutorial '%s' already completed, skipping..." % tutorial_key)
		queue_free()
		return
	
	print("Starting tutorial: '%s'" % tutorial_key)
	is_active = true
	
	# Find battle node
	battle_node = get_parent()
	
	# Setup overlay
	overlay = overlay_scene.instantiate()
	battle_node.add_child(overlay)
	overlay.show_overlay()
	
	# Setup narration
	narration = narration_scene.instantiate()
	overlay.add_child(narration)
	
	# Setup auto advance timer
	auto_advance_timer = Timer.new()
	auto_advance_timer.one_shot = true
	auto_advance_timer.timeout.connect(_on_auto_advance_timeout)
	add_child(auto_advance_timer)
	
	# Connect to game events
	_connect_events()
	
	emit_signal("tutorial_started")
	
	# Start first step
	await get_tree().create_timer(0.5).timeout
	_advance_to_next_step()


func _connect_events() -> void:
	Events.card_played.connect(_on_card_played)
	Events.player_press_end_turn_button.connect(_on_end_turn_pressed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)


func _disconnect_events() -> void:
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)
	if Events.player_press_end_turn_button.is_connected(_on_end_turn_pressed):
		Events.player_press_end_turn_button.disconnect(_on_end_turn_pressed)
	if Events.enemy_turn_ended.is_connected(_on_enemy_turn_ended):
		Events.enemy_turn_ended.disconnect(_on_enemy_turn_ended)


func _advance_to_next_step() -> void:
	current_step_index += 1
	
	if current_step_index >= steps.size():
		_complete_tutorial()
		return
	
	var step := steps[current_step_index]
	emit_signal("step_changed", current_step_index)
	_execute_step(step)


func _execute_step(step: TutorialStep) -> void:
	# Show narration
	if step.narration_text != "":
		narration.show_narration(step.narration_text)
	
	# Handle highlighting
	if step.highlight_node_path != "":
		var node := battle_node.get_node_or_null(step.highlight_node_path)
		if node and node is Control:
			overlay.highlight_node(node as Control)
			
			# Show drag arrow if requested
			if step.show_drag_arrow:
				var node_rect := (node as Control).get_global_rect()
				var start_pos := node_rect.get_center()
				overlay.call("show_drag_pointer", start_pos, step.drag_arrow_end_pos)
			
			# Check if this step requires card interaction
			var is_card_play_step := (step.action_type == TutorialStep.ActionType.PLAY_CARD or 
									  step.action_type == TutorialStep.ActionType.PLAY_CARD_TYPE)
			
			if is_card_play_step:
				# Allow card interactions - DON'T block input at overlay level
				overlay.allow_all_input()  # This disables _input() blocking
				# Only disable non-card UI buttons
				_disable_non_card_ui()
				print("TutorialManager: Step %d allows card interaction" % current_step_index)
			else:
				# Block all input except the highlighted element
				overlay.block_input_except_node(node as Control)
				_block_all_except_highlighted(node as Control)
		else:
			push_warning("TutorialManager: Could not find node at path: " + step.highlight_node_path)
	else:
		overlay.clear_highlight()
		if step.block_all_except_highlight:
			overlay.block_input_except_node(null)
		else:
			overlay.allow_all_input()
			_enable_all_inputs()
	
	# Handle auto-advance
	if step.auto_advance_delay > 0.0 and step.action_type == TutorialStep.ActionType.NONE:
		auto_advance_timer.start(step.auto_advance_delay)
	
	# Handle action-based advancement
	match step.action_type:
		TutorialStep.ActionType.NONE:
			if step.auto_advance_delay <= 0.0:
				# No action required and no auto advance, this shouldn't happen
				push_warning("TutorialManager: Step has no action and no auto advance")
				_advance_to_next_step()
		TutorialStep.ActionType.WAIT_SIGNAL:
			if step.wait_signal_name != "":
				_connect_to_custom_signal(step.wait_signal_name)


func _disable_non_card_ui() -> void:
	# Disable end turn button
	var end_turn_button := battle_node.get_node_or_null("BattleUI/EndTurnButton")
	if end_turn_button and end_turn_button is Button:
		end_turn_button.disabled = true
	
	# Disable draw/discard pile buttons
	var draw_button := battle_node.get_node_or_null("BattleUI/DrawPileButton")
	if draw_button and draw_button is Button:
		draw_button.disabled = true
	
	var discard_button := battle_node.get_node_or_null("BattleUI/DiscardPileButton")
	if discard_button and discard_button is Button:
		discard_button.disabled = true
	
	# Keep hand enabled for card interaction


func _block_all_except_highlighted(allowed_node: Control) -> void:
	# Disable end turn button if not highlighted
	var end_turn_btn := battle_node.get_node_or_null("BattleUI/EndTurnButton")
	if end_turn_btn and end_turn_btn != allowed_node:
		if end_turn_btn is Button:
			end_turn_btn.disabled = true
	
	# Disable hand cards ONLY if hand is NOT the highlighted node
	var hand_node := battle_node.get_node_or_null("BattleUI/Hand")
	if hand_node:
		var current_step := steps[current_step_index]
		# Only disable hand if we're NOT waiting for card play and hand is NOT highlighted
		if current_step.action_type != TutorialStep.ActionType.PLAY_CARD and \
		   current_step.action_type != TutorialStep.ActionType.PLAY_CARD_TYPE and \
		   hand_node != allowed_node:
			_disable_hand(hand_node)
	
	# Disable draw/discard pile buttons if not highlighted
	var draw_btn := battle_node.get_node_or_null("BattleUI/DrawPileButton")
	if draw_btn and draw_btn != allowed_node:
		if draw_btn is Button:
			draw_btn.disabled = true
	
	var discard_btn := battle_node.get_node_or_null("BattleUI/DiscardPileButton")
	if discard_btn and discard_btn != allowed_node:
		if discard_btn is Button:
			discard_btn.disabled = true

	# Disable end turn button if not highlighted
	var end_turn_button := battle_node.get_node_or_null("BattleUI/EndTurnButton")
	if end_turn_button and end_turn_button != allowed_node:
		if end_turn_button is Button:
			end_turn_button.disabled = true
	
	# Disable hand cards ONLY if hand is NOT the highlighted node
	var hand := battle_node.get_node_or_null("BattleUI/Hand")
	if hand:
		var current_step := steps[current_step_index]
		# Only disable hand if we're NOT waiting for card play and hand is NOT highlighted
		if current_step.action_type != TutorialStep.ActionType.PLAY_CARD and \
		   current_step.action_type != TutorialStep.ActionType.PLAY_CARD_TYPE and \
		   hand != allowed_node:
			_disable_hand(hand)
	
	# Disable draw/discard pile buttons if not highlighted
	var draw_button := battle_node.get_node_or_null("BattleUI/DrawPileButton")
	if draw_button and draw_button != allowed_node:
		if draw_button is Button:
			draw_button.disabled = true
	
	var discard_button := battle_node.get_node_or_null("BattleUI/DiscardPileButton")
	if discard_button and discard_button != allowed_node:
		if discard_button is Button:
			discard_button.disabled = true


func _enable_all_inputs() -> void:
	overlay.allow_all_input()
	
	# Re-enable end turn button
	var end_turn_button := battle_node.get_node_or_null("BattleUI/EndTurnButton")
	if end_turn_button and end_turn_button is Button:
		end_turn_button.disabled = false
	
	# Re-enable hand
	var hand := battle_node.get_node_or_null("BattleUI/Hand")
	if hand:
		_enable_hand(hand)
	
	# Re-enable pile buttons
	var draw_button := battle_node.get_node_or_null("BattleUI/DrawPileButton")
	if draw_button and draw_button is Button:
		draw_button.disabled = false
	
	var discard_button := battle_node.get_node_or_null("BattleUI/DiscardPileButton")
	if discard_button and discard_button is Button:
		discard_button.disabled = false


func _disable_hand(hand: Node) -> void:
	for card_ui in hand.get_children():
		if card_ui.has_method("set_disabled"):
			card_ui.call("set_disabled", true)
		elif "disabled" in card_ui:
			card_ui.disabled = true


func _enable_hand(hand: Node) -> void:
	for card_ui in hand.get_children():
		if card_ui.has_method("set_disabled"):
			card_ui.call("set_disabled", false)
		elif "disabled" in card_ui:
			card_ui.disabled = false


func _connect_to_custom_signal(signal_name: String) -> void:
	if Events.has_signal(signal_name):
		Events.connect(signal_name, _on_custom_signal_received.bind(signal_name), CONNECT_ONE_SHOT)
	else:
		push_warning("TutorialManager: Signal not found: " + signal_name)
		_advance_to_next_step()


func _on_custom_signal_received(signal_name: String) -> void:
	var step := steps[current_step_index]
	if step.wait_signal_name == signal_name:
		await get_tree().create_timer(0.5).timeout
		_advance_to_next_step()


func _on_card_played(card: Card) -> void:
	if not is_active or current_step_index < 0:
		return
	
	var step := steps[current_step_index]
	
	match step.action_type:
		TutorialStep.ActionType.PLAY_CARD:
			await get_tree().create_timer(0.5).timeout
			_advance_to_next_step()
		
		TutorialStep.ActionType.PLAY_CARD_TYPE:
			if card.type == step.card_type_required:
				await get_tree().create_timer(0.5).timeout
				_advance_to_next_step()


func _on_end_turn_pressed() -> void:
	if not is_active or current_step_index < 0:
		return
	
	var step := steps[current_step_index]
	
	if step.action_type == TutorialStep.ActionType.END_TURN:
		await get_tree().create_timer(0.3).timeout
		_advance_to_next_step()


func _on_enemy_turn_ended() -> void:
	if not is_active or current_step_index < 0:
		return
	
	var step := steps[current_step_index]
	
	if step.action_type == TutorialStep.ActionType.WAIT_ENEMY_TURN:
		await get_tree().create_timer(0.5).timeout
		_advance_to_next_step()


func _on_auto_advance_timeout() -> void:
	_advance_to_next_step()


func _complete_tutorial() -> void:
	is_active = false
	
	# Mark as shown in DialogueState - CRITICAL for preventing repeats
	if tutorial_key != "":
		DialogueState.mark_shown(tutorial_key)
		print("Tutorial '%s' completed and saved!" % tutorial_key)
	
	# Clean up
	_enable_all_inputs()
	_disconnect_events()
	
	if narration:
		narration.hide_narration()
		await narration.narration_finished
	
	if overlay:
		overlay.hide_overlay()
		await get_tree().create_timer(0.3).timeout
		overlay.queue_free()
	
	emit_signal("tutorial_completed")
	
	# Remove self
	queue_free()


func skip_tutorial() -> void:
	if tutorial_key != "":
		DialogueState.mark_shown(tutorial_key)
	
	_enable_all_inputs()
	_disconnect_events()
	
	if overlay:
		overlay.queue_free()
	if narration:
		narration.queue_free()
	
	queue_free()
