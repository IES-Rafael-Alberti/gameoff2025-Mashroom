extends CharacterBody2D

@export_group("Basics")
@export var base_speed = 800.0

@onready var sonido_caida = preload("res://assets/Audio/SFX/Minijuego surf/efectoSplash.wav")
@onready var anims = $Sprite2D
@onready var sonido_golpe = preload("res://assets/Audio/SFX/Minijuego surf/sonidoGolpe.wav")

var speed = base_speed
var limit_min: float
var limit_max: float
var can_move = true
var can_be_damaged = true


func _ready():
	AudioPlayer.music_minijuego_surf()


func _physics_process(_delta):
	# Get the input direction and handle the movement/deceleration.
	if can_move:

		var direction = Input.get_axis("move_left", "move_right") # Player Movement
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

		move_and_slide()

		if position.x > limit_max: # Pone limites de movimiento
			position.x = limit_max
			velocity.x = 0
		elif position.x < limit_min:
			position.x = limit_min
			velocity.x = 0

		if can_be_damaged:
			if velocity.x == 0:  # Pone animaciones segun su movimiento
				anims.play("default")
			elif velocity.x > 0:
				anims.play("turning_right")
			elif velocity.x < 0:
				anims.play("turning_left")


func _on_hitbox_area_entered(area):
	if area.is_in_group("Damage") and can_be_damaged:
		area.queue_free()

		if _upd_hp(-1) <= 0:
			_death()
		else:
			_damage()


func _upd_hp(add: int):
	var game_manager = get_tree().get_root().get_node("Main/GameManager")
	var new_hp = game_manager.health + add
	game_manager.hp_update(new_hp)
	return new_hp


func _damage():
	AudioPlayer.play_sfx(sonido_golpe)
	anims.play("damaged")
	can_be_damaged = false
	can_move = false
	await get_tree().create_timer(0.2).timeout
	can_move = true
	await anims.animation_finished
	can_be_damaged = true
	anims.play("default")


func _death():
	AudioPlayer.play_sfx(sonido_golpe)
	can_move = false
	can_be_damaged = false
	anims.play("death")
	await get_tree().create_timer(0.998).timeout #para sfx de caida y que espere
	AudioPlayer.play_sfx(sonido_caida, -12.0)
	await anims.animation_finished
	# Temporal, para testeo
	if true:
		AudioPlayer.stop_music()
		var game_manager = get_tree().get_root().get_node("Main/GameManager")
		game_manager.load_scene_dialogic(
			preload("res://Scenes/CaveMinigame/CaveGame.tscn"), '2-underwater_scene')
		
