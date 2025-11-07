extends CharacterBody2D


@export var speed: float = 200.0
@export var limit_top: float = 350.0
@export var limit_bottom: float = 435.0

func _physics_process(delta):
	velocity.y = 0  # Reinicia el movimiento vertical cada frame

	# Controles: flechas o WASD
	if Input.is_action_pressed("move_down"):
		velocity.y += speed
	elif Input.is_action_pressed("move_up"):
		velocity.y -= speed

	# Aplica movimiento
	move_and_slide()

	# Limita la posición dentro del área jugable
	if position.y < limit_top:
		position.y = limit_top
	elif position.y > limit_bottom:
		position.y = limit_bottom
		
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		restart_game()
		
func restart_game():
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
