extends Camera2D

var objectToFollow: Node2D
var BLMarker: Marker2D
var TRMarker: Marker2D

@onready var cameraSize = get_viewport().get_visible_rect().size/zoom
@onready var camWidth = cameraSize.x
@onready var camHeight = cameraSize.y

var followPlayer = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if followPlayer:
		position.x = objectToFollow.position.x
		position.y = objectToFollow.position.y
		
		if position.x < BLMarker.global_position.x+camWidth/2:
			position.x = BLMarker.global_position.x+camWidth/2
		elif position.x > TRMarker.global_position.x-camWidth/2:
			position.x = TRMarker.global_position.x-camWidth/2 
			
		if position.y > BLMarker.position.y-camHeight/2:
			position.y = BLMarker.position.y-camHeight/2
		elif position.y < TRMarker.position.y+camHeight/2:
			position.y = TRMarker.position.y+camHeight/2 
	else:
		position = Vector2(960, 540)

func startFollow(follow: Node2D, BLMark: Marker2D, TRMark: Marker2D):
	objectToFollow = follow
	BLMarker = BLMark
	TRMarker = TRMark
	followPlayer = true
