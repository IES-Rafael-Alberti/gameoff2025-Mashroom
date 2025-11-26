extends Control

@export_group("Objects")
@export var OptionsContainer: Control
@export var Options: Control
@export var Controls: Control

@onready var play_button: Button = $PlayButton
@onready var options_button: Button = $OptionsButton

var changeControl = ""
var changeButton: Button

func _ready():
	AudioPlayer.musicNivel()
	startUpdateButtons()
	if play_button:
		play_button.grab_focus()

func _on_play_button_pressed() -> void:
	AudioPlayer.stopMusic()
	AudioPlayer.pulsarBtn()
	if play_button:
		play_button.focus_mode = Control.FOCUS_NONE
	if options_button:
		options_button.focus_mode = Control.FOCUS_NONE
	var GameManager = get_tree().get_root().get_node("Main/GameManager")
	GameManager.loadSceneDialogic(preload("res://Scenes/SurfMinigame/SurfMinigame.tscn"), '1-prologue')
	#GameManager.loadScene(preload("res://Scenes/CaveMinigame/CaveGame.tscn"))

func _on_options_button_pressed():
	AudioPlayer.pulsarBtn()
	OptionsContainer.showOptionMenu(true)
	if play_button:
		play_button.focus_mode = Control.FOCUS_NONE
	if options_button:
		options_button.focus_mode = Control.FOCUS_NONE
	
func _on_exit_button_pressed():
	AudioPlayer.pulsarBtn()
	await OptionsContainer.showOptionMenu(false)
	if play_button:
		play_button.focus_mode = Control.FOCUS_ALL
	if options_button:
		options_button.focus_mode = Control.FOCUS_ALL 
		options_button.grab_focus()
	

func _on_option_button_item_selected(index):
	var GameManager = get_tree().get_root().get_node("Main/GameManager")
	GameManager.changeLanguage(index)
	
func _input(event):
	if event.is_released():
		if event is InputEventKey and changeControl != "" and getControlType(changeButton) == 0:
			changeInput(event, "Keyboard")
			changeControl = ""
		elif (event is InputEventJoypadButton or (event is InputEventJoypadMotion and abs(event.axis_value) > 0.3)) and changeControl != "" and getControlType(changeButton) == 1:
			changeInput(event, "Joystick")
			changeControl = ""

func removeEvent(action: String, type: String):
	var events := InputMap.action_get_events(action)

	for e in events:
		if (type == "Joystick" and e is InputEventJoypadButton or e is InputEventJoypadMotion) or (type == "Keyboard" and e is InputEventKey):
			InputMap.action_erase_event(action, e)
			

func changeInput(event, type):
	removeEvent(changeControl, type)
	InputMap.action_add_event(changeControl, event)
	match changeControl:
		"MainAction":
			removeEvent("ui_accept", type)
			InputMap.action_add_event("ui_accept", event)
		"move_left":
			removeEvent("ui_left", type)
			InputMap.action_add_event("ui_left", event)
		"move_right":
			removeEvent("ui_right", type)
			InputMap.action_add_event("ui_right", event)
		"move_up":
			removeEvent("ui_up", type)
			InputMap.action_add_event("ui_up", event)
		"move_down":
			removeEvent("ui_down", type)
			InputMap.action_add_event("ui_down", event)
	print(InputMap.action_get_events(changeControl))
	changeControl = ""
	updateButton(changeButton, changeControl)

func updateButton(button: Button, movement: String):
	var events = InputMap.action_get_events(movement)
	var type = getControlType(button)
	if events.size() > type:
		button.text = events[type].as_text()
	else: button.text = ""
	button.button_pressed = false

func selectChange(button: Button, toggle: bool, movement: String):
	if toggle:
		button.release_focus()
		if changeButton:
			changeButton.button_pressed = false
		changeControl = movement
		changeButton = button
		button.text = "ui_pressKey"
	else:
		if (changeControl == ""):
			button.grab_focus()
		changeButton = null
		changeControl = ""
		updateButton(button, movement)

func _on_up_button_toggled(toggled_on, source):
	selectChange(source, toggled_on, "move_up")

func _on_down_button_toggled(toggled_on, source):
	selectChange(source, toggled_on, "move_down")

func _on_left_button_toggled(toggled_on, source):
	selectChange(source, toggled_on, "move_left")

func _on_right_button_toggled(toggled_on, source):
	selectChange(source, toggled_on, "move_right")

func _on_main_button_toggled(toggled_on, source):
	selectChange(source, toggled_on, "MainAction")

func _on_second_button_toggled(toggled_on, source):
	selectChange(source, toggled_on, "SecondaryAction")
	
func getControlType(source: Button) -> int:
	var grandparent = source.get_parent().get_parent()
	if grandparent.name == "KeyControlsVBox":
		return 0
	elif grandparent.name == "JoystickControlsVBox":
		return 1
	else:
		return -1

func startUpdateButtons():
	var Buttons = ["UpHBox/UpButton", "DownHBox/DownButton",
	"LeftHBox/LeftButton", "RightHBox/RightButton",
	"MainHBox/MainButton"]
	var path = "ControlsHbox"
	for buttonURL in Buttons:
		var buttonKeyBoard = Controls.get_node(path + "/KeyControlsVBox/" + buttonURL)
		updateButton(buttonKeyBoard, buttonKeyBoard.text)
		var buttonJoystick = Controls.get_node(path + "/JoystickControlsVBox/" + buttonURL)
		updateButton(buttonJoystick, buttonJoystick.text)
