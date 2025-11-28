extends Area2D

@export_group("Base")
@export var speed = 200
@export var despawn_time = 10
@export var push_power = -2000

func _ready():
	await get_tree().create_timer(despawn_time).timeout 
	queue_free()

func _process(delta):
	position.x -= speed * delta