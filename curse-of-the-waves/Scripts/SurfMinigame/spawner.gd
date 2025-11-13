extends Node2D

@export_group("Basics")
@export var BaseSpawnTime = 1.0
@export var FishEye = 0.0
@export var BaseObjectsSpeed = 2

@export_group("Objects")
@export var SpawnPoint: Marker2D
@export var Objects: Array[PackedScene]

var spawnTime: float
var spawnMult = 1.0
var objectsSpeed = BaseObjectsSpeed

var limitMin: float
var limitMax: float
var heightStart: float
var heightEnd: float

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnTime = getSpawnTime()

func getSpawnTime():
	return spawnMult*BaseSpawnTime
	
func _on_spawn_timer_timeout():
	spawnTime = randf_range(getSpawnTime()/1.2, getSpawnTime()*1.5)
	await obstacleSpawns()
	OutsideSpawns()
	
	$SpawnTimer.wait_time = spawnTime
	$SpawnTimer.start()

func OutsideSpawns(): # Obstacles that doesn't affect Gameplay
	match randi_range(0,3):
		0: # Big Rock
			for n in range(0,randf_range(1,10)):
				await get_tree().create_timer(randf_range(0.2,1)).timeout
				var nextObject = Objects[0]
				if randi_range(0,1) == 0:
					spawnObjectPos(nextObject, randi_range(-300,-50))
				else: 
					spawnObjectPos(nextObject, randi_range(150,400))
		1: # Big Rock
			var nextObject = Objects[0]
			spawnObjectPos(nextObject, randi_range(150,400))
			if randi_range(0,1) == 0:
				for n in range(1,7):
					if randi_range(0,1) == 0: spawnObjectPos(nextObject, -50*n)
					
			if randi_range(0,1) == 0:
				for n in range(1,7):
					if randi_range(0,1) == 0: spawnObjectPos(nextObject, 50*n + 100)
					
		3: # Big Rock
			var nextObject = Objects[1]
			if randi_range(0,1) == 0:
				spawnObjectPos(nextObject, randi_range(-300,-50))
			else: 
				spawnObjectPos(nextObject, randi_range(150,400))
			
func obstacleSpawns(): # Obstacles for the gameplay
	match randi_range(0,5):
		0: # Single Rock
			var nextObject = Objects[0]
			spawnObjectPos(nextObject, randi_range(0,100))
			
		1: # 2 Rocks
			var nextObject = Objects[0]
			spawnObjectPos(nextObject, randi_range(0,40))
			spawnObjectPos(nextObject, randi_range(60,100))
			
		2: # Group of Rocks
			var nextObject = Objects[0]
			for n in range(0,4):
				spawnObjectPos(nextObject, randi_range(0,100))
				await get_tree().create_timer(getSpawnTime()/5).timeout
				
		3: # Big Rock
			await get_tree().create_timer(spawnTime/2).timeout
			var nextObject = Objects[1]
			spawnObjectPos(nextObject, randi_range(0,100))
			await get_tree().create_timer(spawnTime/2).timeout
			
		4: # Line of Rocks
			await get_tree().create_timer(spawnTime/2).timeout
			var nextObject = Objects[0]
			var freeSpace = randi_range(0,4)
			for n in range(0,5):
				if freeSpace != n:
					spawnObjectPos(nextObject, 25*n)
			await get_tree().create_timer(spawnTime/2).timeout
			
		5: # Cut down borders
			var nextObject = Objects[0]
			spawnObjectPos(nextObject, 0)
			spawnObjectPos(nextObject, 100)
			
			await get_tree().create_timer(0.2).timeout
			if randi_range(0,1) == 0: spawnObjectPos(nextObject, 0)
			if randi_range(0,1) == 0: spawnObjectPos(nextObject, 100)
				
			await get_tree().create_timer(0.3).timeout
			spawnObjectPos(nextObject, 25)
			spawnObjectPos(nextObject, 75)
			if randi_range(0,1) == 0: spawnObjectPos(nextObject, 0)
			if randi_range(0,1) == 0: spawnObjectPos(nextObject, 100)
				
			await get_tree().create_timer(0.5).timeout
			if randi_range(0,1) == 0: spawnObjectPos(nextObject, 50)


func spawnObjectPos(object: PackedScene, posRange: float): # posRange: Range between 0 and 100
	var nextObject = object.instantiate() 
	var actualPos = (limitMax-limitMin)*(posRange/100)+limitMin
	var spawnPos = Vector2(actualPos, SpawnPoint.position.y) 
	
	nextObject.global_position = spawnPos + Vector2((SpawnPoint.position.x-spawnPos.x)/(FishEye+1) ,0)
	var objMov = nextObject.get_node("ObstacleMovement")
	objMov.EndPos = Vector2(spawnPos.x, heightEnd)
	objMov.Speed *= objectsSpeed
	
	add_child(nextObject)
