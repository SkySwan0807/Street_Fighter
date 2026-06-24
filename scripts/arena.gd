extends Node2D

## Controla el round de pelea: enlaza a los dos Fighter entre sí,
## actualiza las barras de vida, lleva el temporizador y decide
## quién gana (por KO o por tiempo).

const ROUND_TIME: float = 60.0

@onready var player1: Fighter = $Player1
@onready var player2: Fighter = $Player2
@onready var p1_health_bar: ProgressBar = $UI/HUD/P1HealthBar
@onready var p2_health_bar: ProgressBar = $UI/HUD/P2HealthBar
@onready var timer_label: Label = $UI/HUD/TimerLabel
@onready var round_over_panel: Panel = $UI/HUD/RoundOverPanel
@onready var winner_label: Label = $UI/HUD/RoundOverPanel/WinnerLabel

var time_left: float = ROUND_TIME
var round_active: bool = true


func _ready() -> void:
	player1.opponent = player2
	player2.opponent = player1

	player1.health_changed.connect(_on_p1_health_changed)
	player2.health_changed.connect(_on_p2_health_changed)
	player1.defeated.connect(_on_fighter_defeated)
	player2.defeated.connect(_on_fighter_defeated)

	round_over_panel.visible = false
	_update_timer_label()
	print("Eleccion.player1_character = ", Eleccion.player1_character)
	print("Eleccion.player2_character = ", Eleccion.player2_character)


func _process(delta: float) -> void:
	if not round_active:
		return
	time_left = max(time_left - delta, 0.0)
	_update_timer_label()
	if time_left <= 0.0:
		_end_round_by_time()


func _update_timer_label() -> void:
	timer_label.text = str(int(ceil(time_left)))


func _on_p1_health_changed(current: int, max_h: int) -> void:
	p1_health_bar.max_value = max_h
	p1_health_bar.value = current


func _on_p2_health_changed(current: int, max_h: int) -> void:
	p2_health_bar.max_value = max_h
	p2_health_bar.value = current


func _on_fighter_defeated(fighter: Fighter) -> void:
	if not round_active:
		return
	var winner_name: String = player2.player_label if fighter == player1 else player1.player_label
	_show_winner(winner_name)


func _end_round_by_time() -> void:
	if not round_active:
		return
	var winner_name: String
	if player1.current_health == player2.current_health:
		winner_name = "Empate"
	elif player1.current_health > player2.current_health:
		winner_name = player1.player_label
	else:
		winner_name = player2.player_label
	_show_winner(winner_name)


func _show_winner(winner_name: String) -> void:
	round_active = false
	if winner_name == "Empate":
		winner_label.text = "¡Empate!"
	else:
		winner_label.text = "¡%s gana!" % winner_name
	round_over_panel.visible = true


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
