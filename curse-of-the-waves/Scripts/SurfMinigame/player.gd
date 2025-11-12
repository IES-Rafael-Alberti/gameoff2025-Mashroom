extends CharacterBody2D

@export_group("Basics")
@export var Hp = 3
@export var Speed = 300.0

@onready var anims = $Sprite2D

var limitMin: float
var limitMax: float
var canMove = true
var canBeDamaged = true

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	if canMove:
		
		var direction = Input.get_axis("move_left", "move_right") # Player Movement
		if direction:
			velocity.x = direction * Speed
		else:
			velocity.x = move_toward(velocity.x, 0, Speed)

		move_and_slide()
		
		if position.x > limitMax: # Pone limites de movimiento
			position.x = limitMax
			velocity.x = 0
		elif position.x < limitMin:
			position.x = limitMin
			velocity.x = 0
			
		if velocity.x == 0:  # Pone animaciones segun su movimiento
			anims.play("default")
		elif velocity.x > 0:
			anims.play("turning_right")
		elif velocity.x < 0:
			anims.play("turning_left")
	
func _on_hitbox_area_entered(body): # Detección al tocar un obstaculo (tiene que ser Area2D)
	if body.is_in_group("Damage") and canBeDamaged:
		death()
		body.queue_free()

func death(): # Proceso de Muerte
	canMove = false
	canBeDamaged = false
	if randi_range(0,1) == 1: # 50% de flipear la death anim para dar variedad
		anims.flip_h = true
	anims.play("death")
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
