extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var animsSize = sprite_frames.get_animation_names().size()
	var name = "Obj"+str(randi_range(1,animsSize))
	#if randi_range(0,1) == 0:
	#	flip_h = true
	play(name)
