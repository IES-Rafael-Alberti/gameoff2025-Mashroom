extends CharacterBody2D

@export_group("Basics")
@export var base_speed: float = 400.0
@export var jump_power: int = -20
@export var iframes: float = 1.0

@export_group("Complex")
@export var gravity_mult: float = 0.5
@export var release_jump_power: int = -200
@export var max_jump_speed: int = -300
@export var max_fall_speed: int = 300

@onready var anims: AnimatedSprite2D = $Sprite2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed: float = base_speed
var can_move: bool = true
var can_be_damaged: bool = true
var is_moving: bool = false
var is_hidden: bool = false


func _ready() -> void:
	AudioPlayer.music_minijuego_cueva()


func _physics_process(delta: float) -> void:
	var desired_anim = "default"
	# Add the gravity.
	if not is_on_floor():
		velocity += Vector2(0, gravity) * delta * gravity_mult
	# Input handling (movement, jump, hide)
	if can_move:
		if Input.is_action_pressed("MainAction"):
			is_hidden = true
		else:
			is_hidden = false
			if Input.is_action_pressed("move_up"):
				desired_anim = "move"
				if velocity.y > 0:
					velocity.y = 0
				velocity.y += jump_power

	var direction = Input.get_axis("move_left", "move_right")
	if direction and not is_hidden:
		velocity.x = direction * speed
		desired_anim = "move"
		if velocity.x > 0:
			anims.flip_h = true
		elif velocity.x < 0:
			anims.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Hidden state overrides other animations
	if is_hidden:
		desired_anim = "hide"

	# Play animation only when it changes so frames can advance
	if anims.animation != desired_anim:
		anims.play(desired_anim)

	# Limit the Vertical Movement
	if velocity.y > max_fall_speed:
		velocity = Vector2(velocity.x, max_fall_speed)
	elif velocity.y < max_jump_speed:
		velocity = Vector2(velocity.x, max_jump_speed)
	move_and_slide()

	# Detect movement
	if velocity.x != 0:
		is_moving = true
	else:
		is_moving = false

	# Temporal (to know when hidden)
	if is_hidden:
		# ensure hide animation shows
		if anims.animation != "hide":
			anims.play("hide")
	else:
		anims.flip_v = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Damage") and can_be_damaged and not is_hidden:
		_take_damage()
	elif area.is_in_group("SoundWave"):
		velocity.x = area.PushPower
		if can_be_damaged and not is_hidden:
			_take_damage()
	elif area.is_in_group("Finish"):
		_finish()


func _finish() -> void:
	var game_manager = get_tree().get_root().get_node("Main/GameManager")
	AudioPlayer.stop_music()
	game_manager.load_scene_dialogic(preload("res://Scenes/Credits.tscn"), '3-cave_scene', true)


func _take_damage() -> void:
	if _upd_hp(-1) <= 0:
		_death()
	else:
		can_be_damaged = false
		await get_tree().create_timer(iframes).timeout
		can_be_damaged = true


func _upd_hp(add: int) -> int:
	var game_manager = get_tree().get_root().get_node("Main/GameManager")
	var new_hp = game_manager.health + add
	game_manager.hp_update(new_hp)
	return new_hp


func _death() -> void:
	can_move = false
	can_be_damaged = false

	# Temporal, para testeo
	if true:
		#Dialogic.start('2-underwater_scene')
		#await Dialogic.timeline_ended
		var game_manager = get_tree().get_root().get_node("Main/GameManager")
		game_manager.call_deferred(
			"load_scene",
			load("res://Scenes/CaveMinigame/CaveGame.tscn"),
			true,
		)
