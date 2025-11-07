extends Node2D


@export var obstacle_scene: PackedScene
@export var spawn_interval: float = 2.0  # El tiempo en que aparece un obstáculo
@export var obstacle_speed: float = 200.0
@export var spawn_area_top: float = 300.0
@export var spawn_area_bottom: float = 400.0

var spawn_timer = 0.0

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_obstacle()

func spawn_obstacle():
	if obstacle_scene:
		var obstacle = obstacle_scene.instantiate()
		add_child(obstacle)
		obstacle.position = Vector2(1280, randf_range(spawn_area_top, spawn_area_bottom))
		obstacle.speed = obstacle_speed
