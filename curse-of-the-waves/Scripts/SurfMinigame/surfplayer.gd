extends CharacterBody2D

@export_group("Basics")
@export var Hp = 3
@export var BaseSpeed = 800.0

@onready var sonidoCaida = preload("res://assets/Audio/SFX/splash_effect.wav")
@onready var anims = $Sprite2D
@onready var heart_textures = {
	"full": preload("res://assets/GUI/Heart.png"),
	"broken": preload("res://assets/GUI/Broken-heart.png")
}

var speed = BaseSpeed
var limitMin: float
var limitMax: float
var canMove = true
var canBeDamaged = true

func _ready():
	AudioPlayer.musicMinijuegoSurf()

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
			
		if canBeDamaged:
			if velocity.x == 0:  # Pone animaciones segun su movimiento
				anims.play("default")
			elif velocity.x > 0:
				anims.play("turning_right")
			elif velocity.x < 0:
				anims.play("turning_left")
	
func _on_hitbox_area_entered(area): # Detección al tocar un obstaculo (tiene que ser Area2D)
	if area.is_in_group("Damage") and canBeDamaged:
		area.queue_free()
		
		Hp -= 1
		salud_ctrl()
		if Hp <= 0:
			death()
		else:
			anims.play("damaged")
			canBeDamaged = false
			canMove = false
			await get_tree().create_timer(0.2).timeout
			canMove = true
			await anims.animation_finished
			canBeDamaged = true
			anims.play("default")

func death(): # Proceso de Muerte
	canMove = false
	canBeDamaged = false
	anims.play("death")
	await get_tree().create_timer(0.999).timeout #para sfx de caida y que espere
	AudioPlayer.playSfx(sonidoCaida, -12.0)
	await anims.animation_finished
	# Temporal, para testeo
	if true:
		AudioPlayer.stopMusic()
		var GameManager = get_tree().get_root().get_node("Main/GameManager")
		GameManager.loadSceneDialogic(preload("res://Scenes/CaveMinigame/CaveGame.tscn"), '2-underwater_scene')
	
func salud_ctrl():
	match Hp:
		3:
			$Life/Heart.texture = heart_textures["full"]
			$Life/Heart2.texture = heart_textures["full"]
			$Life/Heart3.texture = heart_textures["full"]
			
		2:
			$Life/Heart.texture = heart_textures["full"]
			$Life/Heart2.texture = heart_textures["full"]
			$Life/Heart3.texture = heart_textures["broken"]
			
		1:
			$Life/Heart.texture = heart_textures["full"]
			$Life/Heart2.texture = heart_textures["broken"]
			$Life/Heart3.texture = heart_textures["broken"]
			
		0:
			$Life/Heart.texture = heart_textures["broken"]
			$Life/Heart2.texture = heart_textures["broken"]
			$Life/Heart3.texture = heart_textures["broken"]
