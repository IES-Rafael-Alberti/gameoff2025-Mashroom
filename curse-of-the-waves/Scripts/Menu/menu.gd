extends Control

@export_group("Objects")
@export var OptionsContainer: Control
@export var Controls: HBoxContainer

var changeControl = ""
var changeButton: Button

func _ready():
	AudioPlayer.musicNivel()
	startUpdateButtons()
	$PlayButton.grab_focus()

func _on_play_button_pressed() -> void:
	AudioPlayer.stopMusic()
	AudioPlayer.pulsarBtn()
	$PlayButton.focus_mode  = Control.FOCUS_NONE
	$OptionsButton.focus_mode  = Control.FOCUS_NONE
	var GameManager = get_tree().get_root().get_node("Main/GameManager")
	#GameManager.loadSceneDialogic(preload("res://Scenes/SurfMinigame/SurfMinigame.tscn"), '1-prologue')
	GameManager.loadScene(preload("res://Scenes/CaveMinigame/CaveGame.tscn"))

func _on_options_button_pressed():
	AudioPlayer.pulsarBtn()
	OptionsContainer.showOptionMenu(true)
	$PlayButton.focus_mode  = Control.FOCUS_NONE
	$OptionsButton.focus_mode  = Control.FOCUS_NONE
	
func _on_back_button_pressed():
	AudioPlayer.pulsarBtn()
	await OptionsContainer.showOptionMenu(false)
	$PlayButton.focus_mode  = Control.FOCUS_ALL
	$OptionsButton.focus_mode  = Control.FOCUS_ALL 
	$OptionsButton.grab_focus()

func _on_option_button_item_selected(index):
	var GameManager = get_tree().get_root().get_node("Main/GameManager")
	GameManager.changeLanguage(index)
	
func _input(event):
	if event is InputEventKey and changeControl != "":
		InputMap.action_erase_events(changeControl)
		InputMap.action_add_event(changeControl, event)
		updateButton(changeButton, changeControl)
	
func updateButton(button: Button, movement: String):
	var events = InputMap.action_get_events(movement)
	if events.size() > 0:
		button.text = events[0].as_text()
	else: button.text = ""
	button.button_pressed = false

func selectChange(button: Button, toggle: bool, movement: String):
	if toggle:
		if changeButton:
			changeButton.button_pressed = false
		changeControl = movement
		changeButton = button
		button.text = "ui_pressKey"
	else:
		changeButton = null
		changeControl = ""
		updateButton(button, movement)

func _on_up_button_toggled(toggled_on):
	var button = Controls.get_node("MovementVBox/UpHBox/UpButton")
	selectChange(button, toggled_on, "move_up")

func _on_down_button_toggled(toggled_on):
	var button = Controls.get_node("MovementVBox/DownHBox/DownButton")
	selectChange(button, toggled_on, "move_down")

func _on_left_button_toggled(toggled_on):
	var button = Controls.get_node("MovementVBox/LeftHBox/LeftButton")
	selectChange(button, toggled_on, "move_left")

func _on_right_button_toggled(toggled_on):
	var button = Controls.get_node("MovementVBox/RightHBox/RightButton")
	selectChange(button, toggled_on, "move_right")

func _on_main_button_toggled(toggled_on):
	var button = Controls.get_node("ActionVBox/MainHBox/MainButton")
	selectChange(button, toggled_on, "MainAction")

func _on_second_button_toggled(toggled_on):
	var button = Controls.get_node("ActionVBox/SecondaryHBox/SecondButton")
	selectChange(button, toggled_on, "SecondaryAction")

func startUpdateButtons():
	var Buttons = ["MovementVBox/UpHBox/UpButton", "MovementVBox/DownHBox/DownButton",
	"MovementVBox/LeftHBox/LeftButton", "MovementVBox/RightHBox/RightButton",
	"ActionVBox/MainHBox/MainButton", "ActionVBox/SecondaryHBox/SecondButton"]
	for buttonURL in Buttons:
		var button = Controls.get_node(buttonURL)
		updateButton(button, button.text)
