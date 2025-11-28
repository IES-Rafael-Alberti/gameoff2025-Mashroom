extends Node2D

@export_group("Basics")
@export var intervals: int = 4
@export var transition_total_duration: float = 60.0
@export var transition_duration: float = 1.2
@export var time_before_ending: float = 5.0

@export_group("Complex")
@export var auto_cycle: bool = true
@export var start_phase: int = 0
@export var player_colors: Array[String] = ["ffffff", "d8e3ec", "bfd2e7fe", "75a4cafe"]

@export_group("Objects")
@export var player: CharacterBody2D
@export var spawner: Node2D
@export var min_pos: Marker2D
@export var max_pos: Marker2D

# Texture paths organized by phase and type
var sky_textures: Array[Texture2D] = [
	preload("res://assets/SurfMinigame/Ocean/Phase1/sky1.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase2/sky2.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase3/sky3.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase4/sky4.png"),
]
var clouds_textures: Array[Texture2D] = [
	preload("res://assets/SurfMinigame/Ocean/Phase1/clouds1.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase2/clouds2.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase3/clouds3.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase4/clouds4.png"),
]
var water_textures: Array[Texture2D] = [
	preload("res://assets/SurfMinigame/Ocean/Phase1/water1.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase2/water2.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase3/water3.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase4/water4.png"),
]
var wave_textures: Array[Texture2D] = [
	preload("res://assets/SurfMinigame/Ocean/Phase1/wave1.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase2/wave2.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase3/wave3.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase4/wave4.png"),
]
var shadow_textures: Array[Texture2D] = [
	preload("res://assets/SurfMinigame/Ocean/Phase1/shadow1.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase2/shadow2.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase3/shadow3.png"),
	preload("res://assets/SurfMinigame/Ocean/Phase4/shadow4.png"),
]

var _current_phase: int = 1

# Cache shader path so we don't call load repeatedly
const TRANSITION_SHADER_PATH := "res://assets/Shaders/Transition_between_two_textures.gdshader"


func _ready() -> void:
	player.limit_min = min_pos.position.x
	player.limit_max = max_pos.position.x
	spawner.limit_min = min_pos.position.x
	spawner.limit_max = max_pos.position.x
	spawner.height_start = min_pos.position.y
	spawner.height_end = max_pos.position.y

	start_background_cycle()


func start_background_cycle() -> void:
	var dur: float = transition_total_duration / intervals
	while _current_phase < intervals:
		await get_tree().create_timer(dur).timeout
		_current_phase += 1
		transition_sprite(
			get_node("Oleaje/BackGround/Sky"),
			_get_texture_for_phase(sky_textures, _current_phase - 1),
			transition_duration,
		)
		transition_sprite(
			get_node("Oleaje/BackGround/Clouds"),
			_get_texture_for_phase(clouds_textures, _current_phase - 1),
			transition_duration,
		)
		transition_sprite(
			get_node("Oleaje/BackGround/Water"),
			_get_texture_for_phase(water_textures, _current_phase - 1),
			transition_duration,
		)
		transition_sprite(
			get_node("Oleaje/Foreground/Wave"),
			_get_texture_for_phase(wave_textures, _current_phase - 1),
			transition_duration,
		)
		transition_sprite(
			get_node("Oleaje/Foreground/Shadow"),
			_get_texture_for_phase(shadow_textures, _current_phase - 1),
			transition_duration,
		)

		create_tween().tween_property(
			player,
			"modulate",
			Color(player_colors[_current_phase - 1]),
			1,
		)

		create_tween().tween_property(
			spawner,
			"modulate",
			Color(player_colors[_current_phase - 1]),
			1,
		)

		await get_tree().create_timer(transition_duration).timeout
		print(_current_phase)

	await get_tree().create_timer(dur).timeout
	spawner.active = false
	await get_tree().create_timer(time_before_ending).timeout
	# Here spawns the monster
	spawner.spawn_kumi()


func transition_sprite(
		sprite: Sprite2D,
		new_texture: Texture2D,
		duration: float,
) -> Signal:
	var shader_res = load(TRANSITION_SHADER_PATH)
	if shader_res == null:
		push_error("Transition shader not found")
		# Return a dummy signal if shader fails, to avoid crashes on await
		return get_tree().process_frame

	var mat: ShaderMaterial
	# Reuse existing ShaderMaterial if possible so we keep the material persistent
	var mat_candidate = sprite.material
	if mat_candidate and mat_candidate is ShaderMaterial and mat_candidate.shader == shader_res:
		mat = mat_candidate
	else:
		mat = ShaderMaterial.new()
		mat.shader = shader_res
		# set texture_1 from the visible sprite texture at first use
		mat.set_shader_parameter("texture_1", sprite.texture)

	# Set up the new target texture and start with transform_ratio = 1.0 (show texture_1)
	mat.set_shader_parameter("texture_2", new_texture)
	mat.set_shader_parameter("transform_ratio", 1.0)
	sprite.material = mat

	var tween = create_tween()
	tween.tween_property(
		mat,
		"shader_parameter/transform_ratio",
		0.0,
		duration,
	)

	# When the tween finishes, update the shader so texture_2 becomes the base.
	# Use a bound Callable to pass the material and new texture.
	var cb = Callable(self, "_on_transition_finished").bind(mat, new_texture)
	tween.connect("finished", cb)

	# Return the tween's finished FunctionState so callers can await it if desired.
	return tween.finished


func _apply_phase_instant(
		sky_sprite: Sprite2D,
		clouds_sprite: Sprite2D,
		ocean_sprite: Sprite2D,
		wave_sprite: Sprite2D,
		shadow_sprite: Sprite2D,
		phase_index: int,
) -> void:
	# Immediately apply the provided phase textures to sprites using persistent ShaderMaterial
	var shader_res = load(TRANSITION_SHADER_PATH)
	if shader_res == null:
		return

	if sky_sprite and sky_textures.size() > phase_index:
		var m = ShaderMaterial.new()
		m.shader = shader_res
		m.set_shader_parameter("texture_1", sky_textures[phase_index])
		m.set_shader_parameter("transform_ratio", 1.0)
		sky_sprite.material = m
	if clouds_sprite and clouds_textures.size() > phase_index:
		var mc = ShaderMaterial.new()
		mc.shader = shader_res
		mc.set_shader_parameter("texture_1", clouds_textures[phase_index])
		mc.set_shader_parameter("transform_ratio", 1.0)
		clouds_sprite.material = mc
	if ocean_sprite and water_textures.size() > phase_index:
		var mo = ShaderMaterial.new()
		mo.shader = shader_res
		mo.set_shader_parameter("texture_1", water_textures[phase_index])
		mo.set_shader_parameter("transform_ratio", 1.0)
		ocean_sprite.material = mo
	if wave_sprite and wave_textures.size() > phase_index:
		var mw = ShaderMaterial.new()
		mw.shader = shader_res
		mw.set_shader_parameter("texture_1", wave_textures[phase_index % wave_textures.size()])
		mw.set_shader_parameter("transform_ratio", 1.0)
		wave_sprite.material = mw
	if shadow_sprite and shadow_textures.size() > phase_index:
		var ms = ShaderMaterial.new()
		ms.shader = shader_res
		var sh_tex = shadow_textures[phase_index % shadow_textures.size()]
		ms.set_shader_parameter("texture_1", sh_tex)
		ms.set_shader_parameter("transform_ratio", 1.0)
		shadow_sprite.material = ms


func _get_texture_for_phase(list: Array[Texture2D], index: int) -> Texture2D:
	# Safe lookup: if the requested index is within bounds, return it. Otherwise
	# return the last available texture (so missing entries fall back to final phase).
	if list == null or list.size() == 0:
		return null
	if index < 0:
		return list[0]
	if index < list.size():
		return list[index]
	return list[list.size() - 1]


func _ensure_default_phase(
		sky_sprite: Sprite2D,
		clouds_sprite: Sprite2D,
		ocean_sprite: Sprite2D,
		wave_sprite: Sprite2D,
		shadow_sprite: Sprite2D,
) -> void:
	pass
	# Insert the currently visible texture as the first phase if not already present.
	# Textures are now preloaded at class initialization


func _on_transition_finished(mat: ShaderMaterial, new_texture: Texture2D) -> void:
	if mat == null:
		return
	mat.set_shader_parameter("texture_1", new_texture)
	mat.set_shader_parameter("transform_ratio", 1.0)


func transition_to_phase(index: int, stop_cycle: bool = false) -> void:
	# Immediately transition sprites to the specified phase index.
	var sky_sprite: Sprite2D = get_node_or_null("Oleaje/BackGround/Sky")
	var clouds_sprite: Sprite2D = get_node_or_null("Oleaje/BackGround/Clouds")
	var ocean_sprite: Sprite2D = get_node_or_null("Oleaje/BackGround/Water")
	var wave_sprite: Sprite2D = get_node_or_null("Oleaje/Foreground/Wave")
	var shadow_sprite: Sprite2D = get_node_or_null("Oleaje/Foreground/Shadow")

	if index < 0:
		return

	if sky_textures.size() == 0:
		return

	index = index % sky_textures.size()

	var pending := []
	pending.append(
		transition_sprite(
			sky_sprite,
			_get_texture_for_phase(sky_textures, index),
			transition_duration,
		),
	)
	if clouds_textures.size() > 0 and clouds_sprite:
		pending.append(
			transition_sprite(
				clouds_sprite,
				_get_texture_for_phase(clouds_textures, index),
				transition_duration,
			),
		)
	if water_textures.size() > 0 and ocean_sprite:
		pending.append(
			transition_sprite(
				ocean_sprite,
				_get_texture_for_phase(water_textures, index),
				transition_duration,
			),
		)
	if wave_textures.size() > 0 and wave_sprite:
		pending.append(
			transition_sprite(
				wave_sprite,
				_get_texture_for_phase(wave_textures, index),
				transition_duration,
			),
		)
	if shadow_textures.size() > 0 and shadow_sprite:
		pending.append(
			transition_sprite(
				shadow_sprite,
				_get_texture_for_phase(shadow_textures, index),
				transition_duration,
			),
		)

	for p in pending:
		await p
