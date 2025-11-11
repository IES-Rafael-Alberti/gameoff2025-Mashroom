extends Area2D

@export_group("Basics")
@export var speed = 50

var puedeMoverse: bool = true
var vel: Vector2 = Vector2.ZERO
var screen_size: Vector2
var posicionInicial: Vector2

func _ready():
	screen_size = get_viewport_rect().size
	posicionInicial = position

func _process(delta):
	if not puedeMoverse:
		vel = Vector2.ZERO
		return

	vel = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		vel.x += 1
	if Input.is_action_pressed("move_left"):
		vel.x -= 1

	if vel.length() > 0:
		vel = vel.normalized() * speed

	position += vel * delta
	position = position.clamp(Vector2.ZERO, screen_size)

func reinicioPosicion():
	position = posicionInicial
