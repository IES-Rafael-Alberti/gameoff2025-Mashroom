extends Node2D

@export_group("Base")
@export var base_spawn_time = 3.0

@export_group("SoundWaves")
@export var sw_big_speed = 3000
@export var sw_big_despawn_time = 10
@export var sw_big_scale = 20
@export var sw_big_push_power = -2000
@export var sw_speed = 2000
@export var sw_despawn_time = 10
@export var sw_scale = 3
@export var sw_push_power = -2000
@export var sw_group_cd = 0.5

@export_group("Objects")
@export var spawn_point: Marker2D
@export var sound_wave: PackedScene
@export var top_spawn: Marker2D
@export var bottom_spawn: Marker2D


func _ready():
	$SpawnTimer.start(base_spawn_time)


func _process(_delta):
	var game_camera = get_tree().get_root().get_node("Main/GameManager/Camera")
	position = game_camera.global_position


func _on_spawn_timer_timeout():
	match randi_range(0,1):
		0: await spawnBigSoundWave()
		1: await spawnGroupSoundWave()
	$SpawnTimer.start(BaseSpawnTime)
	
func spawnGroupSoundWave():
	AudioPlayer.sfxAntesOndita()
	for i in range(0,3):
	#onditas pequeñas
		await get_tree().create_timer(1).timeout #sfx antes de la onda y se espera
		AudioPlayer.sfxOndita(3.0) #bajarle volumen a esta para subir el de la grande
		var spawnPos = Vector2(SpawnPoint.global_position.x,randf_range(BottomSpawn.position.y,TopSpawn.position.y))
		spawnSoundWave(SWSpeed, SWDespawnTime, SWScale, SWPushPower, spawnPos)
		await get_tree().create_timer(SWGroupCd).timeout 

func spawnBigSoundWave():
	#onda grande, que sea mas grave y fuerte que la pequeña
	#este mismo sonido pero para la pequeña y + agudo 
	AudioPlayer.sfxAntesOnda()
	await get_tree().create_timer(1).timeout
	AudioPlayer.sfxOnda(7.0)
	spawnSoundWave(SWBigSpeed, SWBigDespawnTime, SWBigScale, SWBigPushPower, SpawnPoint.global_position)
	
func spawnSoundWave(Speed: float, Dp: float, Scale: float, PushPower: float, pos: Vector2):
	var SWInstance = SoundWave.instantiate()
	SWInstance.Speed = Speed
	SWInstance.DespawnTime = Dp
	SWInstance.scale *= Scale
	SWInstance.PushPower = PushPower
	SWInstance.position = pos
	add_child(SWInstance)
