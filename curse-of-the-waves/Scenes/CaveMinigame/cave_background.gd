extends Sprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var GameCamera = get_tree().get_root().get_node("Main/GameManager/Camera")
	position = GameCamera.global_position
