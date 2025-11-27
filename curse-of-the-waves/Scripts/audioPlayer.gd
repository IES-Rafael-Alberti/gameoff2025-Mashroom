extends AudioStreamPlayer

const musica1 = preload("res://assets/Audio/Música/Para menú/ukeleleMenu.wav")
const musica2 = preload("res://assets/Audio/Música/Minijuego surf + cutsceneInicial/night-paradise-instrumental-269040.mp3")
const sfx1 = preload("res://assets/Audio/SFX/recogeObjetoAgudo.wav")
const musica3 = preload("res://assets/Audio/Música/Minijuego cueva/lightVoid-mystical-orchestral.wav")
const ondita = preload("res://assets/Audio/SFX/Minijuego cueva/Ondas/SFXOnda.wav") #pequeña
const antesOndita = preload("res://assets/Audio/SFX/Minijuego cueva/Ondas/antesSFXOnda.wav")
const onda = preload("res://assets/Audio/SFX/Minijuego cueva/Ondas/sfxOndaGrave2.wav") #grande/enorme
const antesOnda = preload("res://assets/Audio/SFX/Minijuego cueva/Ondas/sfxAntesOndaGrave2.wav")

var vel_fade = 1.0
var fade = false


func play_music(musica: AudioStream, vol = 0.0):
	if stream == musica:
		return
	stream = musica
	volume_db = vol
	play()

func musicNivel(vol = 0.0):
	play_music(musica1, vol)
	
func musicMinijuegoSurf():
	play_music(musica2)


func music_minijuego_cueva():
	play_music(MUSICA_CUEVA)

func sfxOndita(vol = 0.0):
	playSfx(ondita, vol)

func sfxAntesOndita():
	playSfx(antesOndita)

func sfxOnda(vol = 0.0):
	playSfx(onda, vol)

func sfxAntesOnda():
	playSfx(antesOnda)

func stopMusic(): #con fade
	if fade:
		return
	fade = true
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80.0, vel_fade)
	tween.tween_callback(func(): stop(); volume_db = 0.0; fade = false)  # para y resetea


func music_fade(musica: AudioStream, vol = 0.0):  # para empezar con la musica suavito
	if stream == musica:
		return
	stream = musica
	volume_db = -70.0
	play()
	var tween = create_tween()
	tween.tween_property(self, "volume_db", vol, vel_fade)


func play_sfx(audio_stream: AudioStream, vol = 0.0):
	var sfx = AudioStreamPlayer.new()
	sfx.stream = audio_stream
	sfx.name = "SFX"
	sfx.volume_db = vol
	sfx.bus = "SFX"
	add_child(sfx)
	sfx.play()

	await sfx.finished
	sfx.queue_free()
