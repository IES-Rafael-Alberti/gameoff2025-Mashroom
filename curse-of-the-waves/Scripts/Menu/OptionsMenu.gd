extends Control

@export_group("Objects")
@export var option_anim: AnimationPlayer


func _ready():
	hide()


func show_option_menu(show_menu: bool):
	if show_menu:
		show()
		option_anim.play("OptionsMenu")
		$OptionsBackground/Options/ExitButton.grab_focus()
	else:
		option_anim.play_backwards("OptionsMenu")
		await option_anim.animation_finished
		hide()
