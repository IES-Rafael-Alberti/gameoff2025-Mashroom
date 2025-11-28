extends Control

@export_group("Objects")
@export var options_container: Control
@export var options: Control
@export var controls: Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var credits_button: Button = $VBoxContainer/CreditsButton

var change_control := ""
var change_button: Button


func _ready():
	AudioPlayer.music_nivel(-3.0)
	_start_update_buttons()
	if play_button:
		play_button.grab_focus()


func _on_play_button_pressed() -> void:
	Dialogic.VAR.set_variable("said_ugly", false)
	Dialogic.VAR.set_variable("canon_final", false)
	Dialogic.VAR.set_variable("has_weapon", false)
	Dialogic.VAR.set_variable("gave_up", false)
	AudioPlayer.stop_music()
	AudioPlayer.pulsar_btn()
	if play_button:
		play_button.focus_mode = Control.FOCUS_NONE
	if options_button:
		options_button.focus_mode = Control.FOCUS_NONE
	if credits_button:
		credits_button.focus_mode = Control.FOCUS_NONE
	var game_manager = get_tree().get_root().get_node("Main/GameManager")
	game_manager.load_scene_dialogic(
		preload("res://Scenes/SurfMinigame/SurfMinigame.tscn"), '1-prologue',true)


func _on_credits_button_pressed():
	AudioPlayer.pulsar_btn()
	var game_manager = get_tree().get_root().get_node("Main/GameManager")
	game_manager.load_scene(preload("res://Scenes/Credits.tscn"),false)


func _on_options_button_pressed():
	AudioPlayer.pulsar_btn()
	options_container.show_option_menu(true)
	if play_button:
		play_button.focus_mode = Control.FOCUS_NONE
	if options_button:
		options_button.focus_mode = Control.FOCUS_NONE
	if credits_button:
		credits_button.focus_mode = Control.FOCUS_NONE


func _on_exit_button_pressed():
	AudioPlayer.pulsar_btn()
	await options_container.show_option_menu(false)
	if play_button:
		play_button.focus_mode = Control.FOCUS_ALL
	if options_button:
		options_button.focus_mode = Control.FOCUS_ALL
		options_button.grab_focus()
	if credits_button:
		credits_button.focus_mode = Control.FOCUS_ALL
		credits_button.grab_focus()


func _on_option_button_item_selected(index):
	var game_manager = get_tree().get_root().get_node("Main/GameManager")
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
		# Type 0 = Keyboard, Type 1 = Joystick
		if type == 0 and event is InputEventKey:
			button.text = event.as_text()
			break
		elif type == 1 and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
			button.text = event.as_text()
			break

	button.button_pressed = false


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
