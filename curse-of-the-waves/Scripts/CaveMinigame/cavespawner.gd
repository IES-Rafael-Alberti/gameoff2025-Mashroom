extends Node2D

@export_group("Base")
@export var base_spawn_time = 3.0
@export var witch_killed = false
@export var wk_spawn_time = 10.0

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
	$SpawnTimer.start(5)


func _process(_delta):
	if witch_killed:
		base_spawn_time = 10
	var game_camera = get_tree().get_root().get_node("Main/GameManager/Camera")
	position = game_camera.global_position


func _on_spawn_timer_timeout():
	match randi_range(0, 1):
		0:
			await _spawn_big_sound_wave()
		1:
			await _spawn_group_sound_wave()
	$SpawnTimer.start(base_spawn_time if not witch_killed else wk_spawn_time)


func _spawn_group_sound_wave():
	AudioPlayer.sfx_antes_ondita()
	for i in range(0, 3):
		#onditas pequeñas
		await get_tree().create_timer(1).timeout #sfx antes de la onda y se espera
		AudioPlayer.sfx_ondita(3.0) #bajarle volumen a esta para subir el de la grande
		var spawn_pos = Vector2(
			spawn_point.global_position.x,
			randf_range(bottom_spawn.position.y, top_spawn.position.y))
		_spawn_sound_wave(sw_speed, sw_despawn_time, sw_scale, sw_push_power, spawn_pos)
		await get_tree().create_timer(sw_group_cd).timeout


func _spawn_big_sound_wave():
	#onda grande
	AudioPlayer.sfx_antes_onda(4.0)
	await get_tree().create_timer(1).timeout #sfx antes de la onda y se espera
	AudioPlayer.sfx_onda(7.0)
	_spawn_sound_wave(
		sw_big_speed, sw_big_despawn_time, sw_big_scale,
		sw_big_push_power, spawn_point.global_position)


func _spawn_sound_wave(speed: float, dp: float, sw_scale_val: float,
		push_power: float, pos: Vector2):
	var sw_instance = sound_wave.instantiate()
	sw_instance.speed = speed
	sw_instance.despawn_time = dp
	sw_instance.scale *= sw_scale_val
	sw_instance.push_power = push_power
	sw_instance.position = pos
	add_child(sw_instance)
