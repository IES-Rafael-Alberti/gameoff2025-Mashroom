extends Control

@export_group("Objects")
@export var options_container: Control
@export var options: Control
@export var controls: Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var credits_button: Button = $VBoxContainer/CreditsButton
@onready var game_manager = get_tree().get_root().get_node("Main/GameManager")

var change_control := ""
var change_button: Button


func _ready():
	AudioPlayer.music_nivel(-3.0)
	_start_update_buttons()
	if play_button:
		play_button.grab_focus()


func _on_play_button_pressed() -> void:
	AudioPlayer.stop_music()
	AudioPlayer.pulsar_btn()
	menuFocus(false)
	#game_manager.load_scene_dialogic(load("res://Scenes/SurfMinigame/SurfMinigame.tscn"),'1-prologue', true)
	#game_manager.load_scene(load("res://Scenes/CaveMinigame/CaveGame.tscn"), true)
	game_manager.load_scene_dialogic(load("res://Scenes/CaveMinigame/CaveGame.tscn"),'1-prologue', true)


func _on_options_button_pressed():
	AudioPlayer.pulsar_btn()
	options_container.show_option_menu(true)
	menuFocus(false)


func _on_exit_button_pressed():
	AudioPlayer.pulsar_btn()
	await options_container.show_option_menu(false)
	menuFocus(true)
	play_button.grab_focus()

func menuFocus(activated: bool):
	var act = Control.FOCUS_ALL
	if not activated:
		act = Control.FOCUS_NONE
	play_button.focus_mode = act
	options_button.focus_mode = act
	credits_button.focus_mode = act

func _on_option_button_item_selected(index):
	game_manager.change_language(index)


func _input(event):
	if event.is_released():
		if event is InputEventKey and change_control != "" \
				and _get_control_type(change_button) == 0:
			_change_input(event, "Keyboard")
			change_control = ""
		elif _is_joypad_event(event) and change_control != "" \
				and _get_control_type(change_button) == 1:
			_change_input(event, "Joystick")
			change_control = ""


func _is_joypad_event(event) -> bool:
	if event is InputEventJoypadButton:
		return true
	if event is InputEventJoypadMotion and abs(event.axis_value) > 0.3:
		return true
	return false


func _remove_event(action: String, type: String):
	var events := InputMap.action_get_events(action)

	for e in events:
		var is_joystick := e is InputEventJoypadButton or e is InputEventJoypadMotion
		var is_keyboard := e is InputEventKey
		if (type == "Joystick" and is_joystick) or (type == "Keyboard" and is_keyboard):
			InputMap.action_erase_event(action, e)


func _change_input(event, type):
	_remove_event(change_control, type)
	InputMap.action_add_event(change_control, event)
	match change_control:
		"MainAction":
			_remove_event("ui_accept", type)
			InputMap.action_add_event("ui_accept", event)
		"move_left":
			_remove_event("ui_left", type)
			InputMap.action_add_event("ui_left", event)
		"move_right":
			_remove_event("ui_right", type)
			InputMap.action_add_event("ui_right", event)
		"move_up":
			_remove_event("ui_up", type)
			InputMap.action_add_event("ui_up", event)
		"move_down":
			_remove_event("ui_down", type)
			InputMap.action_add_event("ui_down", event)
	print(InputMap.action_get_events(change_control))
	change_control = ""
	_update_button(change_button, change_control)


func _update_button(button: Button, movement: String):
	var events = InputMap.action_get_events(movement)
	var type = _get_control_type(button)
	button.text = ""

	for event in events:
		var text = event.as_text()
		# Type 0 = Keyboard, Type 1 = Joystick
		if type == 0 and event is InputEventKey:
			button.text = text
			break
		elif type == 1 and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
			if event is InputEventJoypadButton:
				if text.contains("D-pad"):
					var substr = text.substr(text.find("D-pad"))
					button.text = substr.substr(0,substr.length()-1)
				else:
					var substr = text.substr(text.find("Xbox"))
					button.text = substr.substr(0,substr.find(","))
			else:
				var axis = text.substr(text.find("Axis")+5,1)
				var axisDir = text.substr(text.find("Value")+6)
				button.text = getDirByAxis(int(axis),float(axisDir))
	button.button_pressed = false

func getDirByAxis(axis: int, value: float):
	var toReturn = ""
	if axis == 4: return "Left Trigger"
	if axis == 5: return "Right Trigger"
	if axis/2 == 1:toReturn += "Right stick: "
	else: toReturn += "Left stick: "
	
	match axis%2:
		1:
			if value > 0:
					toReturn += "Down"
			else:
					toReturn += "Up"
		0:
			if value > 0:
					toReturn += "Right"
			else:
					toReturn += "Left"
	return toReturn


func _select_change(button: Button, toggle: bool, movement: String):
	if toggle:
		button.release_focus()
		if change_button:
			change_button.button_pressed = false
		change_control = movement
		change_button = button
		button.text = "ui_pressKey"
	else:
		if change_control == "":
			button.grab_focus()
		change_button = null
		change_control = ""
		_update_button(button, movement)


func _on_up_button_toggled(toggled_on, source):
	_select_change(source, toggled_on, "move_up")


func _on_down_button_toggled(toggled_on, source):
	_select_change(source, toggled_on, "move_down")


func _on_left_button_toggled(toggled_on, source):
	_select_change(source, toggled_on, "move_left")


func _on_right_button_toggled(toggled_on, source):
	_select_change(source, toggled_on, "move_right")


func _on_main_button_toggled(toggled_on, source):
	_select_change(source, toggled_on, "MainAction")


func _on_second_button_toggled(toggled_on, source):
	_select_change(source, toggled_on, "SecondaryAction")


func _get_control_type(source: Button) -> int:
	var grandparent = source.get_parent().get_parent()
	if grandparent.name == "KeyControlsVBox":
		return 0
	if grandparent.name == "JoystickControlsVBox":
		return 1
	return -1


func _start_update_buttons():
	var buttons = [
		"UpHBox/UpButton", "DownHBox/DownButton",
		"LeftHBox/LeftButton", "RightHBox/RightButton",
		"MainHBox/MainButton"
	]
	var path = "ControlsHbox"
	for button_url in buttons:
		var button_keyboard = controls.get_node(path + "/KeyControlsVBox/" + button_url)
		_update_button(button_keyboard, button_keyboard.text)
		var button_joystick = controls.get_node(path + "/JoystickControlsVBox/" + button_url)
		_update_button(button_joystick, button_joystick.text)


func _on_credits_button_pressed():
	game_manager.load_scene(
		load("res://Scenes/Credits.tscn"), false)
