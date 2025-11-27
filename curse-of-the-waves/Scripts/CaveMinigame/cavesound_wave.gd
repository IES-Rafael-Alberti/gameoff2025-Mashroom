extends Area2D

@export_group("Base")
@export var Speed = 200
@export var DespawnTime = 10
@export var PushPower = -2000

func _ready():
	await get_tree().create_timer(DespawnTime).timeout 
	queue_free()

func _process(delta):
	position.x -= Speed * delta
