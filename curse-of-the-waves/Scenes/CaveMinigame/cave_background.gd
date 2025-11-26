extends Sprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var game_camera = get_tree().get_root().get_node("Main/GameManager/Camera")
	position = game_camera.global_position
