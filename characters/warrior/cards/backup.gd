extends Card

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var return_bottom_deck_effect := ReturnBottomDeckEffect.new()
	return_bottom_deck_effect.execute(targets)
	
	await Events.card_returned_to_bottom_deck
	
	var player = targets[0] as Player
	var last_card: Card = player.stats.draw_pile.cards[-1]
	last_card.cost = 0
	SFXPlayer.play(sound)
