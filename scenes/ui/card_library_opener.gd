class_name CardLibraryOpener
extends TextureButton

@export var card_library: CardPile : set = set_card_library


func set_card_library(new_value: CardPile) -> void:
	card_library = new_value
