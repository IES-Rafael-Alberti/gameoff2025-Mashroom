extends Node2D

@onready var time = $Timer
@onready var label = $Label
@onready var jugador = $Jugador

enum State {rojo, verde}
var estado: State = State.rojo #si o si mayuscula el state 
var posicionRojo: Vector2
var umbral = 2.0 #probar igual 5.0 o 10.0

func _ready():
	time.wait_time = 3.0
	verde() #iniciar en verde para que jugador se mueva al empezar
	time.start()

func _on_timer_timeout() -> void:
	if estado == State.verde:
		rojo()
	else:
		verde()

func verde() -> void:
	estado = State.verde
	label.text ="Camina"
	jugador.puedeMoverse = true
	if not time.is_stopped():
		time.start() 

func rojo() -> void:
	estado = State.rojo
	label.text = "Para"
	time.stop() #detener timer para evitar solapamientos mientras penalizas
	
	posicionRojo = jugador.position #pa tomar la posicion al empezar en rojo
	await get_tree().process_frame #esto para forzar el frame a que se procese para mostrar el label de espera
	await get_tree().create_timer(0.5).timeout #esperar para dar tiempo a moverse el jugador
	
	var dist = jugador.position.distance_to(posicionRojo)
	print("DEBUG: snap:", posicionRojo, " ahora:", jugador.position, " dist:", dist)

	if dist > umbral:
		print("DEBUG: movimiento detectado :3")
		await penalizar()
	else:
		print("DEBUG: no hubo movimiento. Se puede continuar")
		time.start()

func penalizar() -> void:
	time.stop()
	jugador.puedeMoverse = false
	
	label.text = "te moviste jaja"
	await get_tree().process_frame
	await get_tree().create_timer(1.5).timeout

	jugador.reinicioPosicion()

	label.text = "Preparate" #mensaje y espera antes pa volver a continuar
	await get_tree().process_frame
	await get_tree().create_timer(1.5).timeout
	verde()
	time.start()
