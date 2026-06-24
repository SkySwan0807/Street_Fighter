extends Node

var click_count = 0

var player1_character = ""
var player2_character = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	

func select_character(character:String, button:TextureButton):

	if click_count == 0:

		player1_character = character
		click_count += 1
		
		print("Jugador 1 eligió: ", character)
		button.disabled = true

	elif click_count == 1:

		player2_character = character
		click_count += 1

		print("Jugador 2 eligió: ", character)
		button.disabled = true

		start_fight()

func start_fight():

	print("P1: ",player1_character)
	print("P2: ",player2_character)

	#Los personajes elegidos se guardan en una variable global llamado 
	#Eleccion.player1_character	
	Eleccion.player1_character = player1_character
	Eleccion.player2_character = player2_character


	get_tree().change_scene_to_file(
		"res://scenes/arena.tscn"
	)


func _on_dee_jay_button_pressed() -> void:
	select_character(
		"DeeJay",
		$DeeJayButton
	)


func _on_cammi_button_pressed() -> void:
	select_character(
		"Cammi",
		$CammiButton
	)


func _on_m_bison_button_pressed() -> void:
	select_character(
		"MBison",
		$MBisonButton
	)
