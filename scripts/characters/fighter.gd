extends CharacterBody2D
class_name Fighter

signal health_changed(current_health: int, max_health: int)
signal defeated(fighter: Fighter)

enum State {
	IDLE,
	LEFT,
	RIGHT,
	PUNCH,
	KICK,
	HURT,
	JUMP,
	CROUCH,
	KO,
	WIN
}

enum Potencias {
	DEBIL,
	MEDIO,
	FUERTE
}

@export_group("Estadísticas")
@export var max_health: int = 100
@export var move_speed: float = 220.0
@export var jump_velocity: float = -500.0
@export var gravity: float = 1300.0

@export_group("Golpes")
@export var light_damage: int = 8
@export var light_active_time: float = 0.12
@export var light_recovery_time: float = 0.18
@export var light_knockback: float = 90.0

@export var medium_damage: int = 12
@export var medium_active_time: float = 0.14
@export var medium_recovery_time: float = 0.26
@export var medium_knockback: float = 130.0

@export var heavy_damage: int = 16
@export var heavy_active_time: float = 0.16
@export var heavy_recovery_time: float = 0.32
@export var heavy_knockback: float = 170.0

@export_group("Identidad")
@export var player_label: String

var state: State = State.IDLE
var potencia: Potencias = Potencias.DEBIL

var current_health: int
var facing_right: bool = true
var attack_phase_timer: float = 0.0
var attack_id: String = ""
var hurt_timer: float = 0.0

## Asignado desde la escena de la arena para que el personaje sepa hacia dónde mirar.
var opponent: Fighter = null

@onready var visual = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	current_health = max_health
	hurtbox.owner_fighter = self
	hitbox.owner_fighter = self
	hitbox.monitoring = false
	_apply_facing()

func _physics_process(_delta):
	if state in [State.IDLE, State.LEFT, State.JUMP, State.RIGHT]:
		_face_opponent()
		
	velocity.y += gravity * _delta
	match state:
		State.IDLE:
			state_idle(_delta)

		State.RIGHT:
			state_right(_delta)
			
		State.LEFT:
			state_left(_delta)
			
		State.JUMP:
			state_jump(_delta)
			
		State.CROUCH:
			state_crouch(_delta)
			
		State.PUNCH:
			match potencia:
				Potencias.FUERTE:
					state_golpe_fuerte(_delta)
				Potencias.MEDIO:
					state_golpe_medio(_delta)
				Potencias.DEBIL:
					state_golpe_debil(_delta)
					
		State.KICK:
			match potencia:
				Potencias.FUERTE:
					state_patada_fuerte(_delta)
				Potencias.MEDIO:
					state_patada_medio(_delta)
				Potencias.DEBIL:
					state_patada_debil(_delta)
			
	move_and_slide()
			
func state_idle(_delta):
	
	velocity.x = 0
	if visual.animation != "idle":
		visual.play("idle")
	
	if (Input.is_action_pressed("derecha_p1") 
		and player_label == "Jugador_1"):
		change_state(State.RIGHT)
	elif (Input.is_action_pressed("derecha_p2") 
		and player_label == "Jugador_2"):
		change_state(State.RIGHT)
	
	if (Input.is_action_pressed("izquierda_p1") 
		and player_label == "Jugador_1"):
		change_state(State.LEFT)
	elif (Input.is_action_pressed("izquierda_p2") 
		and player_label == "Jugador_2"):
		change_state(State.LEFT)
		
	if (Input.is_action_pressed("salto_p1") 
		and player_label == "Jugador_1"
		and is_on_floor()):
		velocity.y = jump_velocity
		change_state(State.JUMP)
	elif (Input.is_action_pressed("salto_p2") 
		and player_label == "Jugador_2"
		and is_on_floor()):
		velocity.y = jump_velocity
		change_state(State.JUMP)
		
	if (Input.is_action_pressed("agacharse_p1") 
		and player_label == "Jugador_1"
		and is_on_floor()):
		change_state(State.CROUCH)
	elif (Input.is_action_pressed("agacharse_p2") 
		and player_label == "Jugador_2"
		and is_on_floor()):
		change_state(State.CROUCH)
	
	if (Input.is_action_pressed("golpe_fuerte_p1") 
		and player_label == "Jugador_1"):
		change_potencia(Potencias.FUERTE)
		change_state(State.PUNCH)
	elif (Input.is_action_pressed("golpe_fuerte_p2") 
		and player_label == "Jugador_2"):
		change_potencia(Potencias.FUERTE)
		change_state(State.PUNCH)
	
	if (Input.is_action_pressed("golpe_debil_p1") 
		and player_label == "Jugador_1"):
		change_potencia(Potencias.DEBIL)
		change_state(State.PUNCH)
	elif (Input.is_action_pressed("golpe_debil_p2") 
		and player_label == "Jugador_2"):
		change_potencia(Potencias.DEBIL)
		change_state(State.PUNCH)
	
	if (Input.is_action_pressed("golpe_medio_p1") 
		and player_label == "Jugador_1"):
		change_potencia(Potencias.MEDIO)
		change_state(State.PUNCH)
	elif (Input.is_action_pressed("golpe_medio_p2") 
		and player_label == "Jugador_2"):
		change_potencia(Potencias.MEDIO)
		change_state(State.PUNCH)

	if (Input.is_action_pressed("patada_fuerte_p1") 
		and player_label == "Jugador_1"):
		change_potencia(Potencias.FUERTE)
		change_state(State.KICK)
	elif (Input.is_action_pressed("patada_fuerte_p2") 
		and player_label == "Jugador_2"):
		change_potencia(Potencias.FUERTE)
		change_state(State.KICK)
	
	if (Input.is_action_pressed("patada_medio_p1") 
		and player_label == "Jugador_1"):
		change_potencia(Potencias.MEDIO)
		change_state(State.KICK)
	elif (Input.is_action_pressed("patada_medio_p2") 
		and player_label == "Jugador_2"):
		change_potencia(Potencias.MEDIO)
		change_state(State.KICK)
		
	if (Input.is_action_pressed("patada_debil_p1") 
		and player_label == "Jugador_1"):
		change_potencia(Potencias.DEBIL)
		change_state(State.KICK)
	elif (Input.is_action_pressed("patada_debil_p2") 
		and player_label == "Jugador_2"):
		change_potencia(Potencias.DEBIL)
		change_state(State.KICK)

func state_right(_delta):
	var direction
	if facing_right:
		visual.play("caminar_adelante")
	else:
		visual.play("caminar_atras")
		
	if player_label == "Jugador_1":
		direction = Input.get_axis("izquierda_p1", "derecha_p1")
	elif player_label == "Jugador_2":
		direction = Input.get_axis("izquierda_p2", "derecha_p2")
	
	if direction == 0:
		change_state(State.IDLE)

	velocity.x = direction * move_speed

	if Input.is_action_just_pressed("golpe_fuerte_p1"):
		change_potencia(Potencias.FUERTE)
		change_state(State.PUNCH)
		
func state_left(_delta):
	
	var direction
	if facing_right:
		visual.play("caminar_atras")
	else:
		visual.play("caminar_adelante")

	if player_label == "Jugador_1":
		direction = Input.get_axis("izquierda_p1", "derecha_p1")
	elif player_label == "Jugador_2":
		direction = Input.get_axis("izquierda_p2", "derecha_p2")
	
	if direction == 0:
		change_state(State.IDLE)

	velocity.x = direction * move_speed

	if Input.is_action_just_pressed("golpe_fuerte_p1"):
		change_potencia(Potencias.FUERTE)
		change_state(State.PUNCH)

func state_jump(_delta):
	# Permitir movimiento horizontal en el aire
	var direction
	if player_label == "Jugador_1":
		direction = Input.get_axis("izquierda_p1", "derecha_p1")
	elif player_label == "Jugador_2":
		direction = Input.get_axis("izquierda_p2", "derecha_p2")
		
	velocity.x = direction * move_speed

	if visual.animation != "salto":
		visual.play("salto")

	# Cuando toque el suelo, volver a idle
	if is_on_floor():
		change_state(State.IDLE)

func state_crouch(_delta):
	velocity.x = 0
	if visual.animation != "agacharse":
		visual.play("agacharse")
	if (not Input.is_action_pressed("agacharse_p1")
		and player_label == "Jugador_1"):
		change_state(State.IDLE)
	if (not Input.is_action_pressed("agacharse_p2") 
		and player_label == "Jugador_2"):
		change_state(State.IDLE)

func state_golpe_fuerte(_delta):
	velocity.x = 0
	visual.play("golpe_fuerte")

func state_golpe_medio(_delta):
	velocity.x = 0
	visual.play("golpe_medio")

func state_golpe_debil(_delta):
	velocity.x = 0
	visual.play("golpe_debil")
	
func state_patada_fuerte(_delta):
	velocity.x = 0
	visual.play("patada_fuerte")

func state_patada_medio(_delta):
	velocity.x = 0
	visual.play("patada_medio")

func state_patada_debil(_delta):
	velocity.x = 0
	visual.play("patada_debil")

func change_state(new_state):
	if state == new_state:
		return
		
	state = new_state

func change_potencia(new_potencia):
	if potencia == new_potencia:
		return
	potencia = new_potencia
	
func _on_animated_sprite_2d_animation_finished():
	#print("Animación terminada:", $AnimatedSprite2D.animation)
	#print("Cambio de estado a Idle")
	match state:
		State.PUNCH, State.KICK:
			change_state(State.IDLE)

func _apply_facing() -> void:
	visual.flip_h = not facing_right
	
func _face_opponent() -> void:
	if opponent == null:
		return

	facing_right = opponent.global_position.x > global_position.x
	
	_apply_facing()
