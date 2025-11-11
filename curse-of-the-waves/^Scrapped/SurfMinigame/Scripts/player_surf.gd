extends CharacterBody2D


@export var speed: float = 200.0
@export var limit_top: Marker2D
@export var limit_bottom: Marker2D

var top_pos: float
var bottom_pos: float

func _ready():
	top_pos = limit_top.position.y
	bottom_pos = limit_bottom.position.y 

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
	if position.y < top_pos:
		position.y = top_pos
	elif position.y > bottom_pos:
		position.y = bottom_pos
		
	zIndexHeight()
	

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		restart_game()
		
func restart_game():
	hide()
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func zIndexHeight():
	var new_zIndex = (position.y-top_pos) / (bottom_pos - top_pos) * 10
	$Sprite2D.z_index = new_zIndex + 1
