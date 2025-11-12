extends Node2D

@export_group("Basics")
@export var SpawnTime = 2.0
@export var FishEye = 0.0
@export var ObjectsSpeed = 10

@export_group("Objects")
@export var SpawnPoint: Marker2D
@export var Objects: Array[PackedScene]

var limitMin: float
var limitMax: float
var heightStart: float
var heightEnd: float

# Called when the node enters the scene tree for the first time.
func _ready():
	$SpawnTimer.wait_time = SpawnTime


func _on_spawn_timer_timeout():
	spawnObject()
	
func spawnObject():
	var object = Objects[0].instantiate()
			
	var spawnPos = Vector2(randf_range(limitMin, limitMax), SpawnPoint.position.y) 
		
	object.global_position = spawnPos + Vector2((SpawnPoint.position.x-spawnPos.x)/(FishEye+1) ,0)
	var objMov = object.get_node("ObstacleMovement")
	objMov.EndPos = Vector2(spawnPos.x, heightEnd)
	objMov.Speed = ObjectsSpeed
	
	add_child(object)
