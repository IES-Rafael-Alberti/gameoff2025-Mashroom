extends CharacterBody2D

# Constants
const SFX_SPLASH_PATH = "res://assets/Audio/SFX/Minijuego surf/efectoSplash.wav"
const SFX_HIT_PATH = "res://assets/Audio/SFX/Minijuego surf/sonidoGolpe.wav"
const CAVE_GAME_SCENE_PATH = "res://Scenes/CaveMinigame/CaveGame.tscn"

@export_group("Basics")
@export var base_speed: float = 800.0

@onready var sonido_caida = preload(SFX_SPLASH_PATH)
@onready var anims: Node = $Sprite2D
@onready var sonido_golpe = preload(SFX_HIT_PATH)
@onready var game_manager = get_tree().get_root().get_node("Main/GameManager")

var speed: float = base_speed
var limit_min: float
var limit_max: float
var can_move: bool = true
var can_be_damaged: bool = true


func _ready() -> void:
	AudioPlayer.music_minijuego_surf()
	# Start the storm sequence after a delay
	await get_tree().create_timer(18.0).timeout
	sfx_tormenta()


func _physics_process(_delta: float) -> void:
	if not can_move:
		return

	# Handle Movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

	# Clamp position
	if position.x > limit_max:
		position.x = limit_max
		velocity.x = 0
	elif position.x < limit_min:
		position.x = limit_min
		velocity.x = 0

	# Handle Animations
	if can_be_damaged:
		if velocity.x == 0:
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
			_damage()
	elif area.is_in_group("Kumi"):
		game_manager.surfBeated = true
		next_scene()


func _upd_hp(add: int) -> int:
	var new_hp = game_manager.health + add
	game_manager.hp_update(new_hp)
	return new_hp


func _damage() -> void:
	AudioPlayer.play_sfx(sonido_golpe)
	anims.play("damaged")

	can_be_damaged = false
	can_move = false

	await get_tree().create_timer(0.2).timeout
	can_move = true

	await anims.animation_finished
	can_be_damaged = true
	anims.play("default")


func _death() -> void:
	AudioPlayer.play_sfx(sonido_golpe)
	can_move = false
	can_be_damaged = false
	anims.play("death")

	await get_tree().create_timer(0.998).timeout # Wait for fall sfx timing
	AudioPlayer.play_sfx(sonido_caida, -7.0)

	await anims.animation_finished
	next_scene()


func next_scene() -> void:
	AudioPlayer.stop_music()
	game_manager.load_scene_cave(
		preload(CAVE_GAME_SCENE_PATH),
		'2-underwater_scene',
		true,
	)


func sfx_tormenta() -> void:
	var vol_trueno: float = -5.0 # Initial volume
	var vol_aumenta: float = 2.0 # Volume increase step
	var intervalo: float = 4.0 # Seconds between thunders
	var duracion_sfx: float = 2.0
	var max_thunders: int = 11 # Limit of thunders
	var contador: int = 0

	while contador < max_thunders:
		var tween = create_tween()
		tween.tween_property(AudioPlayer, "volume_db", -8.0, 1.5)
		await tween.finished

		AudioPlayer.sfxTrueno(vol_trueno)
		await get_tree().create_timer(duracion_sfx).timeout

		tween = create_tween()
		tween.tween_property(AudioPlayer, "volume_db", 0.0, 1.5)
		await get_tree().create_timer(intervalo).timeout

		vol_trueno += vol_aumenta
		if contador <= 2:
			intervalo = max(1.0, intervalo - 1.0)
		contador += 1
