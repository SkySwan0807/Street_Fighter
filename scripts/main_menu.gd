extends Control


func _on_start_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/arena.tscn")
	get_tree().change_scene_to_file("res://scenes/EleccionPersonaje.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
