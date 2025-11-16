extends Control

@export_group("Objects")
@export var OptionsContainer: Control


func _on_play_button_pressed() -> void:
	Dialogic.start('1-prologue')
	await Dialogic.timeline_ended
	get_tree().change_scene_to_file("res://Scenes/SurfMinigame/SurfMinigame.tscn")
	

func _on_options_button_pressed():
	OptionsContainer.showOptionMenu(true)
