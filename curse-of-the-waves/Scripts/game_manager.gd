extends Node


@export var health = 3
@export var objects : Dictionary

var baseWindowsSize = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)


func _enter_tree() -> void:
	TranslationServer.set_locale("en")


func _on_language_option_button_item_selected(index: int) -> void:
	match index:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("es")
