extends CharacterBody2D

@export_group("Basics")
@export var Hp = 3
@export var BaseSpeed = 800.0

@onready var anims = $Sprite2D
@onready var heart_textures = {
	"full": preload("res://assets/SurfMinigame/Heart.png"),
	"broken": preload("res://assets/SurfMinigame/Broken-heart.png")
}

var speed = BaseSpeed
var limitMin: float
var limitMax: float
var canMove = true
var canBeDamaged = true
func _process(delta):
	salud_ctrl()
	
func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	if canMove:
		
		var direction = Input.get_axis("move_left", "move_right") # Player Movement
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

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
		body.queue_free()
		
		Hp -= 1
		if Hp <= 0:
			death()
		

func death(): # Proceso de Muerte
	canMove = false
	canBeDamaged = false
	if randi_range(0,1) == 1: # 50% de flipear la death anim para dar variedad
		anims.flip_h = true
	anims.play("death")
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
	
func salud_ctrl():
	if Hp == 3:
		$Life/Heart.texture = heart_textures["full"]
		$Life/Heart2.texture = heart_textures["full"]
		$Life/Heart3.texture = heart_textures["full"]
	elif Hp == 2:
		$Life/Heart.texture = heart_textures["full"]
		$Life/Heart2.texture = heart_textures["full"]
		$Life/Heart3.texture = heart_textures["broken"]
	elif Hp == 1:
		$Life/Heart.texture = heart_textures["full"]
		$Life/Heart2.texture = heart_textures["broken"]
		$Life/Heart3.texture = heart_textures["broken"]
	elif Hp <= 0:
		$Life/Heart.texture = heart_textures["broken"]
		$Life/Heart2.texture = heart_textures["broken"]
		$Life/Heart3.texture = heart_textures["broken"]
