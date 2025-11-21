extends CharacterBody2D


@export_group("Basics")
@export var BaseSpeed = 400.0
@export var JumpPower = -200
@export var iframes = 1

@export_group("Complex")
@export var gravityMult = 0.5
@export var releaseJumpPower = -200
@export var maxJumpSpeed = -500
@export var maxFallSpeed = 300

var speed = BaseSpeed
var canMove = true
var canBeDamaged = true
var isMoving = false
var isHidden = false

func _ready():
	AudioPlayer.musicMinijuegoCueva()
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * gravityMult
	if canMove:
		if Input.is_action_pressed("SecondaryAction") or Input.is_action_pressed("move_down"):
			isHidden = true
		else: 
			isHidden = false
			# Handle jump.
			if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("move_up"):
				if velocity.y > 0:
					velocity.y = 0
				velocity.y += JumpPower
			# Handle Left-Right
			
	var direction = Input.get_axis("move_left", "move_right")
	if direction and not isHidden:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
				
	# Limit the Vertical Movement
	if velocity.y > maxFallSpeed:
		velocity = Vector2(velocity.x,maxFallSpeed)
	elif velocity.y < maxJumpSpeed:
		velocity = Vector2(velocity.x,maxJumpSpeed)
	move_and_slide()
	
	# Detect movement
	if velocity.x != 0: 
		isMoving = true
	else: 
		isMoving = false
		
	# Temporal (to know when hidden)
	if isHidden: $Sprite2D.flip_v = true
	else: $Sprite2D.flip_v = false



func _on_hitbox_area_entered(area):
	if area.is_in_group("Damage") and canBeDamaged and not isHidden:
		takeDamage()
	elif area.is_in_group("SoundWave"):
		velocity.x = area.PushPower
		if canBeDamaged and not isHidden:
			takeDamage()
	elif area.is_in_group("Finish"):
		finish()
		
func finish():
	var GameManager = get_tree().get_root().get_node("Main/GameManager")
	GameManager.loadSceneDialogic(preload("res://Scenes/FinishGame.tscn"), '3-cave_scene')
	
func takeDamage():
	if updHp(-1) <= 0:
		death()
	else:
		canBeDamaged = false
		await get_tree().create_timer(iframes).timeout
		canBeDamaged = true
		
func updHp(add: int):
	var GameManager = get_tree().get_root().get_node("Main/GameManager")
	var newHp = GameManager.health + add
	GameManager.HpUpdate(newHp)
	return newHp

func death(): # Proceso de Muerte
	canMove = false
	canBeDamaged = false
	
	# Temporal, para testeo
	if true:
		#Dialogic.start('2-underwater_scene')
		#await Dialogic.timeline_ended
		var GameManager = get_tree().get_root().get_node("Main/GameManager")
		GameManager.loadScene(load("res://Scenes/CaveMinigame/CaveGame.tscn"))
