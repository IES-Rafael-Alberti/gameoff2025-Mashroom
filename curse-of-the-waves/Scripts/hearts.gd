extends HBoxContainer

@export var full_hp_icon: CompressedTexture2D
@export var empty_hp_icon: CompressedTexture2D


func update_icons(hp: int) -> void:
	for i in range(1, 4):
		get_node("H" + str(i)).texture = full_hp_icon if hp >= i else empty_hp_icon
	if hp >= 4:
		get_node("H4").texture = full_hp_icon
		get_node("H0").custom_minimum_size = Vector2(0, 0)
	else:
		get_node("H4").texture = null
		get_node("H0").custom_minimum_size = get_node("H1").custom_minimum_size
