extends Node

# Track the current map music stream
var map_music_stream: AudioStream = null
var map_music_player_index: int = -1

# Track battle music player by index
var battle_music_player_index: int = -1


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


# Play map music (always from the beginning)
func play_map_music(audio: AudioStream) -> void:
	if not audio:
		print("play_map_music: No audio provided")
		return
	
	print("play_map_music: Called with audio")
	
	# Stop any battle music
	if battle_music_player_index >= 0:
		var battle_player = get_child(battle_music_player_index) as AudioStreamPlayer
		if battle_player and battle_player.playing:
			battle_player.stop()
		battle_music_player_index = -1
	
	# Always start map music from the beginning
	print("play_map_music: Starting map music from beginning")
	map_music_stream = audio
	
	for i in get_child_count():
		var player = get_child(i) as AudioStreamPlayer
		if not player.playing:
			player.stream = audio
			player.play()
			map_music_player_index = i
			print("play_map_music: Started on player index ", i, " (", player.name, ")")
			return
	
	print("play_map_music: ERROR - No available player found!")


# Play battle music (stops map music)
func play_battle_music(audio: AudioStream) -> void:
	if not audio:
		print("play_battle_music: No audio provided")
		return
	
	print("play_battle_music: Called")
	
	# Stop map music
	if map_music_player_index >= 0:
		var map_player = get_child(map_music_player_index) as AudioStreamPlayer
		if map_player:
			print("play_battle_music: Stopping map player index ", map_music_player_index)
			map_player.stop()
	
	# Stop any other playing music to be safe
	for i in get_child_count():
		var player = get_child(i) as AudioStreamPlayer
		if player.playing:
			print("play_battle_music: Stopping player ", player.name)
			player.stop()
	
	# Find an available player for battle music (prefer a different one than map music)
	for i in get_child_count():
		if i != map_music_player_index:
			var player = get_child(i) as AudioStreamPlayer
			player.stream = audio
			player.play()
			battle_music_player_index = i
			print("play_battle_music: Started battle music on player index ", i, " (", player.name, ")")
			return
	
	print("play_battle_music: ERROR - No available player found!")


# Resume map music from the beginning
func resume_map_music() -> void:
	print("resume_map_music: Called")
	print("  map_music_stream: ", map_music_stream)
	
	# Stop battle music if playing
	if battle_music_player_index >= 0:
		var battle_player = get_child(battle_music_player_index) as AudioStreamPlayer
		if battle_player:
			print("resume_map_music: Stopping battle music player index ", battle_music_player_index)
			battle_player.stop()
		battle_music_player_index = -1
	
	# Stop all other players to be safe
	for i in get_child_count():
		if i != map_music_player_index:
			var player = get_child(i) as AudioStreamPlayer
			if player and player.playing:
				print("resume_map_music: Stopping other player index ", i)
				player.stop()
	
	# Play map music from the beginning
	if map_music_stream:
		for i in get_child_count():
			var player = get_child(i) as AudioStreamPlayer
			if not player.playing:
				player.stream = map_music_stream
				player.play()  # Start from beginning (no position parameter)
				map_music_player_index = i
				print("resume_map_music: Started map music from beginning on index ", i)
				return
		print("resume_map_music: ERROR - No available player found")
	else:
		print("resume_map_music: ERROR - No map music stream available")


func stop() -> void:
	for player in get_children():
		player = player as AudioStreamPlayer
		player.stop()
	
	# Clear tracking
	map_music_player_index = -1
	battle_music_player_index = -1


func already_playing_music() -> bool:
	for player in get_children():
		player = player as AudioStreamPlayer
		if player.playing:
			print("already playing music")
			return true
			
	print("no music")
	return false
