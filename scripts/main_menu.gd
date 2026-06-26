extends Control

func _ready() -> void:
	if ResourceLoader.exists("res://assets/audio/menu.mp3"):
		var menu_music := load("res://assets/audio/menu.mp3") as AudioStream
		GameManager.play_music(menu_music)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/EleccionPersonaje.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
