extends Control

@export_group("Objects")
@export var OptionsContainer: Control

func _ready():
	AudioPlayer.play_music_nivel()
	$PlayButton.grab_focus()

func _on_play_button_pressed() -> void:
	$PlayButton.focus_mode  = Control.FOCUS_NONE
	$OptionsButton.focus_mode  = Control.FOCUS_NONE
	Dialogic.start('1-prologue')
	await Dialogic.timeline_ended
	get_tree().change_scene_to_file("res://Scenes/SurfMinigame/SurfMinigame.tscn")
	

func _on_options_button_pressed():
	OptionsContainer.showOptionMenu(true)
	$PlayButton.focus_mode  = Control.FOCUS_NONE
	$OptionsButton.focus_mode  = Control.FOCUS_NONE
	
func _on_back_button_pressed():
	await OptionsContainer.showOptionMenu(false)
	$PlayButton.focus_mode  = Control.FOCUS_ALL
	$OptionsButton.focus_mode  = Control.FOCUS_ALL 
	$OptionsButton.grab_focus()

"func play_sound(stream: AudioStream):
	var musica = AudioStreamPlayer.new()
	musica.stream = stream
	add_child(musica)
	musica.play()"
