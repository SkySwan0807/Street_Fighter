extends Node2D

@onready var personaje: CharacterBody2D = $Cammy

func _ready():
	# No necesitas hacer nada aquí, el personaje se maneja solo
	pass

func _process(_delta):
	# El personaje ya maneja su propia lógica en _physics_process
	# No necesitas controlar las animaciones desde aquí
	pass
