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

# ── Session tracking ──────────────────────────────────────────────────────────
# Filled by _generate_shop_*() and restore_from_save().
# Read by Run._save_run() via the public getters below to persist shop state.
var _card_ids: Array[String]   = []
var _card_prices: Array[int]   = []
var _sold_card_ids: Array[String] = []
var _thread_ids: Array[String] = []
var _thread_prices: Array[int] = []
var _sold_thread_ids: Array[String] = []


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


# ── Public population API ─────────────────────────────────────────────────────

func populate_shop() -> void:
	_generate_shop_cards()
	_generate_shop_threads()


# Restores a shop session from a saved state instead of re-running RNG
# generation.  Produces the same items and prices as the original visit and
# marks previously purchased items as sold-out.
func restore_from_save(
		card_ids: Array[String],   card_prices: Array[int],   sold_card_ids: Array[String],
		thread_ids: Array[String], thread_prices: Array[int], sold_thread_ids: Array[String]
) -> void:
	# Restore internal tracking so subsequent saves capture the correct state.
	_card_ids         = card_ids.duplicate()
	_card_prices      = card_prices.duplicate()
	_sold_card_ids    = sold_card_ids.duplicate()
	_thread_ids       = thread_ids.duplicate()
	_thread_prices    = thread_prices.duplicate()
	_sold_thread_ids  = sold_thread_ids.duplicate()
	
	# ── Restore cards ─────────────────────────────────────────────────────────
	for i: int in card_ids.size():
		var card := _find_card_by_id(card_ids[i])
		if not card:
			push_warning("Shop restore: card id '%s' not found in draftable_cards" % card_ids[i])
			continue
		
		var shop_card := SHOP_CARD.instantiate() as ShopCard
		# Saved prices are BASE prices (pre-modifier). Apply the modifier now
		# so the correct discounted price shows — whether or not the discount
		# thread was already owned or was bought during this visit.
		if i < card_prices.size():
			shop_card.gold_cost = _get_updated_shop_cost(card_prices[i])
		cards.add_child(shop_card)
		shop_card.card = card
		shop_card.current_card_ui.tooltip_requested.connect(card_tooltip_popup.show_tooltip)
		shop_card.update(run_stats)
		
		if card_ids[i] in sold_card_ids:
			shop_card.mark_as_sold()
	
	# ── Restore threads ───────────────────────────────────────────────────────
	for i: int in thread_ids.size():
		var thread := _find_thread_by_id(thread_ids[i])
		if not thread:
			push_warning("Shop restore: thread id '%s' not found in shop_threads" % thread_ids[i])
			continue
		
		var shop_thread := SHOP_THREAD.instantiate() as ShopThread
		# Same as cards: saved prices are BASE prices, apply modifier on restore.
		if i < thread_prices.size():
			shop_thread.gold_cost = _get_updated_shop_cost(thread_prices[i])
		threads.add_child(shop_thread)
		shop_thread.thread = thread
		shop_thread.update(run_stats)
		
		if thread_ids[i] in sold_thread_ids:
			shop_thread.mark_as_sold()


# ── State getters (called by Run._save_run()) ─────────────────────────────────

func get_card_ids()        -> Array[String]: return _card_ids
func get_card_prices()     -> Array[int]:    return _card_prices
func get_sold_card_ids()   -> Array[String]: return _sold_card_ids
func get_thread_ids()      -> Array[String]: return _thread_ids
func get_thread_prices()   -> Array[int]:    return _thread_prices
func get_sold_thread_ids() -> Array[String]: return _sold_thread_ids


# ── Private helpers ───────────────────────────────────────────────────────────

func _blink_timer_setup() -> void:
	blink_timer.wait_time = randf_range(1.0, 5.0)
	blink_timer.start()


func _generate_shop_cards() -> void:
	_card_ids.clear()
	_card_prices.clear()
	
	var available_cards: Array[Card] = char_stats.draftable_cards.duplicate_cards()
	RNG.array_shuffle(available_cards)
	var shop_card_array: Array[Card] = available_cards.slice(0, 4)
	
	for card: Card in shop_card_array:
		var shop_card := SHOP_CARD.instantiate() as ShopCard
		cards.add_child(shop_card)  # _ready() fires here, generates gold_cost from RNG
		shop_card.card = card
		shop_card.current_card_ui.tooltip_requested.connect(card_tooltip_popup.show_tooltip)
		
		# Save the BASE price (before any modifier) so restore_from_save() can
		# always re-apply the modifier cleanly via _get_updated_shop_cost().
		_card_ids.append(card.id)
		_card_prices.append(shop_card.gold_cost)
		
		shop_card.gold_cost = _get_updated_shop_cost(shop_card.gold_cost)
		shop_card.update(run_stats)


func _generate_shop_threads() -> void:
	_thread_ids.clear()
	_thread_prices.clear()
	
	var available_threads := shop_threads.filter(
		func(thread: ThreadPassive):
			var can_appear    := thread.can_appear_as_reward(char_stats)
			var already_had_it := thread_handler.has_thread(thread.id)
			return can_appear and not already_had_it
	)
	
	RNG.array_shuffle(available_threads)
	var shop_threads_array: Array[ThreadPassive] = available_threads.slice(0, 4)
	
	for thread: ThreadPassive in shop_threads_array:
		var shop_thread := SHOP_THREAD.instantiate() as ShopThread
		threads.add_child(shop_thread)  # _ready() fires here, generates gold_cost from RNG
		shop_thread.thread = thread
		
		# Save the BASE price (before any modifier) so restore_from_save() can
		# always re-apply the modifier cleanly via _get_updated_shop_cost().
		_thread_ids.append(thread.id)
		_thread_prices.append(shop_thread.gold_cost)
		
		shop_thread.gold_cost = _get_updated_shop_cost(shop_thread.gold_cost)
		shop_thread.update(run_stats)


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


func _find_card_by_id(id: String) -> Card:
	for card: Card in char_stats.draftable_cards.cards:
		if card.id == id:
			return card
	return null


func _find_thread_by_id(id: String) -> ThreadPassive:
	for thread: ThreadPassive in shop_threads:
		if thread.id == id:
			return thread
	return null


# ── Event handlers ────────────────────────────────────────────────────────────

func _on_back_button_pressed() -> void:
	Events.shop_exited.emit()


func _on_shop_card_bought(card: Card, gold_cost: int) -> void:
	char_stats.deck.add_card(card)
	run_stats.gold -= gold_cost
	# Track the purchase so it survives a save/load within this shop visit.
	_sold_card_ids.append(card.id)
	_update_items()


func _on_shop_thread_bought(thread: ThreadPassive, gold_cost: int) -> void:
	thread_handler.add_thread(thread)
	run_stats.gold -= gold_cost
	# Track the purchase so it survives a save/load within this shop visit.
	_sold_thread_ids.append(thread.id)
	
	if thread is CouponsThread:
		var coupons_thread := thread as CouponsThread
		coupons_thread.add_shop_modifier(self)
		_update_item_costs()
	else:
		_update_items()


func _on_blink_timer_timeout() -> void:
	shop_keeper_animation.play("blink")
	_blink_timer_setup()
