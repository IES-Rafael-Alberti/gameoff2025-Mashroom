extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var GameCamera = get_tree().get_root().get_node("Main/GameManager/Camera")
	GameCamera.startFollow($Player, $BottomLeft, $TopRight)
