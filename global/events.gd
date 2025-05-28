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
signal drawpile_shuffled
@warning_ignore("unused_signal")
signal card_discarded # When rogue cards use a discard effect
@warning_ignore("unused_signal")
signal card_chosen(card: Card)
@warning_ignore("unused_signal")
signal tooltip_hide_requested
@warning_ignore("unused_signal")
signal card_returned_to_top_deck(card: Card)
@warning_ignore("unused_signal")
signal card_returned_to_bottom_deck(card: Card)
@warning_ignore("unused_signal")
signal card_type_found_in_hand(found: bool)
@warning_ignore("unused_signal")
signal card_removed


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
signal player_press_end_turn_button # Before the relics and statuses are applied
@warning_ignore("unused_signal")
signal player_turn_ended
@warning_ignore("unused_signal")
signal player_hit
@warning_ignore("unused_signal")
signal player_lose_life # When an effect makes you lose HP directly during your turn
@warning_ignore("unused_signal")
signal player_gain_block
@warning_ignore("unused_signal")
signal player_spend_spell
@warning_ignore("unused_signal")
signal player_gain_spell
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
@warning_ignore("unused_signal")
signal status_gained
@warning_ignore("unused_signal")
signal hand_choice_requested(reason: String) # Takes a string with the title of the hand choice view

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
@warning_ignore("unused_signal")
signal boss_reward_exited
@warning_ignore("unused_signal")
signal card_reward_skipped

# Treasure Room-related events
@warning_ignore("unused_signal")
signal treasure_room_exited(found_thread: ThreadPassive)

# Thread-related events
@warning_ignore("unused_signal")
signal thread_tooltip_requested(thread: ThreadPassive)
@warning_ignore("unused_signal")
signal start_of_turn_relics_activated
@warning_ignore("unused_signal")
signal end_of_turn_relics_activated

# Random Event room-related events
@warning_ignore("unused_signal")
signal event_room_exited

# Bestiary-related events
@warning_ignore("unused_signal")
signal bestiary_exited
