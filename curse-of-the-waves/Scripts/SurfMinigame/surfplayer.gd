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

var is_speed_boost = false
var is_invulnerable = false
var is_slowing = false
# Temporizador de cada buff
var buff_timers = {
	"speed": 0.0,
	"invul": 0.0,
	"slow": 0.0
}
# Duración predefinida de cada buff
var buff_durations = {
	"speed": 5.0,
	"invul": 4.0,
	"slow": 6.0
}


func _ready():
	AudioPlayer.music_minijuego_surf()

func _process(delta):
	update_buffs(delta) # Actualiza los buff activos


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
		
		if is_invulnerable:
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
			
	if area.is_in_group("Buff"): #Buff recibido
		apply_buff(area.buff_type)
		area.queue_free()


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
		

func apply_buff(type: String):
	match type: #Aplica el buff según su tipo
		"invul":
			invulnerability()
		"slow":
			slow_obstacles()

			
func invulnerability():
	is_invulnerable = true
	buff_timers["invul"] = buff_durations["invul"]
	can_be_damaged = false
	print("BUFF: invu aplicado")
	
	print("can_be_damaged =", can_be_damaged)

func slow_obstacles():
	is_slowing = true
	buff_timers["slow"] = buff_durations["slow"]
	# Aplicamos slow a todos los obstáculos existentes
	for o in get_tree().get_nodes_in_group("Obstacle"):
		if o.has_node("ObstacleMovement"):
			o.get_node("ObstacleMovement").global_multiplier = 0.5
	print("BUFF: slow aplicado")
	
func update_buffs(delta):
	# Invulnerabilidad
	if is_invulnerable:
		buff_timers["invul"] -= delta
		if buff_timers["invul"] <= 0:
			is_invulnerable = false
			can_be_damaged = true
			
	# Slow obstacles
	if is_slowing:
		buff_timers["slow"] -= delta
		if buff_timers["slow"] <= 0:
			is_slowing = false
			# Restauramos la volocidad normal a los obstáculos
			for o in get_tree().get_nodes_in_group("Obstacle"):
				if o.has_node("ObstacleMovement"):
					o.get_node("ObstacleMovement").global_multiplier = 1.0
	
