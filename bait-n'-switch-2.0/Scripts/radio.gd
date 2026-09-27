extends Node3D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var timer: Timer = $Timer

const MUSIC_FOLDER_PATH: String = "res://Cosy Tunes/" # Should accept .OGG .wav and .MP3 :))))
const MIN_WAIT_TIME: float = 1 
const MAX_WAIT_TIME: float = 120 # This is in seconds btw

var playlist: Array[AudioStream] = []

func _ready() -> void:
	load_songs_from_folder()
	
	timer.timeout.connect(_on_timer_timeout)
	
	# Start the first countdown
	start_random_timer()

func load_songs_from_folder() -> void:
	var dir = DirAccess.open(MUSIC_FOLDER_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".ogg") or file_name.ends_with(".mp3") or file_name.ends_with(".wav"):
					var full_path = MUSIC_FOLDER_PATH + file_name
					var song = load(full_path)
					if song is AudioStream:
						playlist.append(song)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func start_random_timer() -> void:
	# Pick a random wait time between the min and max limits
	var random_delay = randf_range(MIN_WAIT_TIME, MAX_WAIT_TIME)
	timer.start(random_delay)

func play_random_song() -> void:
	if playlist.is_empty():
		print("Playlist is empty!")
		return
		
	# Select a random song from the array and play it
	var random_index = randi() % playlist.size()
	audio_player.stream = playlist[random_index]
	audio_player.play()

func _on_timer_timeout() -> void:
	play_random_song() # Plays a random song when timer expires

func _on_audio_player_finished() -> void:
	start_random_timer() # Starts the timer when current song ends
