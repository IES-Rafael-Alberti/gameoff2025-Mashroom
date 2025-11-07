extends Area2D


@export var speed: float = 200.0  # Velocidad a la que se mueve el obstáculo

var top_pos: float
var bottom_pos: float

func _process(delta):
	position.x -= speed * delta  # Para que se mueva el obstáculo hacia la izquierda

	# Si sale fuera de pantalla, borramos el obstáculo
	if position.x < -100:
		queue_free()
		
	zIndexHeight()

func zIndexHeight():
	var new_zIndex = (position.y-top_pos) / (bottom_pos - top_pos) * 10
	$Sprite2D.z_index = new_zIndex + 1
