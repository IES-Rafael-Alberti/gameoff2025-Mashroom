extends AudioStreamPlayer

const musica1 = preload("res://assets/Audio/Música/Para menú/ukeleleMenu.wav")
const musica2 = preload("res://assets/Audio/Música/Minijuego surf + cutsceneInicial/night-paradise-instrumental-269040.mp3")
const sfx1 = preload("res://assets/Audio/SFX/recogeObjetoAgudo.wav")
const musica3 = preload("res://assets/Audio/Música/Minijuego cueva/lightVoid-mystical-orchestral.wav")

var velFade = 1.0
var fade = false

func play_music(musica: AudioStream, vol = 0.0):
	if stream == musica:
		return
	stream = musica
	volume_db = vol
	play()

func musicNivel():
	play_music(musica1)

func musicMinijuegoSurf():
	play_music(musica2)

func pulsarBtn():
	playSfx(sfx1)

func musicMinijuegoCueva():
	play_music(musica3)

func stopMusic(): #con fade
	if fade:
		return
	fade = true
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80.0, velFade)
	tween.tween_callback(func(): stop(); volume_db = 0.0; fade = false)  #para y resetea

#para empezar con la musica suavito
func musicFade(musica: AudioStream, vol = 0.0):
	if stream == musica:
		return
	stream = musica
	volume_db  = -70.0 
	play()
	var tween = create_tween()
	tween.tween_property(self, "volume_db", vol, velFade)

func playSfx(stream: AudioStream, vol = 0.0):
	var sfx = AudioStreamPlayer.new()
	sfx.stream = stream
	sfx.name = "SFX"
	sfx.volume_db = vol
	add_child(sfx)
	sfx.play()
	
	await sfx.finished
	sfx.queue_free()
