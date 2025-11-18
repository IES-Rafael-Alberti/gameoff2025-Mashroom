extends Node2D

@export_group("Base")
@export var BaseSpawnTime = 3.0

@export_group("SoundWaves")
@export var SWBigSpeed = 3000
@export var SWBigDespawnTime = 10
@export var SWBigScale = 20
@export var SWBigPushPower = -2000
@export var SWSpeed = 2000
@export var SWDespawnTime = 10
@export var SWScale = 3
@export var SWPushPower = -2000
@export var SWGroupCd = 0.5

@export_group("Objects")
@export var SpawnPoint: Marker2D
@export var SoundWave: PackedScene
@export var TopSpawn: Marker2D
@export var BottomSpawn: Marker2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$SpawnTimer.start(BaseSpawnTime)
	

func _on_spawn_timer_timeout():
	print("Spawned")
	match randi_range(0,1):
		0: await spawnBigSoundWave()
		1: await spawnGroupSoundWave()
	$SpawnTimer.start(BaseSpawnTime)
	
func spawnGroupSoundWave():
	for i in range(0,3):
		var spawnPos = Vector2(SpawnPoint.position.x,randf_range(BottomSpawn.position.y,TopSpawn.position.y))
		spawnSoundWave(SWSpeed, SWDespawnTime, SWScale, SWPushPower, spawnPos)
		await get_tree().create_timer(SWGroupCd).timeout 

func spawnBigSoundWave():
	spawnSoundWave(SWBigSpeed, SWBigDespawnTime, SWBigScale, SWBigPushPower, SpawnPoint.position)
	
func spawnSoundWave(Speed: float, Dp: float, Scale: float, PushPower: float, pos: Vector2):
	var SWInstance = SoundWave.instantiate()
	SWInstance.Speed = Speed
	SWInstance.DespawnTime = Dp
	SWInstance.scale *= Scale
	SWInstance.PushPower = PushPower
	SWInstance.position = pos
	add_child(SWInstance)
