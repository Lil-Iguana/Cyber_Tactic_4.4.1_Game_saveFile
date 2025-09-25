extends Card

const ANTIVIRUS_STATUS := preload("res://statuses/antivirus.tres")

var stacks := 4

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler):
	SFXPlayer.play(sound)
	var status_effect := StatusEffect.new()
	var antivirus := ANTIVIRUS_STATUS.duplicate()
	antivirus.stacks = stacks
	status_effect.status = antivirus
	status_effect.execute(targets)
