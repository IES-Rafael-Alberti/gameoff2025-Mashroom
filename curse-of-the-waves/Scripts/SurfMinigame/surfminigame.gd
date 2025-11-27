extends Node2D

@export_group("Objects")
@export var player: CharacterBody2D
@export var spawner: Node2D
@export var min_pos: Marker2D
@export var max_pos: Marker2D


func _ready():
	player.limit_min = min_pos.position.x
	player.limit_max = max_pos.position.x
	spawner.limit_min = min_pos.position.x
	spawner.limit_max = max_pos.position.x
	spawner.height_start = min_pos.position.y
	spawner.height_end = max_pos.position.y

	# Start automatic background/asset transitions for the surf minigame.
	# This will cycle the Sky, Clouds and Ocean sprites through phase textures
	# using the `Transition_between_two_textures.gdshader` shader.
	start_background_cycle()


@export var transition_interval: float = 5.0
@export var transition_duration: float = 1.2

# Inspector-editable phase texture lists. Populate these in the Inspector to
# avoid modifying the code when adding/removing phases.
@export var phase_sky_textures: Array[Texture2D] = []
@export var phase_clouds_textures: Array[Texture2D] = []
@export var phase_ocean_textures: Array[Texture2D] = []
@export var phase_wave_textures: Array[Texture2D] = []
@export var phase_shadow_textures: Array[Texture2D] = []

@export var auto_cycle: bool = true
@export var start_phase: int = 0

# Optional array of NodePaths you can populate in the Inspector to choose which
# nodes will be transitioned. Order convention (if used):
# [Sky, Clouds, Ocean, Wave, Shadow]
@export var transition_nodes: Array[NodePath] = []

var _sky_textures: Array = []
var _ocean_textures: Array = []
var _clouds_textures: Array = []
var _wave_textures: Array = []
var _shadow_textures: Array = []

var _current_phase: int = 0
var _cycle_running: bool = false

# Cache shader path so we don't call load repeatedly
const TRANSITION_SHADER_PATH := "res://assets/Shaders/Transition_between_two_textures.gdshader"

func _init_phase_textures() -> void:
	# Prefer inspector arrays when provided.
	if phase_sky_textures.size() > 0:
		_sky_textures = phase_sky_textures.duplicate()
	else:
		_sky_textures = [
			load("res://assets/SurfMinigame/Ocean/Phase1/sky1.png"),
			load("res://assets/SurfMinigame/Ocean/Phase2/sky2.png"),
			load("res://assets/SurfMinigame/Ocean/Phase3/sky3.png"),
			load("res://assets/SurfMinigame/Ocean/Phase4/sky4.png")
		]

	if phase_ocean_textures.size() > 0:
		_ocean_textures = phase_ocean_textures.duplicate()
	else:
		_ocean_textures = [
			load("res://assets/SurfMinigame/Ocean/Phase1/water1.png"),
			load("res://assets/SurfMinigame/Ocean/Phase2/water2.png"),
			load("res://assets/SurfMinigame/Ocean/Phase3/water3.png"),
			load("res://assets/SurfMinigame/Ocean/Phase4/water4.png")
		]

	if phase_clouds_textures.size() > 0:
		_clouds_textures = phase_clouds_textures.duplicate()
	else:
		_clouds_textures = [
			load("res://assets/SurfMinigame/Ocean/Phase1/clouds1.png"),
			load("res://assets/SurfMinigame/Ocean/Phase2/clouds2.png"),
			load("res://assets/SurfMinigame/Ocean/Phase3/clouds3.png"),
			load("res://assets/SurfMinigame/Ocean/Phase4/clouds4.png")
		]

	# Optional wave/shadow lists (may be empty)
	if phase_wave_textures.size() > 0:
		_wave_textures = phase_wave_textures.duplicate()
	else:
		_wave_textures = []

	if phase_shadow_textures.size() > 0:
		_shadow_textures = phase_shadow_textures.duplicate()
	else:
		_shadow_textures = [
			load("res://assets/SurfMinigame/Ocean/Phase1/shadow1.png"),
			load("res://assets/SurfMinigame/Ocean/Phase2/shadow2.png"),
			load("res://assets/SurfMinigame/Ocean/Phase3/shadow3.png"),
			load("res://assets/SurfMinigame/Ocean/Phase4/shadow4.png")
		]

	# Provide sensible defaults for wave textures if none supplied.
	if _wave_textures.size() == 0:
		_wave_textures = [
			load("res://assets/SurfMinigame/Ocean/Phase1/wave1.png"),
			load("res://assets/SurfMinigame/Ocean/Phase2/wave2.png"),
			load("res://assets/SurfMinigame/Ocean/Phase3/wave3.png"),
			load("res://assets/SurfMinigame/Ocean/Phase4/wave4.png")
		]


func start_background_cycle() -> void:
	_init_phase_textures()
	# Find the sprites inside this scene. You may supply `transition_nodes` in
	# the Inspector (preferred) or the code will fall back to the default paths.
	var sky_sprite: Sprite2D
	var clouds_sprite: Sprite2D
	var ocean_sprite: Sprite2D
	if transition_nodes.size() >= 3:
		sky_sprite = get_node_or_null(transition_nodes[0])
		clouds_sprite = get_node_or_null(transition_nodes[1])
		ocean_sprite = get_node_or_null(transition_nodes[2])
	else:
		sky_sprite = get_node_or_null("Oleaje/BackGround/Sky")
		clouds_sprite = get_node_or_null("Oleaje/BackGround/Clouds")
		ocean_sprite = get_node_or_null("Oleaje/BackGround/Water")

	if not sky_sprite or not ocean_sprite:
		push_warning("SurfMinigame: required sprites not found.")
		push_warning("  Sky: %s  Ocean: %s" % [sky_sprite, ocean_sprite])
		return # scene layout changed; abort silently.

	print("SurfMinigame: starting background cycle.")
	print("  auto_cycle: %s" % auto_cycle)
	print("  start_phase: %d" % start_phase)
	print("  phases: %d" % _sky_textures.size())

	# Start background cycling (if enabled).
	_current_phase = clamp(start_phase, 0, max(0, _sky_textures.size() - 1))

	# Prepare wave/shadow sprites here so we can set initial textures immediately
	var wave_sprite: Sprite2D
	var shadow_sprite: Sprite2D
	if transition_nodes.size() >= 5:
		wave_sprite = get_node_or_null(transition_nodes[3])
		shadow_sprite = get_node_or_null(transition_nodes[4])
	else:
		wave_sprite = get_node_or_null("Oleaje/Foreground/Wave")
		shadow_sprite = get_node_or_null("Oleaje/Foreground/Shadow")

	# Ensure the current textures are included as the first phase (default assets)
	_ensure_default_phase(
		sky_sprite,
		clouds_sprite,
		ocean_sprite,
		wave_sprite,
		shadow_sprite
	)

	# Apply the starting phase immediately so the scene shows the correct visuals
	_apply_phase_instant(
		sky_sprite,
		clouds_sprite,
		ocean_sprite,
		wave_sprite,
		shadow_sprite,
		_current_phase
	)

	if auto_cycle:
		_cycle_running = true
		_background_cycle(
			sky_sprite,
			clouds_sprite,
			ocean_sprite,
			wave_sprite,
			shadow_sprite,
			_current_phase
		)


func _background_cycle(
		sky_sprite: Sprite2D,
		clouds_sprite: Sprite2D,
		ocean_sprite: Sprite2D,
		wave_sprite: Sprite2D,
		shadow_sprite: Sprite2D,
		phase_index: int
	) -> void:
	# Wait initial interval before the first transition so the first change is delayed
	await get_tree().create_timer(transition_interval).timeout

	while _cycle_running:
		var last_index: int = _sky_textures.size() - 1
		# If we're already at the last phase, stop cycling
		if phase_index >= last_index:
			print("SurfMinigame: reached final phase %d - stopping cycle" % phase_index)
			_cycle_running = false
			break

		var next_index: int = phase_index + 1

		var pending := []

		# Sky / clouds / ocean
		if _sky_textures.size() > 0:
			var p_sky = transition_sprite(
				sky_sprite,
				_get_texture_for_phase(_sky_textures, next_index),
				transition_duration
			)
			pending.append(p_sky)
		if _clouds_textures.size() > 0 and clouds_sprite:
			var p_clouds = transition_sprite(
				clouds_sprite,
				_get_texture_for_phase(_clouds_textures, next_index),
				transition_duration
			)
			pending.append(p_clouds)
		if _ocean_textures.size() > 0:
			var p_ocean = transition_sprite(
				ocean_sprite,
				_get_texture_for_phase(_ocean_textures, next_index),
				transition_duration
			)
			pending.append(p_ocean)

		# Optional Wave / Shadow from Foreground (use parameters passed in)
		if _wave_textures.size() > 0 and wave_sprite:
			var p_wave = transition_sprite(
				wave_sprite,
				_get_texture_for_phase(_wave_textures, next_index),
				transition_duration
			)
			pending.append(p_wave)
		if _shadow_textures.size() > 0 and shadow_sprite:
			var p_shadow = transition_sprite(
				shadow_sprite,
				_get_texture_for_phase(_shadow_textures, next_index),
				transition_duration
			)
			pending.append(p_shadow)

		# Await all transitions
		for p in pending:
			if p:
				# p is a FunctionState returned by transition_sprite; await it
				await p

		phase_index = next_index
		_current_phase = phase_index
		print("SurfMinigame: completed transition to phase %d" % phase_index)

		await get_tree().create_timer(transition_interval).timeout


func transition_sprite(
		sprite: Sprite2D,
		new_texture: Texture2D,
		duration: float
	):
	var shader_res = load(TRANSITION_SHADER_PATH)
	if shader_res == null:
		push_error("Transition shader not found")
		return null

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
		duration
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
		phase_index: int
	) -> void:
	# Immediately apply the provided phase textures to sprites using persistent ShaderMaterial
	var shader_res = load(TRANSITION_SHADER_PATH)
	if shader_res == null:
		return

	if sky_sprite and _sky_textures.size() > phase_index:
		var m = ShaderMaterial.new()
		m.shader = shader_res
		m.set_shader_parameter("texture_1", _sky_textures[phase_index])
		m.set_shader_parameter("transform_ratio", 1.0)
		sky_sprite.material = m
	if clouds_sprite and _clouds_textures.size() > phase_index:
		var mc = ShaderMaterial.new()
		mc.shader = shader_res
		mc.set_shader_parameter("texture_1", _clouds_textures[phase_index])
		mc.set_shader_parameter("transform_ratio", 1.0)
		clouds_sprite.material = mc
	if ocean_sprite and _ocean_textures.size() > phase_index:
		var mo = ShaderMaterial.new()
		mo.shader = shader_res
		mo.set_shader_parameter("texture_1", _ocean_textures[phase_index])
		mo.set_shader_parameter("transform_ratio", 1.0)
		ocean_sprite.material = mo
	if wave_sprite and _wave_textures.size() > phase_index:
		var mw = ShaderMaterial.new()
		mw.shader = shader_res
		mw.set_shader_parameter("texture_1", _wave_textures[phase_index % _wave_textures.size()])
		mw.set_shader_parameter("transform_ratio", 1.0)
		wave_sprite.material = mw
	if shadow_sprite and _shadow_textures.size() > phase_index:
		var ms = ShaderMaterial.new()
		ms.shader = shader_res
		var sh_tex = _shadow_textures[phase_index % _shadow_textures.size()]
		ms.set_shader_parameter("texture_1", sh_tex)
		ms.set_shader_parameter("transform_ratio", 1.0)
		shadow_sprite.material = ms


func _get_texture_for_phase(list: Array, index: int):
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
		shadow_sprite: Sprite2D
	) -> void:
	# Insert the currently visible texture as the first phase if not already present.
	if sky_sprite:
		var cur = sky_sprite.texture
		if _sky_textures.size() == 0:
			_sky_textures.insert(0, cur)
		elif _sky_textures[0] != cur:
			_sky_textures.insert(0, cur)

	if clouds_sprite:
		var curc = clouds_sprite.texture
		if _clouds_textures.size() == 0:
			_clouds_textures.insert(0, curc)
		elif _clouds_textures[0] != curc:
			_clouds_textures.insert(0, curc)

	if ocean_sprite:
		var curo = ocean_sprite.texture
		if _ocean_textures.size() == 0:
			_ocean_textures.insert(0, curo)
		elif _ocean_textures[0] != curo:
			_ocean_textures.insert(0, curo)

	if wave_sprite:
		var curw = wave_sprite.texture
		if _wave_textures.size() == 0:
			_wave_textures.insert(0, curw)
		elif _wave_textures[0] != curw:
			_wave_textures.insert(0, curw)

	if shadow_sprite:
		var curs = shadow_sprite.texture
		if _shadow_textures.size() == 0:
			_shadow_textures.insert(0, curs)
		elif _shadow_textures[0] != curs:
			_shadow_textures.insert(0, curs)


func _on_transition_finished(mat: ShaderMaterial, new_texture: Texture2D) -> void:
	if mat == null:
		return
	mat.set_shader_parameter("texture_1", new_texture)
	mat.set_shader_parameter("transform_ratio", 1.0)


func transition_to_phase(index: int, stop_cycle: bool=false) -> void:
	# Immediately transition sprites to the specified phase index.
	var sky_sprite: Sprite2D = get_node_or_null("Oleaje/BackGround/Sky")
	var clouds_sprite: Sprite2D = get_node_or_null("Oleaje/BackGround/Clouds")
	var ocean_sprite: Sprite2D = get_node_or_null("Oleaje/BackGround/Water")
	var wave_sprite: Sprite2D = get_node_or_null("Oleaje/Foreground/Wave")
	var shadow_sprite: Sprite2D = get_node_or_null("Oleaje/Foreground/Shadow")

	if index < 0:
		return

	if _sky_textures.size() == 0:
		return

	index = index % _sky_textures.size()

	if stop_cycle:
		_cycle_running = false

	var pending := []
	pending.append(
		transition_sprite(
			sky_sprite,
			_get_texture_for_phase(_sky_textures, index),
			transition_duration
		)
	)
	if _clouds_textures.size() > 0 and clouds_sprite:
		pending.append(
			transition_sprite(
				clouds_sprite,
				_get_texture_for_phase(_clouds_textures, index),
				transition_duration
			)
		)
	if _ocean_textures.size() > 0 and ocean_sprite:
		pending.append(
			transition_sprite(
				ocean_sprite,
				_get_texture_for_phase(_ocean_textures, index),
				transition_duration
			)
		)
	if _wave_textures.size() > 0 and wave_sprite:
		pending.append(
			transition_sprite(
				wave_sprite,
				_get_texture_for_phase(_wave_textures, index),
				transition_duration
			)
		)
	if _shadow_textures.size() > 0 and shadow_sprite:
		pending.append(
			transition_sprite(
				shadow_sprite,
				_get_texture_for_phase(_shadow_textures, index),
				transition_duration
			)
		)

	for p in pending:
		await p

	_current_phase = index
