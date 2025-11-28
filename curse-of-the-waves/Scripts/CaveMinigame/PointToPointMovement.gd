extends Area2D

@export_group("Base")
@export var max_speed = 300
@export var min_speed = 100

@export_group("Points")
@export var Points: Array[Marker2D]

var target_num = 0
var speed = max_speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Points.size() > 0:
		upd_speed()
		var target_pos = Points[target_num].global_position
		look_at(target_pos)
		rotation_degrees += 180
		position = position.move_toward(target_pos, speed * delta)

		if position.distance_to(target_pos) < 10:
			target_num += 1
			if target_num >= Points.size() - 1:
				target_num = 0


func upd_speed():
	var int_num = target_num - 1
	if int_num < 0:
		int_num = Points.size() - 1

	var int_pos = Points[int_num].global_position
	var target_pos = Points[target_num].global_position
	var total_dist = int_pos.distance_to(target_pos)
	var current_dist = position.distance_to(target_pos)

	if current_dist > total_dist / 2:
		speed = move_toward(speed, max_speed, 5)
	else:
		speed = move_toward(speed, min_speed, 5)
