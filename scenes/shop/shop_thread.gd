class_name ShopThread
extends VBoxContainer

const THREAD_UI = preload("res://scenes/thread_handler/thread_ui.tscn")

@export var thread: ThreadPassive : set = set_thread

@onready var thread_container: CenterContainer = %ThreadContainer
@onready var price: HBoxContainer = %Price
@onready var price_label: Label = %PriceLabel
@onready var buy_button: Button = %BuyButton
@onready var gold_cost := RNG.instance.randi_range(100, 300)


func update(run_stats: RunStats) -> void:
	if not thread_container or not price or not buy_button:
		return
	
	price_label.text = str(gold_cost)
	
	if run_stats.gold >= gold_cost:
		price_label.remove_theme_color_override("font_color")
		buy_button.disabled = false
	else:
		price_label.add_theme_color_override("font_color", Color.RED)
		buy_button.disabled = true


func set_thread(new_thread: ThreadPassive) -> void:
	if not is_node_ready():
		await ready
	
	thread = new_thread
	
	for thread_ui: ThreadUI in thread_container.get_children():
		thread_ui.queue_free()
	
	var new_thread_ui := THREAD_UI.instantiate() as ThreadUI
	thread_container.add_child(new_thread_ui)
	new_thread_ui.thread_passive = thread


func _on_buy_button_pressed() -> void:
	Events.shop_thread_bought.emit(thread, gold_cost)
	thread_container.queue_free()
	price.queue_free()
	buy_button.queue_free()
