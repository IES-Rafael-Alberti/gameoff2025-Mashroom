extends Node


@export var health = 3
@export var objects : Dictionary
@export var currentScene: PackedScene

var baseWindowsSize = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)

func _enter_tree() -> void:
	TranslationServer.set_locale("en")

func _on_language_option_button_item_selected(index: int) -> void:
	match index:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("es")

func _ready():
	loadScene(currentScene)

func loadSceneDialogic(scene: PackedScene, dialogic: String):
	if health <= 0:
		health = 1
	currentScene = scene
	Dialogic.start(dialogic)
	var scenes = $LoadedScene.get_children()
	if scenes:
		for i in range(0,scenes.size()):
			scenes[i].queue_free()
	
	await Dialogic.timeline_ended
	$LoadedScene.add_child(scene.instantiate())
	

func loadScene(scene: PackedScene):
	if health <= 0:
		health = 1
	currentScene = scene
	
	var scenes = $LoadedScene.get_children()
	if scenes:
		for i in range(0,scenes.size()):
			scenes[i].queue_free()
			
	$LoadedScene.add_child(scene.instantiate())

#func HpUpdate():
#	var hearts = 
