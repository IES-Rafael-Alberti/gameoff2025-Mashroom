extends Control

@export var OptionAnim: AnimationPlayer

func _ready():
	hide()
	
func showOptionMenu(show: bool):
	if show:
		show()
		OptionAnim.play("OptionsMenu")
	else:
		OptionAnim.play_backwards("OptionsMenu")
		await OptionAnim.animation_finished
		hide()

func _on_back_button_pressed():
	showOptionMenu(false)
