extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var name = "Obs"+str(randi_range(1,2))
	$Sprite2D.play(name)
