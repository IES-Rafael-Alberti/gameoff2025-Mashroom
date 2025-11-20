extends HBoxContainer

@export var fullHpIcon: CompressedTexture2D
@export var emptyHpIcon: CompressedTexture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func updateIcons(hp: int):
	if hp > 1:
		$H1.texture = fullHpIcon
	pass
