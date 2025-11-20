extends Control

@export_group("Objects")
@export var OptionsContainer: Control

func _ready():
	AudioPlayer.musicNivel()
	$PlayButton.grab_focus()

func _on_play_button_pressed() -> void:
	AudioPlayer.stopMusic()
	AudioPlayer.pulsarBtn()
	$PlayButton.focus_mode  = Control.FOCUS_NONE
	$OptionsButton.focus_mode  = Control.FOCUS_NONE
	var GameManager = get_tree().get_root().get_node("Main/GameManager")
	GameManager.loadSceneDialogic(preload("res://Scenes/SurfMinigame/SurfMinigame.tscn"), '1-prologue')
	

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

"func play_sound(stream: AudioStream):
	var musica = AudioStreamPlayer.new()
	musica.stream = stream
	add_child(musica)
	musica.play()"
