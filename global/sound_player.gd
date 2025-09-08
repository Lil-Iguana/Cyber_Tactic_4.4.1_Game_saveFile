extends Node


func play(audio: AudioStream, single=false) -> void:
	if not audio:
		return
	
	if single:
		stop()
	
	for player in get_children():
		player = player as AudioStreamPlayer
		
		if not player.playing:
			player.stream = audio
			player.play()
			break


#Same function as the previous one, but without the pitch change for SFX.
func play_music(audio: AudioStream, single = false) -> void:
	if not audio:
		return
	
	if single:
		stop()
	
	for player in get_children():
		player = player as AudioStreamPlayer
		if not player.playing:
			player.stream = audio
			player.play()
			break


func stop() -> void:
	for player in get_children():
		player = player as AudioStreamPlayer
		player.stop()


func already_playing_music() -> bool:
	for player in get_children():
		player = player as AudioStreamPlayer
		if player.playing:
			print("already playing music")
			return true
			
	print ("no music")
	return false
