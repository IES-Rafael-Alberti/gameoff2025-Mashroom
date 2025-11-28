extends Node2D

@export_group("Basics")
@export var speed = 1.0
@export var despawn_timer_post_end = 1

@export_group("Complex Values")
@export var speed_mult = 1.02
@export var size_mult = 1.02
@export var end_pos: Vector2

@onready var parent = get_parent()
@onready var start_pos = parent.global_position
@onready var size_increment = parent.scale.x/7.0
@onready var movement = (end_pos-start_pos)/100.0

var mov_amount: float

func _ready():
	parent.scale = Vector2(0.01,0.01)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parent.position += movement * delta * speed
	parent.scale += Vector2(size_increment,size_increment) * delta * speed
	
	if parent.position.y < end_pos.y: # Proceso para similar acercamiento 3D
		movement *= 1 + speed_mult * delta * speed
		size_increment *= 1 + size_mult * delta * speed
	else: # Punto donde empieza a desaparecer (llega al final de su ruta)
		movement /= 1 + speed_mult * delta * speed
		size_increment /= 1 + size_mult * delta * speed
		parent.get_node("Sprite2D").self_modulate.a -= 0.03
		if parent.get_node("Sprite2D").self_modulate.a <= 0:
			parent.queue_free()
