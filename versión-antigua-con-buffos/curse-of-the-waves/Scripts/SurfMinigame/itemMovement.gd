extends Node2D

@export_group("Basics")
@export var Speed = 5.0
@export var DespawnTimerPostEnd = 1

@export_group("Complex Values")
@export var SpeedMult = 1.001
@export var SizeMult = 1.001
@export var EndPos: Vector2

@onready var parent = get_parent()
@onready var startPos = parent.global_position
@onready var sizeIncrement = parent.scale.x/7.0
@onready var movement = (EndPos-startPos)/100.0

var movAmount: float

func _ready():
	parent.scale = Vector2(0.2,0.2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parent.position += movement * delta * Speed
	parent.scale += Vector2(sizeIncrement,sizeIncrement) * delta * Speed
	
	var max_scale: = 1.7
	if parent.scale.x > max_scale:
		parent.scale = Vector2(max_scale, max_scale)
	
	if parent.position.y < EndPos.y: # Proceso para similar acercamiento 3D
		movement *= 1 + SpeedMult * delta * Speed
		sizeIncrement *= 1 + SizeMult * delta * Speed
	else: # Punto donde empieza a desaparecer (llega al final de su ruta)
		movement /= 1 +SpeedMult * delta * Speed
		sizeIncrement /= 1 +SizeMult * delta * Speed
		if parent.has_node("Sprite2D"):
			var sprite = parent.get_node("Sprite2D")
			sprite.self_modulate.a -= 0.03
			if sprite.self_modulate.a <= 0:
				parent.queue_free()
		else:
			parent.queue_free()
