extends Node2D

@export_group("Basics")
@export var Speed = 1.0
@export var DespawnTimerPostEnd = 1

@export_group("Complex Values")
@export var SpeedMult = 1.02
@export var SizeMult = 1.02
@export var EndPos: Vector2

@onready var parent = get_parent()
@onready var startPos = parent.global_position
@onready var sizeIncrement = parent.scale.x/7.0
@onready var movement = (EndPos-startPos)/100.0

var movAmount: float

func _ready():
	parent.scale = Vector2(0.01,0.01)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parent.position += movement * delta * Speed
	parent.scale += Vector2(sizeIncrement,sizeIncrement) * delta * Speed
	
	if parent.position.y < EndPos.y: # Proceso para similar acercamiento 3D
		movement *= 1 + SpeedMult * delta * Speed
		sizeIncrement *= 1 + SizeMult * delta * Speed
	else: # Punto donde empieza a desaparecer (llega al final de su ruta)
		movement /= 1 +SpeedMult * delta * Speed
		sizeIncrement /= 1 +SizeMult * delta * Speed
		parent.get_node("Sprite2D").self_modulate.a -= 0.03
		if parent.get_node("Sprite2D").self_modulate.a <= 0:
			parent.queue_free()
