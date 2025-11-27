extends VBoxContainer

@export_group("Basics")
@export var vol: float = 5.0

@export_group("Objects")
@export var general: HSlider
@export var musica: HSlider
@export var efectos: HSlider
@export var testSonido: AudioStream #sonido de prueba
@export var audioPlayer: AudioStreamPlayer

@onready var menosG = $MainHBox/menosG
@onready var masG = $MainHBox/masG
@onready var menosM = $MusicHBox/menosM
@onready var masM = $MusicHBox/masM
@onready var menosS = $SoundHBox/menosS
@onready var masS = $SoundHBox/masS
#@onready var pruebaSFX = preload("res://assets/Audio/SFX/sfxBarraVol.wav")

const minDeci = -60.0
const maxDeci = 0.0

func _ready():
	sliders()
	general.value_changed.connect(volGeneral)
	musica.value_changed.connect(volMusica)
	efectos.value_changed.connect(volSfx)
	
	#conexiones para los botones
	menosG.pressed.connect(btnMenosG)
	masG.pressed.connect(btnMasG)
	menosM.pressed.connect(btnMenosM)
	masM.pressed.connect(btnMasM)
	menosS.pressed.connect(btnMenosS)
	masS.pressed.connect(btnMasS)

func sliders():
	print(general)
	general.value = deci_to_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	musica.value = deci_to_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musica")))
	efectos.value = deci_to_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))

func slider_to_deci(value: float) -> float:
	if value <= 0.0:
		return minDeci
		
	var lin = value / 100.0
	var deci = linear_to_db(lin)
	return clamp(deci, minDeci, maxDeci)
	
func deci_to_slider(deci: float) -> float:
	if deci <= minDeci:
		return 0.0
	var lin = db_to_linear(deci)
	return clamp(lin * 100.0, 0.0, 100.0)
	
func volumen(busNom: String, value:float):
	var deci = slider_to_deci(value)
	var busI = AudioServer.get_bus_index(busNom)
	AudioServer.set_bus_volume_db(busI, deci)
	AudioServer.set_bus_mute(busI, deci <= minDeci)
	
func volGeneral(value: float):
	volumen("Master", value) #este sera el general

func volMusica(value: float):
	volumen("Musica", value)
	
func volSfx(value: float):
	volumen("SFX", value)
	playSfx()

func btnMenosG():
	general.value = clamp(general.value - vol, 0.0, 100.0)
func btnMasG():
	general.value = clamp(general.value + vol, 0.0, 100.0)

func btnMenosM():
	musica.value = clamp(musica.value - vol, 0.0, 100.0)
func btnMasM():
	musica.value = clamp(musica.value + vol, 0.0, 100.0)
	
func btnMenosS():
	efectos.value = clamp(efectos.value - vol, 0.0, 100.0)
func btnMasS():
	efectos.value = clamp(efectos.value + vol, 0.0, 100.0)

#metodo para que suene algo que indique cuan alto o bajo esta el volumen de sfx
func playSfx():
	if audioPlayer and testSonido:
		audioPlayer.stream = testSonido
		audioPlayer.play()
