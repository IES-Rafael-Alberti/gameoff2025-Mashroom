extends Node2D


@export var obstacle_scene: PackedScene
@export var spawn_interval: float = 2.0  # El tiempo en que aparece un obstáculo
@export var obstacle_speed: float = 200.0
@export var spawn_area_top: Marker2D
@export var spawn_area_bottom: Marker2D

var top_pos: float
var bottom_pos: float

var spawn_timer = 0.0

func _ready():
	top_pos = spawn_area_top.position.y
	bottom_pos = spawn_area_bottom.position.y 
	
func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_obstacle()

func spawn_obstacle():
	if obstacle_scene:
		var obstacle = obstacle_scene.instantiate()
		add_child(obstacle)
		obstacle.position = Vector2(1280, randf_range(top_pos, bottom_pos))
		obstacle.speed = obstacle_speed
		obstacle.top_pos = top_pos
		obstacle.bottom_pos = bottom_pos
		
	
