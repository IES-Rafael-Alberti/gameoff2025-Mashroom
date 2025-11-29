extends AudioStreamPlayer

const MUSICA_MENU = preload("res://assets/Audio/Música/Para menú/ukeleleMenu.wav")
const MUSICA_SURF = preload("res://assets/Audio/Música/Minijuego surf + cutsceneInicial/night-paradise-instrumental-269040.mp3")
const SFX_BTN = preload("res://assets/Audio/SFX/recogeObjetoAgudo.wav")
const MUSICA_CUEVA = preload("res://assets/Audio/Música/Minijuego cueva/lightVoid-mystical-orchestral.wav")
const ONDITA = preload("res://assets/Audio/SFX/Minijuego cueva/onda pequeña/SFXOnda.wav")
const ONDA = preload("res://assets/Audio/SFX/Minijuego cueva/onda grande/sfxOndaGrave2.wav")
const ANTES_ONDITA = preload("res://assets/Audio/SFX/Minijuego cueva/onda pequeña/sfxAntesOndita2.wav")
const ANTES_ONDA = preload("res://assets/Audio/SFX/Minijuego cueva/onda grande/sfxAntesOndaGrave2.wav")
const TRUENO = preload("res://assets/Audio/SFX/Minijuego surf/sfxTrueno.wav")
const CREDITOS = preload("res://assets/Audio/Música/Caja_de_ritmos.wav")

var vel_fade: float = 1.0
var fade: bool = false


func play_music(musica: AudioStream, vol: float = 0.0) -> void:
	if stream == musica:
		return
	stream = musica
	volume_db = vol
	play()


func music_nivel(vol: float = 0.0) -> void:
	play_music(MUSICA_MENU, vol)


func music_minijuego_surf() -> void:
	play_music(MUSICA_SURF)


func pulsar_btn() -> void:
	play_sfx(SFX_BTN)


func music_minijuego_cueva() -> void:
	play_music(MUSICA_CUEVA)


func sfx_ondita(vol: float = 0.0) -> void:
	play_sfx(ONDITA, vol)


func sfx_antes_ondita(vol: float = 0.0) -> void:
	play_sfx(ANTES_ONDITA, vol)


func sfx_onda(vol: float = 0.0) -> void:
	play_sfx(ONDA, vol)


func sfx_antes_onda(vol: float = 0.0) -> void:
	play_sfx(ANTES_ONDA, vol)


func sfx_trueno(vol: float = 0.0) -> void:
	play_sfx(TRUENO, vol)


func sonido_creditos() -> void:
	play_music(CREDITOS)


func stop_music() -> void: # con fade
	if fade:
		return
	fade = true
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80.0, vel_fade)
	tween.tween_callback(
		func():
			stop()
			volume_db = 0.0
			fade = false
	) # para y resetea


func music_fade(musica: AudioStream, vol: float = 0.0) -> void:
	# para empezar con la musica suavito
	if stream == musica:
		return
	stream = musica
	volume_db = -70.0
	play()
	var tween = create_tween()
	tween.tween_property(self, "volume_db", vol, vel_fade)


func play_sfx(audio_stream: AudioStream, vol: float = 0.0) -> void:
	var sfx = AudioStreamPlayer.new()
	sfx.stream = audio_stream
	sfx.name = "SFX"
	sfx.volume_db = vol
	sfx.bus = "SFX"
	add_child(sfx)
	sfx.play()

	await sfx.finished
	sfx.queue_free()
