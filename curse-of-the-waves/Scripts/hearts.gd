extends HBoxContainer

@export var full_hp_icon: CompressedTexture2D
@export var empty_hp_icon: CompressedTexture2D


func update_icons(hp: int):
	for i in range(1, 4):
		get_node("H" + str(i)).texture = full_hp_icon if hp >= i else empty_hp_icon
