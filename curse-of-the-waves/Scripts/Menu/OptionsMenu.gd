extends Control

@export_group("Objects")
@export var OptionAnim: AnimationPlayer


func _ready():
	hide()
	
func showOptionMenu(show: bool):
	if show:
		show()
		OptionAnim.play("OptionsMenu")
		$OptionsBackground/Options/BackButton.grab_focus()
	else:
		OptionAnim.play_backwards("OptionsMenu")
		await OptionAnim.animation_finished
		hide()
		
