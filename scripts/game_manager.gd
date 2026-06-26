extends Node

var player1_character: String = ""
var player2_character: String = ""

var music_player: AudioStreamPlayer

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Master"
	music_player.volume_db = -10.0
	add_child(music_player)

func start_fight() -> void:
	get_tree().change_scene_to_file("res://scenes/arena.tscn")

func return_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func play_music(stream: AudioStream, loop: bool = true) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	if "loop" in stream:
		stream.loop = loop
	music_player.stream = stream
	music_player.play()

func stop_music() -> void:
	music_player.stop()
