extends CharacterBody2D

@export_group("Basics")
@export var Hp = 3
@export var Speed = 300.0

var limitMin: float
var limitMax: float


func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * Speed
	else:
		velocity.x = move_toward(velocity.x, 0, Speed)

	move_and_slide()
	
	if position.x > limitMax:
		position.x = limitMax
	elif position.x < limitMin:
		position.x = limitMin
		


func _on_hitbox_area_entered(body):
	if body.is_in_group("Damage"):
		queue_free()
