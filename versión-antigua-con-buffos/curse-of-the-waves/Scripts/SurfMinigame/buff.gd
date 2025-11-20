extends Area2D

@export var buff_type: String = "none"  # "speed", "invulnerable", "slow_obstacles", aplicamos el buff en el inspector de cada item
@export var duration: float = 5.0  # Duración del buff

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Buff") # Añadimos el grupo buff
