extends Node2D

func _ready():
	$Credits/CreditsButton.grab_focus()
	AudioPlayer.sonidoCreditos()

func _on_credits_button_pressed():
	var game_manager = get_tree().get_root().get_node("Main/GameManager")
	game_manager.load_scene(load("res://Scenes/Menu.tscn"), false)
	AudioPlayer.stop_music()
