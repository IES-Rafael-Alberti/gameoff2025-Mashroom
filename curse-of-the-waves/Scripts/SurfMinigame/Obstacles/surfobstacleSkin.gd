extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var anims_size = sprite_frames.get_animation_names().size()
	var anim_name = "Obj" + str(randi_range(1, anims_size))
	#if randi_range(0,1) == 0:
	#	flip_h = true
	play(anim_name)
