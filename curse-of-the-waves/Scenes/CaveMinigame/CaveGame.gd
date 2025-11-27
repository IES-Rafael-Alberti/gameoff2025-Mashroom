extends Node2D


func _ready():
	var game_camera = get_tree().get_root().get_node("Main/GameManager/Camera")
	game_camera.start_follow($Player, $BottomLeft, $TopRight)
