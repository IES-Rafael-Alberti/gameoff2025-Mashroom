extends Area2D


@export var speed: float = 200.0  # Velocidad a la que se mueve el obstáculo

func _process(delta):
	position.x -= speed * delta  # Para que se mueva el obstáculo hacia la izquierda

	# Si sale fuera de pantalla, borramos el obstáculo
	if position.x < -100:
		queue_free()
