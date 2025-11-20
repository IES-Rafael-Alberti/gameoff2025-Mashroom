extends CharacterBody2D

@export_group("Basics")
@export var Hp = 3
@export var BaseSpeed = 800.0

@onready var anims = $Sprite2D
@onready var heart_textures = {
	"full": preload("res://assets/SurfMinigame/Heart.png"),
	"broken": preload("res://assets/SurfMinigame/Broken-heart.png")
}

var speed = BaseSpeed # Referencia al Spawner
var limitMin: float
var limitMax: float
var canMove = true
var canBeDamaged = true

@export var Spawner: Node
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

func _process(delta):
	update_buffs(delta) # Actualiza los buff activos
	salud_ctrl() # Actualiza la UI de los corazones
	
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
	
	if body.is_in_group("Buff"): #Buff recibido
		apply_buff(body.buff_type)
		body.queue_free()

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

func apply_buff(type: String):
	match type: #Aplica el buff según su tipo
		"speed":
			speed_boost()
		"invul":
			invulnerability()
		"slow":
			slow_obstacles()

func speed_boost(): 
	is_speed_boost = true
	buff_timers["speed"] = buff_durations["speed"]
	speed = BaseSpeed * 4.0 # Multiplica la velocidad del jugador
	print("BUFF: speed aplicado")
	print("Spawner =", Spawner)
	print("speed =", BaseSpeed)
	

func invulnerability():
	is_invulnerable = true
	buff_timers["invul"] = buff_durations["invul"]
	canBeDamaged = false
	print("BUFF: invu aplicado")
	print("Spawner =", Spawner)
	print("canBeDamaged =", canBeDamaged)

func slow_obstacles():
	is_slowing = true
	buff_timers["slow"] = buff_durations["slow"]
	# Aplicamos slow a todos los obstáculos existentes
	for o in get_tree().get_nodes_in_group("Obstacle"):
		if o.has_node("ObstacleMovement"):
			o.get_node("ObstacleMovement").global_multiplier = 0.5
	print("BUFF: slow aplicado")
	print("Spawner =", Spawner)
	print("Spawner.BaseObjectsSpeed =", Spawner.BaseObjectsSpeed)

func update_buffs(delta):
	# Speed Boost
	if is_speed_boost:
		buff_timers["speed"] -= delta
		if buff_timers["speed"] <= 0:
			is_speed_boost = false
			speed = BaseSpeed # Volvemos a la velocidad normal
	
	# Invulnerabilidad
	if is_invulnerable:
		buff_timers["invul"] -= delta
		if buff_timers["invul"] <= 0:
			is_invulnerable = false
			canBeDamaged = true
	
	# Slow obstacles
	if is_slowing:
		buff_timers["slow"] -= delta
		if buff_timers["slow"] <= 0:
			is_slowing = false
			# Restauramos la volocidad normal a los obstáculos
			for o in get_tree().get_nodes_in_group("Obstacle"):
				if o.has_node("ObstacleMovement"):
					o.get_node("ObstacleMovement").global_multiplier = 1.0
