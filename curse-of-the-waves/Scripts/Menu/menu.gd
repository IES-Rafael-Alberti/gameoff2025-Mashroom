extends Control

@export var OptionsContainer: Control

func _on_play_button_pressed():
	var new_scene = ResourceLoader.load("res://MenuTest/Scenes/Menu.tscn").instantiate()
	get_tree().get_root().add_child(new_scene)
	get_tree().get_root().get_child(0).queue_free()

func _on_options_button_pressed():
	OptionsContainer.showOptionMenu(true)
