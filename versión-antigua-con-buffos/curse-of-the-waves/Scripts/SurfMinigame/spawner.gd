extends Node2D

@export_group("Basics")
@export var BaseSpawnTime = 2.0
@export var FishEye = 0.0
@export var BaseObjectsSpeed = 2

@export_group("Objects")
@export var SpawnPoint: Marker2D
@export var Objects: Array[PackedScene]

@export_group("Items")
@export var SpawnPointItem: Marker2D
@export var Items: Array[PackedScene]
@export var BuffSpawnMin: = 1.0
@export var BuffSpawnMax: = 3.0

var spawnTime = BaseSpawnTime
var objectsSpeed = BaseObjectsSpeed
var limitMin: float
var limitMax: float
var heightStart: float
var heightEnd: float

# Called when the node enters the scene tree for the first time.
func _ready():
	$SpawnTimer.wait_time = spawnTime

func _on_buff_timer_timeout():
	spawnBuff()
	$BuffTimer.wait_time = randf_range(BuffSpawnMin, BuffSpawnMax)

func _on_spawn_timer_timeout():
	spawnRandObject()
	$SpawnTimer.wait_time = randf_range(spawnTime/2, spawnTime*1.2)
		
	
func spawnRandObject():
	var object = Objects[randi_range(0,Objects.size()-1)].instantiate()
	spawnObject(object)
	
func spawnRandObjectPos(posRange: float): # posRange: Range between 0 and 100
	var object = Objects[0].instantiate()
	spawnObjectPos(object, posRange)
	
func spawnObject(object: Node2D):
	spawnObjectPos(object, randf_range(0, 100))
	
func spawnObjectPos(object: Node2D, posRange: float): # posRange: Range between 0 and 100
	var actualPos = (limitMax-limitMin)*(posRange/100)+limitMin
	var spawnPos = Vector2(actualPos, SpawnPoint.position.y) 
	
	object.global_position = spawnPos + Vector2((SpawnPoint.position.x-spawnPos.x)/(FishEye+1) ,0)
	#var objMov = null
	#if object.has_node("ObstacleMovement"):
		#objMov = object.get_node("ObstacleMovement")
	#elif object.has_node("ItemMovement"):
		#objMov = object.get_node("ItemMovement")
	var objMov = object.get_node("ObstacleMovement")
	objMov.EndPos = Vector2(spawnPos.x, heightEnd)
	objMov.Speed = objectsSpeed
	
	add_child(object)
	
func spawnBuff():
	if Items.is_empty():
		return
	
	var buff = Items[randi_range(0, Items.size() -1)].instantiate()
	
	var posRange = randf_range(0, 100)
	var actualPos = (limitMax - limitMin) * (posRange / 100) + limitMin
	var spawnPos = Vector2(actualPos, SpawnPointItem.position.y)
	
	buff.global_position = spawnPos + Vector2((SpawnPointItem.position.x - spawnPos.x) / (FishEye + 1), 0)
	
	var mov = buff.get_node("ItemMovement")
	mov.EndPos = Vector2(spawnPos.x, heightEnd)
	mov.Speed = objectsSpeed
	
	add_child(buff)
