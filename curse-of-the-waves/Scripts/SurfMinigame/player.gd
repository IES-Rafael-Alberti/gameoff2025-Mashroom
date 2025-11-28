extends CharacterBody2D

@export_group("Basics")
@export var base_speed: float = 800.0

@onready var sonido_caida = preload("res://assets/Audio/SFX/splash_effect.wav")
@onready var anims: AnimatedSprite2D = $Sprite2D
@onready var game_manager = get_tree().get_root().get_node("Main/GameManager")

var speed: float = base_speed
var limit_min: float
var limit_max: float
var can_move: bool = true
var can_be_damaged: bool = true


func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	if can_move:
		var direction = Input.get_axis("move_left", "move_right")  # Player Movement
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

		move_and_slide()

		if position.x > limit_max:  # Pone limites de movimiento
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


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Damage") and can_be_damaged:
		area.queue_free()

		if _upd_hp(-1) <= 0:
			_death()
		else:
			anims.play("damaged")
			can_be_damaged = false
			can_move = false
			await get_tree().create_timer(0.2).timeout
			can_move = true
			await anims.animation_finished
			can_be_damaged = true
			anims.play("default")


func _upd_hp(add: int) -> int:
	var new_hp = game_manager.health + add
	game_manager.hp_update(new_hp)
	return new_hp


func _death() -> void:
	can_move = false
	can_be_damaged = false
	if randi_range(0, 1) == 1:  # 50% de flipear la death anim para dar variedad
		anims.flip_h = true
	anims.play("death")
	await get_tree().create_timer(0.999).timeout  #para sfx de caida y que espere
	AudioPlayer.play_sfx(sonido_caida, -12.0)
	await anims.animation_finished
	# Temporal, para testeo
	if true:
		Dialogic.start('2-underwater_scene')
		await Dialogic.timeline_ended
		get_tree().change_scene_to_file("res://Scenes/cuevaMinijuego/escena_cueva.tscn")
	else:
		get_tree().reload_current_scene()
