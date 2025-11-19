extends Area2D

@export_group("Base")
@export var MaxSpeed = 300
@export var MinSpeed = 100

@export_group("Points")
@export var Points: Array[Marker2D]

var targetNum = 0
var speed = MaxSpeed
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Points.size() > 0:
		updSpeed()
		var targetPos = Points[targetNum].position
		look_at(targetPos)
		rotation_degrees += 180
		
		if position.x <= targetPos.x:
			$AnimatedSprite2D.flip_v = true
		else: $AnimatedSprite2D.flip_v = false
		position = position.move_toward(targetPos, speed * delta)
		
		if position == targetPos:
			if targetNum >= Points.size()-1:
				targetNum = 0
			else: targetNum += 1

func updSpeed():
	var intNum: int
	if targetNum == 0: intNum = Points.size()-1
	else: intNum = targetNum-1
	
	var intPos = Points[intNum].position
	var targetPos = Points[targetNum].position
	
	var intdist = intPos.distance_to(position)
	var targetdist = targetPos.distance_to(position)
	
	speed = MaxSpeed - MaxSpeed*(abs(intdist - targetdist)/intPos.distance_to(targetPos)) + MinSpeed
