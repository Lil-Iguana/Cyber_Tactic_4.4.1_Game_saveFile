## MusicManager — handles all in-game music with overlap/merge transitions.
##
## Attach this script to the MusicPlayer node (res://global/music_player.tscn).
## The node needs exactly TWO AudioStreamPlayer children named
## "PlayerA" and "PlayerB", both set to the "Music" bus.
##
## Transition behaviour:
##   The new track fades IN immediately. The old track waits for
##   overlap_delay seconds, then fades OUT — so both tracks play together
##   at full volume for a moment before the old one disappears.
##
## Usage (call via the MusicPlayer autoload):
##   MusicPlayer.play_track(MusicManager.Track.MAP)
##   MusicPlayer.play_track(MusicManager.Track.BATTLE)
##   MusicPlayer.play_track(MusicManager.Track.BOSS)
##   MusicPlayer.play_track(MusicManager.Track.RESULT)
##   MusicPlayer.play_track(MusicManager.Track.SHOP)
##   MusicPlayer.stop_music()

extends Node

# ---------------------------------------------------------------------------
# Tracks
# ---------------------------------------------------------------------------
enum Track { NONE, MAP, BATTLE, BOSS, RESULT, SHOP, MAINMENU }

const TRACKS: Dictionary = {
	Track.MAP:    "res://art/music/Track_MapRun.ogg",
	Track.BATTLE: "res://art/music/Track_Battle.ogg",
	Track.BOSS:   "res://art/music/Track_BossBattle.ogg",
	Track.RESULT: "res://art/music/Track_ResultBattle.ogg",
	Track.SHOP:   "res://art/music/Track_Shop.ogg",
	Track.MAINMENU:   "res://art/music/mainmenu_music.mp3",
}

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

## Duration (in seconds) for the new track to fade in and the old track to fade out.
@export var fade_duration: float = 2.0

## How long (in seconds) both tracks play together at full volume before
## the old track starts fading out. Set to 0 for a classic simultaneous crossfade.
@export var overlap_delay: float = 1.5

# ---------------------------------------------------------------------------
# Internal state
# ---------------------------------------------------------------------------
var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer

# Which player is currently the "active" (audible) one.
var _active: AudioStreamPlayer
var _inactive: AudioStreamPlayer

var _current_track: Track = Track.NONE
var _target_volume_db: float = 0.0   # Individual players always target 0 dB.

var _tween: Tween = null


# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------
func _ready() -> void:
	_player_a = $PlayerA
	_player_b = $PlayerB

	# Mute both at start so we can fade in cleanly.
	_player_a.volume_db = -80.0
	_player_b.volume_db = -80.0

	_active   = _player_a
	_inactive = _player_b

	_target_volume_db = 0.0


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Play a track by enum value. If the same track is already playing,
## nothing happens (no restart, no duplicate).
## Pass force_restart = true to restart even when the same track is active.
func play_track(track: Track, force_restart: bool = false) -> void:
	if track == Track.NONE:
		stop_music()
		return

	# Guard: don't re-trigger the same track unless forced.
	if track == _current_track and _active.playing and not force_restart:
		return

	var path: String = TRACKS.get(track, "")
	if path.is_empty():
		push_error("MusicManager: No path registered for track %d" % track)
		return

	var stream: AudioStream = load(path)
	if not stream:
		push_error("MusicManager: Could not load stream at %s" % path)
		return

	_current_track = track
	_merge_to(stream)


## Immediately silence everything with a fade-out.
func stop_music() -> void:
	_current_track = Track.NONE
	_kill_tween()

	var t := create_tween()
	_tween = t
	t.set_parallel(true)
	t.tween_property(_active,   "volume_db", -80.0, fade_duration)
	t.tween_property(_inactive, "volume_db", -80.0, fade_duration)
	await t.finished
	_active.stop()
	_inactive.stop()


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

func _merge_to(stream: AudioStream) -> void:
	_kill_tween()

	var old_player := _active
	var new_player := _inactive

	# Prepare the new track silently and start it.
	new_player.stream    = stream
	new_player.volume_db = -80.0
	new_player.play()

	# Swap roles so subsequent calls reference the correct active player.
	_active   = new_player
	_inactive = old_player

	# Phase 1: new track fades IN while old track stays at full volume.
	# Phase 2: after overlap_delay, old track fades OUT.
	# Both phases are sequenced on the same tween using set_parallel(false)
	# for the delay, but we need parallel fades within each phase.

	var t := create_tween()
	_tween = t

	# Fade the new track in immediately (runs in parallel with the delay).
	t.set_parallel(true)
	t.tween_property(new_player, "volume_db", _target_volume_db, fade_duration)

	# After the overlap delay, fade the old track out.
	# tween_interval acts as a sequenced wait even in parallel mode when
	# chained with tween_callback.
	t.set_parallel(false)
	t.tween_interval(overlap_delay)
	t.tween_property(old_player, "volume_db", -80.0, fade_duration)

	await t.finished
	old_player.stop()
	old_player.volume_db = -80.0


func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = null
