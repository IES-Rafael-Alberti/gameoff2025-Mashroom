extends Area2D

@export_group("Base")
@export var max_speed = 300
@export var min_speed = 100

@export_group("Points")
@export var points: Array[Marker2D]

var target_num = 0
var speed = max_speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if points.size() > 0:
		upd_speed()
		var target_pos = points[target_num].global_position
		look_at(target_pos)
		rotation_degrees += 180

		if global_position.x <= target_pos.x:
			$AnimatedSprite2D.flip_v = true
		else:
			$AnimatedSprite2D.flip_v = false
		global_position = global_position.move_toward(target_pos, speed * delta)

		if global_position == target_pos:
			if target_num >= points.size() - 1:
				target_num = 0
			else:
				target_num += 1


func upd_speed():
	var int_num: int
	if target_num == 0:
		int_num = points.size() - 1
	else:
		int_num = target_num - 1

	var int_pos = points[int_num].global_position
	var target_pos = points[target_num].global_position

	var intdist = int_pos.distance_to(global_position)
	var targetdist = target_pos.distance_to(global_position)

	speed = max_speed - max_speed * (
		abs(intdist - targetdist) / int_pos.distance_to(target_pos)
	) + min_speed
