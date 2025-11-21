extends CharacterBody2D

@export_group("Basics")
@export var BaseSpeed = 800.0

@onready var sonidoCaida = preload("res://assets/Audio/SFX/Minijuego surf/efectoSplash.wav")
@onready var anims = $Sprite2D
@onready var sonidoGolpe = preload("res://assets/Audio/SFX/Minijuego surf/sonidoGolpe.wav")

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
		
		if updHp(-1) <= 0:
			death()
		else:
			damage()

func updHp(add: int):
	var GameManager = get_tree().get_root().get_node("Main/GameManager")
	var newHp = GameManager.health + add
	GameManager.HpUpdate(newHp)
	return newHp

func damage():
	AudioPlayer.playSfx(sonidoGolpe)
	anims.play("damaged")
	canBeDamaged = false
	canMove = false
	await get_tree().create_timer(0.2).timeout
	canMove = true
	await anims.animation_finished
	canBeDamaged = true
	anims.play("default")
	

func death(): # Proceso de Muerte
	AudioPlayer.playSfx(sonidoGolpe)
	canMove = false
	canBeDamaged = false
	anims.play("death")
	await get_tree().create_timer(0.998).timeout #para sfx de caida y que espere
	AudioPlayer.playSfx(sonidoCaida, -12.0)
	await anims.animation_finished
	# Temporal, para testeo
	if true:
		AudioPlayer.stopMusic()
		var GameManager = get_tree().get_root().get_node("Main/GameManager")
		GameManager.loadSceneDialogic(preload("res://Scenes/CaveMinigame/CaveGame.tscn"), '2-underwater_scene')
		
