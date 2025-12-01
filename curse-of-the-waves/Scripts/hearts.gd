extends HBoxContainer

@export var full_hp_icon: CompressedTexture2D
@export var empty_hp_icon: CompressedTexture2D

const COLOR_RED: Color = Color(1.0, 1.0, 1.0, 1.0)  
const COLOR_BLUE: Color = Color(0.46, 0.64, 1.0, 1.0) 
const COLOR_BROKEN: Color = Color(0.5, 0.5, 0.5, 1.0)

const TRANSITION_DURATION: float = 0.8

func update_hearts_with_colors(hearts_info: Array) -> void:
	# Iterar sobre cada corazón (H1, H2, H3, H4)
	for heart_data in hearts_info:
		var index = heart_data["index"]
		var heart_node: TextureRect = get_node("H" + str(index))
		
		if not heart_data["is_visible"]:
			# Si no es visible (ej: H4 cuando no pasaste el surf)
			heart_node.texture = null
			# Ajustar H0 para mantener el espaciado
			if index == 4:
				get_node("H0").custom_minimum_size = get_node("H1").custom_minimum_size
		else:
			# El corazón es visible
			# Determinar textura
			if heart_data["is_full"]:
				heart_node.texture = full_hp_icon
			else:
				heart_node.texture = empty_hp_icon
			
			# Determinar color con transición suave
			var target_color: Color = COLOR_RED
			
			if heart_data["is_broken"]:
				# Corazón roto (gris oscuro)
				target_color = COLOR_BROKEN
			elif heart_data["is_blue"]:
				# Corazón azul (del surf)
				target_color = COLOR_BLUE
			else:
				# Corazón rojo normal
				target_color = COLOR_RED
			
			# Aplicar transición de color suave
			animate_color_transition(heart_node, target_color)
			
			# Ajustar H0 cuando H4 es visible
			if index == 4:
				get_node("H0").custom_minimum_size = Vector2(0, 0)


# Función para animar la transición de color suavemente
func animate_color_transition(node: TextureRect, target_color: Color) -> void:
	# Crear tween para transición suave (igual que en el surf)
	var tween = create_tween()
	tween.tween_property(node, "modulate", target_color, TRANSITION_DURATION)
