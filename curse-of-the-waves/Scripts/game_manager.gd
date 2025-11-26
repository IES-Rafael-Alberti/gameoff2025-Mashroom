extends Node


@export var health = 3
@export var objects: Dictionary
@export var current_scene: PackedScene
@export var full_hp: CompressedTexture2D

var base_windows_size = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)


func _ready():
	load_scene(current_scene)
	_gui_show(false)


func _enter_tree() -> void:
	TranslationServer.set_locale("en")


func change_language(index: int):
	match index:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("es")


func load_scene_dialogic(scene: PackedScene, dialogic: String):
	_gui_show(false)
	$Camera.follow_player = false
	if health <= 0:
		hp_update(3)
	current_scene = scene
	Dialogic.start(dialogic)
	var scenes = $LoadedScene.get_children()
	if scenes:
		for i in range(0, scenes.size()):
			scenes[i].queue_free()

	await Dialogic.timeline_ended
	$LoadedScene.add_child(scene.instantiate())
	_gui_show(true)


func load_scene(scene: PackedScene):
	_gui_show(false)
	$Camera.follow_player = false
	if health <= 0:
		hp_update(3)
	current_scene = scene

	var scenes = $LoadedScene.get_children()
	if scenes:
		for i in range(0, scenes.size()):
			scenes[i].queue_free()

	$LoadedScene.add_child(scene.instantiate())
	_gui_show(true)


func hp_update(number: int):
	if number > 3:
		number = 3
	health = number
	$Camera/GUI/Hearts.update_icons(number)


func _gui_show(visible: bool):
	$Camera/GUI.visible = visible
