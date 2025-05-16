extends Node

# Card-related events
@warning_ignore("unused_signal")
signal card_drag_started(card_ui: CardUI)
@warning_ignore("unused_signal")
signal card_drag_ended(card_ui: CardUI)
@warning_ignore("unused_signal")
signal card_aim_started(card_ui: CardUI)
@warning_ignore("unused_signal")
signal card_aim_ended(card_ui: CardUI)
@warning_ignore("unused_signal")
signal card_played(card: Card)
@warning_ignore("unused_signal")
signal card_tooltip_requested(card: Card)
@warning_ignore("unused_signal")
signal card_chosen(card: Card)
@warning_ignore("unused_signal")
signal tooltip_hide_requested

# Player-related events
@warning_ignore("unused_signal")
signal player_card_drawn
@warning_ignore("unused_signal")
signal player_multiple_cards_drawn
@warning_ignore("unused_signal")
signal player_hand_drawn
@warning_ignore("unused_signal")
signal player_hand_discarded
@warning_ignore("unused_signal")
signal player_turn_ended
@warning_ignore("unused_signal")
signal player_hit
@warning_ignore("unused_signal")
signal player_gain_block
@warning_ignore("unused_signal")
signal player_died

# Enemy related events
@warning_ignore("unused_signal")
signal enemy_action_completed(enemy: Enemy)
@warning_ignore("unused_signal")
signal enemy_turn_ended
@warning_ignore("unused_signal")
signal enemy_died(enemy: Enemy)
@warning_ignore("unused_signal")
signal enemy_tooltip_requested(enemy: Stats)

# Battle-related events
@warning_ignore("unused_signal")
signal battle_over_screen_requested(text: String, type: BattleOverPanel.Type)
@warning_ignore("unused_signal")
signal battle_won
@warning_ignore("unused_signal")
signal status_tooltip_requested(statuses: Array[Status])

# Map-related events
@warning_ignore("unused_signal")
signal map_exited

# Shop-related events
@warning_ignore("unused_signal")
signal shop_entered(room: Room)
@warning_ignore("unused_signal")
signal shop_thread_bought(thread: ThreadPassive, gold_cost: int)
@warning_ignore("unused_signal")
signal shop_card_bought(card: Card, gold_cost: int)
@warning_ignore("unused_signal")
signal shop_exited

# Campfire-related events
@warning_ignore("unused_signal")
signal campfire_exited

# Battle Reward-related events
@warning_ignore("unused_signal")
signal battle_reward_exited

# Treasure Room-related events
@warning_ignore("unused_signal")
signal treasure_room_exited(found_thread: ThreadPassive)

# Thread-related events
@warning_ignore("unused_signal")
signal thread_tooltip_requested(thread: ThreadPassive)

# Bestiary-related events
@warning_ignore("unused_signal")
signal bestiary_exited
