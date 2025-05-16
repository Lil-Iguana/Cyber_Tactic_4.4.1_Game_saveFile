class_name BlockEffect
extends Effect

var amount := 0
var receiver_modifier_type := Modifier.Type.BLOCK_GAINED


func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Enemy or target is Player:
			target.gain_block(amount, receiver_modifier_type)
			SFXPlayer.play(sound)
