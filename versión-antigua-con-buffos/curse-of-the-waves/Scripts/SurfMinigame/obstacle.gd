extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Obstacle") # Añadimos al grupo de Obstacle para que funcione el buff de slow
	var name = "Obs"+str(randi_range(1,2))
	$Sprite2D.play(name)
	
