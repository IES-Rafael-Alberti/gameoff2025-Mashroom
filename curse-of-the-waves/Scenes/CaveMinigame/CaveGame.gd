extends Node2D
var witchKilled = false

func _ready():
	var game_camera = get_tree().get_root().get_node("Main/GameManager/Camera")
	game_camera.start_follow($Player, $BottomLeft, $TopRight)
	
	# Espera a que se inicialice la variable
	await get_tree().process_frame  # o hasta que un dialogic scene se inicie
	
	# Ahora sí accedes a la variable
	witchKilledEffect(not Dialogic.VAR.get_variable("canon_final"))

func witchKilledEffect(isDead: bool):
	if isDead:
		print("The witch is dead")
		$Spawner.witch_killed = true
		$EnemiesWitchKilled.visible = true
	else:
		$EnemiesWitchKilled.queue_free()
