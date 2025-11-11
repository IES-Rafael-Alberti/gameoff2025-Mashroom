extends Control

@export var OptionsContainer: Control

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/SurfMinigame/SurfMinigame.tscn")


func _on_options_button_pressed():
	OptionsContainer.showOptionMenu(true)
