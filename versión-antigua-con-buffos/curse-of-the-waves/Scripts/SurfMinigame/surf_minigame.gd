extends Node2D

@export_group("Basics")
@export var GameSpeed = 1.0

@export_group("Objects")
@export var Player: CharacterBody2D
@export var Spawner: Node2D
@export var MinPos: Marker2D
@export var MaxPos: Marker2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Player.limitMin = MinPos.position.x
	Player.limitMax = MaxPos.position.x
	Spawner.limitMin = MinPos.position.x
	Spawner.limitMax = MaxPos.position.x
	Spawner.heightStart = MinPos.position.y
	Spawner.heightEnd = MaxPos.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Player.speed = Player.BaseSpeed * GameSpeed
	Spawner.objectsSpeed = Spawner.BaseObjectsSpeed * GameSpeed
	Spawner.spawnTime = Spawner.BaseSpawnTime / GameSpeed
	pass
