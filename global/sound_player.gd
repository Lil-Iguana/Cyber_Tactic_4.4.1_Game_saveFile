extends Node

# Track the current map music state
var map_music_player: AudioStreamPlayer = null
var map_music_position: float = 0.0
var map_music_stream: AudioStream = null

# Track battle music player
var battle_music_player: AudioStreamPlayer = null


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


# New function specifically for map music that can be resumed
func play_map_music(audio: AudioStream) -> void:
	if not audio:
		return
	
	# Stop any battle music
	if battle_music_player and battle_music_player.playing:
		battle_music_player.stop()
		battle_music_player = null
	
	# If we're resuming the same track, continue from saved position
	if map_music_stream == audio and map_music_player and map_music_position > 0:
		map_music_player.play(map_music_position)
		return
	
	# Otherwise, start new map music
	map_music_stream = audio
	map_music_position = 0.0
	
	for player in get_children():
		player = player as AudioStreamPlayer
		if not player.playing:
			player.stream = audio
			player.play()
			map_music_player = player
			break


# New function for battle music (pauses map music)
func play_battle_music(audio: AudioStream) -> void:
	if not audio:
		return
	
	# Save map music position and pause it
	if map_music_player and map_music_player.playing:
		map_music_position = map_music_player.get_playback_position()
		map_music_player.stop()
	
	# Find an available player for battle music
	for player in get_children():
		player = player as AudioStreamPlayer
		if not player.playing:
			player.stream = audio
			player.play()
			battle_music_player = player
			break


# Resume map music from where it left off
func resume_map_music() -> void:
	if map_music_stream and map_music_player:
		# Stop battle music if playing
		if battle_music_player and battle_music_player.playing:
			battle_music_player.stop()
			battle_music_player = null
		
		# Resume map music
		map_music_player.play(map_music_position)


func stop() -> void:
	for player in get_children():
		player = player as AudioStreamPlayer
		player.stop()
	
	# Clear tracking
	map_music_player = null
	map_music_position = 0.0
	battle_music_player = null


func already_playing_music() -> bool:
	for player in get_children():
		player = player as AudioStreamPlayer
		if player.playing:
			print("already playing music")
			return true
			
	print("no music")
	return false
