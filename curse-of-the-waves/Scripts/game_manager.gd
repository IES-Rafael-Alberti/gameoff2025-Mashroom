extends Node


@export var health = 3
@export var objects : Dictionary
@export var currentScene: PackedScene
@export var FullHP: CompressedTexture2D

var baseWindowsSize = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)
func _ready():
	loadScene(currentScene)
	GuiShow(false)

func _enter_tree() -> void:
	TranslationServer.set_locale("en")

func changeLanguage(index: int):
	match index:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("es")

func loadSceneDialogic(scene: PackedScene, dialogic: String):
	GuiShow(false)
	if health <= 0:
		HpUpdate(1)
	currentScene = scene
	Dialogic.start(dialogic)
	var scenes = $LoadedScene.get_children()
	if scenes:
		for i in range(0,scenes.size()):
			scenes[i].queue_free()
	
	await Dialogic.timeline_ended
	$LoadedScene.add_child(scene.instantiate())
	GuiShow(true)
	

func loadScene(scene: PackedScene):
	GuiShow(false)
	if health <= 0:
		HpUpdate(1)
	currentScene = scene
	
	var scenes = $LoadedScene.get_children()
	if scenes:
		for i in range(0,scenes.size()):
			scenes[i].queue_free()
			
	$LoadedScene.add_child(scene.instantiate())
	GuiShow(true)
	
func HpUpdate(number: int):
	if number > 3:
		number = 3
	health = number
	var heartsIcons = $GUI/Hearts.updateIcons(number)
	
func GuiShow(show: bool):
	$GUI.visible = show
