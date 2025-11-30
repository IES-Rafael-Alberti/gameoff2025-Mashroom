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

const CONFIG_FILE_PATH: String = "user://game_settings.cfg"
var config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	load_scene(current_scene, false)
	gui_show(false)


func _enter_tree() -> void:
	_load_language_preference()


func _load_language_preference() -> void:
	var locale: String = "en"
	
	if OS.get_name() == "Web":
		locale = _load_language_from_localstorage()
	else:
		locale = _load_language_from_configfile()
	
	TranslationServer.set_locale(locale)


func _load_language_from_configfile() -> String:
	var error = config.load(CONFIG_FILE_PATH)
	if error == OK:
		return config.get_value("language", "locale", "en")
	return "en"


func _load_language_from_localstorage() -> String:
	if OS.get_name() == "Web":
		var result = JavaScriptBridge.eval("localStorage.getItem('game_language') || 'en'")
		return result if result else "en"
	return "en"


func change_language(index: int) -> void:
	var locale: String = ""
	match index:
		0:
			locale = "en"
		1:
			locale = "es"
	
	if locale != "":
		TranslationServer.set_locale(locale)
		_save_language_preference(locale)


func _save_language_preference(locale: String) -> void:
	if OS.get_name() == "Web":
		_save_language_to_localstorage(locale)
	else:
		_save_language_to_configfile(locale)


func _save_language_to_configfile(locale: String) -> void:
	config.set_value("language", "locale", locale)
	config.save(CONFIG_FILE_PATH)


func _save_language_to_localstorage(locale: String) -> void:
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("localStorage.setItem('game_language', '" + locale + "')")


func load_scene_dialogic(scene: PackedScene, dialogic: String, is_game: bool) -> void:
	gui_show(false)
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
	gui_show(is_game)


func load_scene_cave(scene: PackedScene, dialogic: String, is_game: bool) -> void:
	gui_show(false)
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
		gui_show(is_game)


func load_scene(scene: PackedScene, is_game: bool) -> void:
	gui_show(false)
	$Camera.follow_player = false
	hp_update(3)
	current_scene = scene

	var scenes = $LoadedScene.get_children()
	if scenes:
		for i in range(0, scenes.size()):
			scenes[i].queue_free()

	$LoadedScene.add_child(scene.instantiate())
	gui_show(is_game)


func hp_update(number: int) -> void:
	health = number
	$Camera/GUI/Hearts.update_icons(health)


func hp_add(number: int) -> void:
	health = health + number
	if health <= 0:
		health = 1
	$Camera/GUI/Hearts.update_icons(health)


func gui_show(is_visible: bool) -> void:
	$Camera/GUI.visible = is_visible
