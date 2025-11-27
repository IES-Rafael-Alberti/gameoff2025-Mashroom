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
<<<<<<< Updated upstream
	loadScene(currentScene)
	GuiShow(false)
=======
	load_scene(current_scene, false)
	_gui_show(false)

>>>>>>> Stashed changes

func _enter_tree() -> void:
	TranslationServer.set_locale("en")

func changeLanguage(index: int):
	match index:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("es")

<<<<<<< Updated upstream
func loadSceneDialogic(scene: PackedScene, dialogic: String):
	GuiShow(false)
	$Camera.followPlayer = false
=======

func load_scene_dialogic(scene: PackedScene, dialogic: String, isGame: bool):
	_gui_show(false)
	$Camera.follow_player = false
>>>>>>> Stashed changes
	if health <= 0:
		HpUpdate(3)
	currentScene = scene
	Dialogic.start(dialogic)
	var scenes = $LoadedScene.get_children()
	if scenes:
		for i in range(0,scenes.size()):
			scenes[i].queue_free()
	
	await Dialogic.timeline_ended
	$LoadedScene.add_child(scene.instantiate())
<<<<<<< Updated upstream
	GuiShow(true)
	

func loadScene(scene: PackedScene):
	GuiShow(false)
	$Camera.followPlayer = false
=======
	_gui_show(isGame)


func load_scene(scene: PackedScene, isGame: bool):
	_gui_show(false)
	$Camera.follow_player = false
>>>>>>> Stashed changes
	if health <= 0:
		HpUpdate(3)
	currentScene = scene
	
	var scenes = $LoadedScene.get_children()
	if scenes:
		for i in range(0,scenes.size()):
			scenes[i].queue_free()
			
	$LoadedScene.add_child(scene.instantiate())
<<<<<<< Updated upstream
	GuiShow(true)
	
func HpUpdate(number: int):
=======
	_gui_show(isGame)


func hp_update(number: int):
>>>>>>> Stashed changes
	if number > 3:
		number = 3
	health = number
	var heartsIcons = $Camera/GUI/Hearts.updateIcons(number)
	
func GuiShow(show: bool):
	$Camera/GUI.visible = show
