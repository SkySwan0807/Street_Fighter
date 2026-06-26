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
@export var start_facing_right: bool = true

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
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
	current_health = max_health
	facing_right = start_facing_right
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

		State.HURT:
			_process_hurt(_delta)

		State.KO:
			velocity.x = move_toward(velocity.x, 0.0, move_speed * _delta)
			velocity.y += gravity * _delta

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

	if (Input.is_action_pressed("golpe_fuerte_p1") 
		and player_label == "Jugador_1"):
		change_potencia(Potencias.FUERTE)
		change_state(State.PUNCH)
	elif (Input.is_action_pressed("golpe_fuerte_p2") 
		and player_label == "Jugador_2"):
		change_potencia(Potencias.FUERTE)
		change_state(State.PUNCH)

	if (Input.is_action_pressed("golpe_medio_p1") 
		and player_label == "Jugador_1"):
		change_potencia(Potencias.MEDIO)
		change_state(State.PUNCH)
	elif (Input.is_action_pressed("golpe_medio_p2") 
		and player_label == "Jugador_2"):
		change_potencia(Potencias.MEDIO)
		change_state(State.PUNCH)

	if (Input.is_action_pressed("golpe_debil_p1") 
		and player_label == "Jugador_1"):
		change_potencia(Potencias.DEBIL)
		change_state(State.PUNCH)
	elif (Input.is_action_pressed("golpe_debil_p2") 
		and player_label == "Jugador_2"):
		change_potencia(Potencias.DEBIL)
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

	if (Input.is_action_pressed("golpe_fuerte_p1") 
		and player_label == "Jugador_1"):
		change_potencia(Potencias.FUERTE)
		change_state(State.PUNCH)
	elif (Input.is_action_pressed("golpe_fuerte_p2") 
		and player_label == "Jugador_2"):
		change_potencia(Potencias.FUERTE)
		change_state(State.PUNCH)

	if (Input.is_action_pressed("golpe_medio_p1") 
		and player_label == "Jugador_1"):
		change_potencia(Potencias.MEDIO)
		change_state(State.PUNCH)
	elif (Input.is_action_pressed("golpe_medio_p2") 
		and player_label == "Jugador_2"):
		change_potencia(Potencias.MEDIO)
		change_state(State.PUNCH)

	if (Input.is_action_pressed("golpe_debil_p1") 
		and player_label == "Jugador_1"):
		change_potencia(Potencias.DEBIL)
		change_state(State.PUNCH)
	elif (Input.is_action_pressed("golpe_debil_p2") 
		and player_label == "Jugador_2"):
		change_potencia(Potencias.DEBIL)
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
	hitbox.damage = heavy_damage
	hitbox.knockback = heavy_knockback
	hitbox.monitoring = true

func state_golpe_medio(_delta):
	velocity.x = 0
	visual.play("golpe_medio")
	hitbox.damage = medium_damage
	hitbox.knockback = medium_knockback
	hitbox.monitoring = true

func state_golpe_debil(_delta):
	velocity.x = 0
	visual.play("golpe_debil")
	hitbox.damage = light_damage
	hitbox.knockback = light_knockback
	hitbox.monitoring = true
	
func state_patada_fuerte(_delta):
	velocity.x = 0
	visual.play("patada_fuerte")
	hitbox.damage = heavy_damage
	hitbox.knockback = heavy_knockback
	hitbox.monitoring = true

func state_patada_medio(_delta):
	velocity.x = 0
	visual.play("patada_medio")
	hitbox.damage = medium_damage
	hitbox.knockback = medium_knockback
	hitbox.monitoring = true

func state_patada_debil(_delta):
	velocity.x = 0
	visual.play("patada_debil")
	hitbox.damage = light_damage
	hitbox.knockback = light_knockback
	hitbox.monitoring = true

func change_state(new_state):
	if state == new_state:
		return
		
	state = new_state

func change_potencia(new_potencia):
	if potencia == new_potencia:
		return
	potencia = new_potencia
	
func _on_animated_sprite_2d_animation_finished():
	match state:
		State.PUNCH, State.KICK:
			hitbox.monitoring = false
			change_state(State.IDLE)
		State.HURT:
			change_state(State.IDLE)

func _process_hurt(_delta: float) -> void:
	hurt_timer -= _delta
	velocity.x = move_toward(velocity.x, 0.0, move_speed * _delta * 3.0)
	if visual.animation != "danio":
		visual.play("danio")
	if hurt_timer <= 0.0:
		change_state(State.IDLE)

func take_damage(amount: int, knockback: float, attacker: Node) -> void:
	if state == State.KO:
		return

	var push_dir := -1.0 if facing_right else 1.0
	if attacker and attacker is Node2D:
		push_dir = -1.0 if attacker.global_position.x > global_position.x else 1.0

	velocity.x = push_dir * knockback
	velocity.y = -120.0

	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		_die()
	else:
		state = State.HURT
		hurt_timer = 0.3

func _die() -> void:
	state = State.KO
	hitbox.monitoring = false
	visual.play("danio")
	defeated.emit(self)

func _apply_facing() -> void:
	visual.flip_h = not facing_right
	hitbox_shape.position.x = 37.0 if facing_right else -37.0
	
func _face_opponent() -> void:
	if opponent == null:
		return

	facing_right = opponent.global_position.x > global_position.x
	
	_apply_facing()
