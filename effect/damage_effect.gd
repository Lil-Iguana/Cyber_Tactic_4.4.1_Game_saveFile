class_name DamageEffect
extends Effect

var amount := 0
var receiver_modifier_type := Modifier.Type.DMG_TAKEN
@export var element := Stats.Element.PHYSICAL


func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Enemy or target is Player:
			var elem_mult = target.stats.get_elemental_multiplier(element)
			var raw_damage = floor(amount * elem_mult)
			target.take_damage(raw_damage, receiver_modifier_type)
			SFXPlayer.play(sound)
