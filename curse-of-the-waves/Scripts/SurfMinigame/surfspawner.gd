extends Node2D

@export_group("Basics")
@export var base_spawn_time = 1.0
@export var fish_eye = 0.0
@export var base_objects_speed = 2

@export_group("Objects")
@export var spawn_point: Marker2D
@export var objects: Array[PackedScene]

var spawn_time: float
var spawn_mult = 1.0
var objects_speed = base_objects_speed

var limit_min: float
var limit_max: float
var height_start: float
var height_end: float


func _ready():
	spawn_time = _get_spawn_time()


func _get_spawn_time():
	return spawn_mult * base_spawn_time


func _on_spawn_timer_timeout():
	spawn_time = randf_range(_get_spawn_time() / 1.2, _get_spawn_time() * 1.5)
	await _obstacle_spawns()
	_outside_spawns()

	$SpawnTimer.wait_time = spawn_time
	$SpawnTimer.start()


func _outside_spawns():  # Obstacles that doesn't affect Gameplay
	for n in range(0, randf_range(5, 20)):
		await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
		var next_object = objects[0]
		if randi_range(0, 1) == 0:
			_spawn_object_pos(next_object, randi_range(-300, -50))
		else:
			_spawn_object_pos(next_object, randi_range(150, 400))

	match randi_range(0, 3):  # 0 is Nothing
		1:  # Line of rocks
			var next_object = objects[0]
			_spawn_object_pos(next_object, randi_range(150, 400))
			if randi_range(0, 1) == 0:
				for m in range(1, 7):
					if randi_range(0, 1) == 0:
						_spawn_object_pos(next_object, -50 * m)

			if randi_range(0, 1) == 0:
				for m in range(1, 7):
					if randi_range(0, 1) == 0:
						_spawn_object_pos(next_object, 50 * m + 100)

		3:  # Big Rock
			var next_object = objects[1]
			if randi_range(0, 1) == 0:
				_spawn_object_pos(next_object, randi_range(-300, -50))
			else:
				_spawn_object_pos(next_object, randi_range(150, 400))


func _obstacle_spawns():  # Obstacles for the gameplay
	match randi_range(0, 5):
		0:  # Single Rock
			var next_object = objects[0]
			_spawn_object_pos(next_object, randi_range(0, 100))

		1:  # 2 Rocks
			var next_object = objects[0]
			_spawn_object_pos(next_object, randi_range(0, 40))
			_spawn_object_pos(next_object, randi_range(60, 100))

		2:  # Group of Rocks
			var next_object = objects[0]
			for m in range(0, 4):
				_spawn_object_pos(next_object, randi_range(0, 100))
				await get_tree().create_timer(_get_spawn_time() / 5).timeout

		3:  # Big Rock
			await get_tree().create_timer(spawn_time / 2).timeout
			var next_object = objects[1]
			_spawn_object_pos(next_object, randi_range(0, 100))
			await get_tree().create_timer(spawn_time / 2).timeout

		4:  # Line of Rocks
			await get_tree().create_timer(spawn_time / 2).timeout
			var next_object = objects[0]
			var free_space = randi_range(0, 4)
			for m in range(0, 5):
				if free_space != m:
					_spawn_object_pos(next_object, 25 * m)
			await get_tree().create_timer(spawn_time / 2).timeout

		5:  # Cut down borders
			var next_object = objects[0]
			_spawn_object_pos(next_object, 0)
			_spawn_object_pos(next_object, 100)

			await get_tree().create_timer(0.2).timeout
			if randi_range(0, 1) == 0:
				_spawn_object_pos(next_object, 0)
			if randi_range(0, 1) == 0:
				_spawn_object_pos(next_object, 100)

			await get_tree().create_timer(0.3).timeout
			_spawn_object_pos(next_object, 25)
			_spawn_object_pos(next_object, 75)
			if randi_range(0, 1) == 0:
				_spawn_object_pos(next_object, 0)
			if randi_range(0, 1) == 0:
				_spawn_object_pos(next_object, 100)

			await get_tree().create_timer(0.5).timeout
			if randi_range(0, 1) == 0:
				_spawn_object_pos(next_object, 50)


func _spawn_object_pos(object: PackedScene, pos_range: float):  # pos_range: Range between 0 and 100
	var next_object = object.instantiate()
	var actual_pos = (limit_max - limit_min) * (pos_range / 100) + limit_min
	var spawn_pos = Vector2(actual_pos, spawn_point.position.y)

	next_object.global_position = spawn_pos + Vector2(
		(spawn_point.position.x - spawn_pos.x) / (fish_eye + 1), 0)
	var obj_mov = next_object.get_node("ObstacleMovement")
	obj_mov.EndPos = Vector2(spawn_pos.x, height_end)
	obj_mov.Speed *= objects_speed

	add_child(next_object)
