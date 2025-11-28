extends Node

@export var health: int = 3
@export var objects: Dictionary
@export var current_scene: PackedScene
@export var full_hp: CompressedTexture2D

var surf_beated: bool = false

var base_windows_size: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height"),
)


func _ready() -> void:
	load_scene(current_scene, false)
	_gui_show(false)


func _enter_tree() -> void:
	TranslationServer.set_locale("en")


func change_language(index: int) -> void:
	match index:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("es")


func load_scene_dialogic(scene: PackedScene, dialogic: String, is_game: bool) -> void:
	_gui_show(false)
	$Camera.follow_player = false
	hp_update(3)
	current_scene = scene
	Dialogic.start(dialogic)
	var scenes = $LoadedScene.get_children()
	if scenes:
		for i in range(0, scenes.size()):
			scenes[i].queue_free()

	await Dialogic.timeline_ended
	$LoadedScene.add_child(current_scene.instantiate())
	_gui_show(is_game)


func load_scene_cave(scene: PackedScene, dialogic: String, is_game: bool) -> void:
	_gui_show(false)
	$Camera.follow_player = false
	hp_update(3)
	current_scene = scene
	Dialogic.start(dialogic)
	var scenes = $LoadedScene.get_children()
	if scenes:
		for i in range(0, scenes.size()):
			scenes[i].queue_free()

	await Dialogic.timeline_ended
	if Dialogic.VAR.get_variable("said_ugly"):
		hp_add(-1)
	if surf_beated:
		hp_add(1)
	if Dialogic.VAR.get_variable("gave_up"):
		Dialogic.VAR.set_variable("gave_up", false)
		current_scene = load("res://Scenes/Main.tscn")
		$LoadedScene.add_child(current_scene.instantiate())
	else:
		$LoadedScene.add_child(current_scene.instantiate())
		_gui_show(is_game)


func load_scene(scene: PackedScene, is_game: bool) -> void:
	_gui_show(false)
	$Camera.follow_player = false
	hp_update(3)
	current_scene = scene

	var scenes = $LoadedScene.get_children()
	if scenes:
		for i in range(0, scenes.size()):
			scenes[i].queue_free()

	$LoadedScene.add_child(scene.instantiate())
	_gui_show(is_game)


func hp_update(number: int) -> void:
	health = number
	$Camera/GUI/Hearts.update_icons(health)


func hp_add(number: int) -> void:
	health = health + number
	if health <= 0:
		health = 1
	$Camera/GUI/Hearts.update_icons(health)


func _gui_show(is_visible: bool) -> void:
	$Camera/GUI.visible = is_visible
