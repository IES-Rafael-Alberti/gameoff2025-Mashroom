extends VBoxContainer

@export_group("Basics")
@export var vol: float = 5.0

@export_group("Objects")
@export var general: HSlider
@export var musica: HSlider
@export var efectos: HSlider
@export var test_sonido: AudioStream #sonido de prueba
@export var audio_player: AudioStreamPlayer

@onready var menos_g = $MainHBox/menosG
@onready var mas_g = $MainHBox/masG
@onready var menos_m = $MusicHBox/menosM
@onready var mas_m = $MusicHBox/masM
@onready var menos_s = $SoundHBox/menosS
@onready var mas_s = $SoundHBox/masS
#@onready var pruebaSFX = preload("res://assets/Audio/SFX/sfxBarraVol.wav")

const MIN_DECI = -60.0
const MAX_DECI = 0.0


func _ready():
	sliders()
	general.value_changed.connect(vol_general)
	musica.value_changed.connect(vol_musica)
	efectos.value_changed.connect(vol_sfx)

	#conexiones para los botones
	menos_g.pressed.connect(btn_menos_g)
	mas_g.pressed.connect(btn_mas_g)
	menos_m.pressed.connect(btn_menos_m)
	mas_m.pressed.connect(btn_mas_m)
	menos_s.pressed.connect(btn_menos_s)
	mas_s.pressed.connect(btn_mas_s)


func sliders():
	print(general)
	general.value = deci_to_slider(
		AudioServer.get_bus_volume_db(
			AudioServer.get_bus_index("Master"),
		),
	)
	musica.value = deci_to_slider(
		AudioServer.get_bus_volume_db(
			AudioServer.get_bus_index("Musica"),
		),
	)
	efectos.value = deci_to_slider(
		AudioServer.get_bus_volume_db(
			AudioServer.get_bus_index("SFX"),
		),
	)


func slider_to_deci(value: float) -> float:
	if value <= 0.0:
		return MIN_DECI

	var lin = value / 100.0
	var deci = linear_to_db(lin)
	return clamp(deci, MIN_DECI, MAX_DECI)


func deci_to_slider(deci: float) -> float:
	if deci <= MIN_DECI:
		return 0.0
	var lin = db_to_linear(deci)
	return clamp(lin * 100.0, 0.0, 100.0)


func volumen(bus_nom: String, value: float):
	var deci = slider_to_deci(value)
	var bus_i = AudioServer.get_bus_index(bus_nom)
	AudioServer.set_bus_volume_db(bus_i, deci)
	AudioServer.set_bus_mute(bus_i, deci <= MIN_DECI)

func vol_general(value: float):
	volumen("Master", value) #este sera el general


func vol_musica(value: float):
	volumen("Musica", value)


func vol_sfx(value: float):
	volumen("SFX", value)
	play_sfx()


func btn_menos_g():
	general.value = clamp(general.value - vol, 0.0, 100.0)


func btn_mas_g():
	general.value = clamp(general.value + vol, 0.0, 100.0)


func btn_menos_m():
	musica.value = clamp(musica.value - vol, 0.0, 100.0)


func btn_mas_m():
	musica.value = clamp(musica.value + vol, 0.0, 100.0)


func btn_menos_s():
	efectos.value = clamp(efectos.value - vol, 0.0, 100.0)


func btn_mas_s():
	efectos.value = clamp(efectos.value + vol, 0.0, 100.0)


#metodo para que suene algo que indique cuan alto o bajo esta el volumen de sfx
func play_sfx():
	if audio_player and test_sonido:
		audio_player.stream = test_sonido
		audio_player.play()