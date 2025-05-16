class_name Shop
extends Control

const SHOP_CARD = preload("res://scenes/shop/shop_card.tscn")
const SHOP_THREAD = preload("res://scenes/shop/shop_thread.tscn")

@export var shop_threads: Array[ThreadPassive]
@export var char_stats: CharacterStats
@export var run_stats: RunStats
@export var thread_handler: ThreadHandler

@onready var cards: HBoxContainer = %Cards
@onready var threads: HBoxContainer = %Threads
@onready var shop_keeper_animation: AnimationPlayer = %ShopkeeperAnimation
@onready var blink_timer: Timer = %BlinkTimer
@onready var card_tooltip_popup: CardTooltipPopup = %CardTooltipPopUp
@onready var modifier_handler: ModifierHandler = $ModifierHandler


func _ready() -> void:
	for shop_card: ShopCard in cards.get_children():
		shop_card.queue_free()
		
	for shop_thread: ShopThread in threads.get_children():
		shop_thread.queue_free()
	
	Events.shop_card_bought.connect(_on_shop_card_bought)
	Events.shop_thread_bought.connect(_on_shop_thread_bought)
	
	_blink_timer_setup()
	blink_timer.timeout.connect(_on_blink_timer_timeout)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and card_tooltip_popup.visible:
		card_tooltip_popup.hide_tooltip()


func populate_shop() -> void:
	_generate_shop_cards()
	_generate_shop_threads()


func _blink_timer_setup() -> void:
	blink_timer.wait_time = randf_range(1.0, 5.0)
	blink_timer.start()


func _generate_shop_cards() -> void:
	var shop_card_array: Array[Card] = []
	var available_cards : Array[Card] = char_stats.draftable_cards.duplicate_cards()
	RNG.array_shuffle(available_cards)
	shop_card_array = available_cards.slice(0, 3)
	
	for card: Card in shop_card_array:
		var new_shop_card := SHOP_CARD.instantiate() as ShopCard
		cards.add_child(new_shop_card)
		new_shop_card.card = card
		new_shop_card.current_card_ui.tooltip_requested.connect(card_tooltip_popup.show_tooltip)
		new_shop_card.gold_cost = _get_updated_shop_cost(new_shop_card.gold_cost)
		new_shop_card.update(run_stats)


func _generate_shop_threads() -> void:
	var shop_threads_array: Array[ThreadPassive] = []
	var available_threads := shop_threads.filter(
		func(thread: ThreadPassive):
			var can_appear := thread.can_appear_as_reward(char_stats)
			var already_had_it := thread_handler.has_thread(thread.id)
			return can_appear and not already_had_it
	)
	
	RNG.array_shuffle(available_threads)
	shop_threads_array = available_threads.slice(0, 3)
	
	for thread: ThreadPassive in shop_threads_array:
		var new_shop_thread := SHOP_THREAD.instantiate() as ShopThread
		threads.add_child(new_shop_thread)
		new_shop_thread.thread = thread
		new_shop_thread.gold_cost = _get_updated_shop_cost(new_shop_thread.gold_cost)
		new_shop_thread.update(run_stats)


func _update_items() -> void:
	for shop_card: ShopCard in cards.get_children():
		shop_card.update(run_stats)

	for shop_thread: ShopThread in threads.get_children():
		shop_thread.update(run_stats)


func _update_item_costs() -> void:
	for shop_card: ShopCard in cards.get_children():
		shop_card.gold_cost = _get_updated_shop_cost(shop_card.gold_cost)
		shop_card.update(run_stats)

	for shop_thread: ShopThread in threads.get_children():
		shop_thread.gold_cost = _get_updated_shop_cost(shop_thread.gold_cost)
		shop_thread.update(run_stats)



func _get_updated_shop_cost(original_cost: int) -> int:
	return modifier_handler.get_modified_value(original_cost, Modifier.Type.SHOP_COST)


func _on_back_button_pressed() -> void:
	Events.shop_exited.emit()


func _on_shop_card_bought(card: Card, gold_cost: int) -> void:
	char_stats.deck.add_card(card)
	run_stats.gold -= gold_cost
	_update_items()


func _on_shop_thread_bought(thread: ThreadPassive, gold_cost: int) -> void:
	thread_handler.add_thread(thread)
	run_stats.gold -= gold_cost
	
	if thread is CouponsThread:
		var coupons_thread := thread as CouponsThread
		coupons_thread.add_shop_modifier(self)
		_update_item_costs()
	else:
		_update_items()


func _on_blink_timer_timeout() -> void:
	shop_keeper_animation.play("blink")
	_blink_timer_setup()
