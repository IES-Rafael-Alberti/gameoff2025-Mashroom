extends Node2D

@export_group("Basics")
@export var Speed = 10.0
@export var DespawnTimerPostEnd = 1

@export_group("Complex Values")
@export var SpeedMult = 1.02
@export var SizeMult = 1.02
@export var EndPos: Vector2

var parent
var startPos: Vector2
var movAmount: float

var sizeIncrement: float
var movement: Vector2

func _ready():
	parent = get_parent()
	startPos = parent.global_position
	parent.scale = Vector2(0.01,0.01)
	
	movement = (EndPos-startPos)/100.0
	sizeIncrement = 1/7.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parent.position += movement * delta * Speed
	parent.scale += Vector2(sizeIncrement,sizeIncrement) * delta * Speed
	if parent.position.y < EndPos.y:
		movement *= 1 + SpeedMult * delta * Speed
		sizeIncrement *= 1 + SizeMult * delta * Speed
	else:
		movement /= 1 +SpeedMult * delta * Speed
		sizeIncrement /= 1 +SizeMult * delta * Speed
		parent.get_node("Sprite2D").self_modulate.a -= 0.03
		if parent.get_node("Sprite2D").self_modulate.a <= 0:
			parent.queue_free()
