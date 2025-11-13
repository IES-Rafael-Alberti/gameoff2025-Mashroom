extends VBoxContainer

@export_group("Basics")
@export var language = "English"


func _on_english_pressed():
	language = "English"

func _on_spanish_button_pressed():
	language = "Spanish"
