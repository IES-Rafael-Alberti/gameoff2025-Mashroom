extends Camera2D

var object_to_follow: Node2D
var bl_marker: Marker2D
var tr_marker: Marker2D

@onready var camera_size = get_viewport().get_visible_rect().size / zoom
@onready var cam_width = camera_size.x
@onready var cam_height = camera_size.y

var follow_player = false


func _process(_delta):
	if follow_player:
		position.x = object_to_follow.position.x
		position.y = object_to_follow.position.y

		if position.x < bl_marker.global_position.x + cam_width / 2:
			position.x = bl_marker.global_position.x + cam_width / 2
		elif position.x > tr_marker.global_position.x - cam_width / 2:
			position.x = tr_marker.global_position.x - cam_width / 2

		if position.y > bl_marker.position.y - cam_height / 2:
			position.y = bl_marker.position.y - cam_height / 2
		elif position.y < tr_marker.position.y + cam_height / 2:
			position.y = tr_marker.position.y + cam_height / 2
	else:
		position = Vector2(960, 540)


func start_follow(follow: Node2D, bl_mark: Marker2D, tr_mark: Marker2D):
	object_to_follow = follow
	bl_marker = bl_mark
	tr_marker = tr_mark
	follow_player = true
