extends AudioStreamPlayer

const MUSICA_MENU = preload(
	"res://assets/Audio/Música/Para menú/ukeleleMenu.wav")
const MUSICA_SURF = preload("res://assets/Audio/Música/" +
	"Minijuego surf + cutsceneInicial/night-paradise-instrumental-269040.mp3")
const SFX_BTN = preload("res://assets/Audio/SFX/recogeObjetoAgudo.wav")
const MUSICA_CUEVA = preload(
	"res://assets/Audio/Música/Minijuego cueva/lightVoid-mystical-orchestral.wav")

var vel_fade = 1.0
var fade = false


func play_music(musica: AudioStream, vol = 0.0):
	if stream == musica:
		return
	stream = musica
	volume_db = vol
	play()


func music_nivel():
	play_music(MUSICA_MENU)


func music_minijuego_surf():
	play_music(MUSICA_SURF)


func pulsar_btn():
	play_sfx(SFX_BTN)


func music_minijuego_cueva():
	play_music(MUSICA_CUEVA)


func stop_music():  # con fade
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
	add_child(sfx)
	sfx.play()

	await sfx.finished
	sfx.queue_free()
