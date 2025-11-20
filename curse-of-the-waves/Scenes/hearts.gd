extends HBoxContainer

@export var fullHpIcon: CompressedTexture2D
@export var emptyHpIcon: CompressedTexture2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func updateIcons(hp: int):
	for i in range(1,4):
		get_node("H"+str(i)).texture = fullHpIcon if hp >= i else emptyHpIcon
