extends AudioStreamPlayer

const musica1 = preload("res://assets/Audio/Música/Para menú/ukeleleMenu.wav")

func play_music(musica: AudioStream, vol = 0.0):
	if stream == musica:
		return
	stream = musica
	volume_db = vol
	play()

func play_music_nivel():
	play_music(musica1)

func playSfx(stream: AudioStream, vol = 0.0):
	var sfx = AudioStreamPlayer.new()
	sfx.stream = stream
	sfx.name = "SFX_Jugador"
	sfx.volume_db = vol
	add_child(sfx)
	sfx.play()
	
	await sfx.finished
	sfx.queue_free()
	
