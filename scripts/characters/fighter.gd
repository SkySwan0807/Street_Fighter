extends CharacterBody2D

enum State {
	IDLE,
	FORWARD,
	BACKWARDS,
	PUNCH,
	KICK,
	HURT
}

enum Potencias {
	DEBIL,
	MEDIO,
	FUERTE
}

var state = State.IDLE
var potencia = Potencias.DEBIL
var speed = 200

func _physics_process(_delta):
	match state:
		State.IDLE:
			state_idle(_delta)

		State.FORWARD:
			state_forward(_delta)
			
		State.BACKWARDS:
			state_backwards(_delta)
			
		State.PUNCH:
			match potencia:
				Potencias.FUERTE:
					state_golpe_fuerte(_delta)
				Potencias.MEDIO:
					state_golpe_medio(_delta)
				Potencias.DEBIL:
					state_golpe_debil(_delta)
			
	move_and_slide()
			
func state_idle(_delta):
	
	velocity.x = 0
	if $AnimatedSprite2D.animation != "idle":
		$AnimatedSprite2D.play("idle")

	if Input.is_action_pressed("derecha_p1"):
		change_state(State.FORWARD)
	
	if Input.is_action_pressed("izquierda_p1"):
		change_state(State.BACKWARDS)

	if Input.is_action_just_pressed("golpe_fuerte_p1"):
		change_potencia(Potencias.FUERTE)
		change_state(State.PUNCH)
	
	if Input.is_action_just_pressed("golpe_debil_p1"):
		change_potencia(Potencias.DEBIL)
		change_state(State.PUNCH)
	
	if Input.is_action_just_pressed("golpe_medio_p1"):
		change_potencia(Potencias.MEDIO)
		change_state(State.PUNCH)


func state_forward(_delta):
	$AnimatedSprite2D.play("caminar_adelante")

	var direction = Input.get_axis("izquierda_p1", "derecha_p1")
	
	if direction == 0:
		change_state(State.IDLE)

	velocity.x = direction * speed

	if Input.is_action_just_pressed("golpe_fuerte_p1"):
		change_potencia(Potencias.FUERTE)
		change_state(State.PUNCH)
		
func state_backwards(_delta):
	$AnimatedSprite2D.play("caminar_atras")

	var direction = Input.get_axis("izquierda_p1", "derecha_p1")
	
	if direction == 0:
		change_state(State.IDLE)

	velocity.x = direction * speed

	if Input.is_action_just_pressed("golpe_fuerte_p1"):
		change_potencia(Potencias.FUERTE)
		change_state(State.PUNCH)

func state_golpe_fuerte(_delta):
	velocity.x = 0
	$AnimatedSprite2D.play("golpe_fuerte")

func state_golpe_medio(_delta):
	velocity.x = 0
	$AnimatedSprite2D.play("golpe_medio")

func state_golpe_debil(_delta):
	velocity.x = 0
	$AnimatedSprite2D.play("golpe_debil")

func change_state(new_state):
	if state == new_state:
		return

	state = new_state
"""
	match state:
		State.IDLE:
			$AnimatedSprite2D.play("idle")

		State.FORWARD:
			$AnimatedSprite2D.play("caminar_adelante")

		State.BACKWARDS:
			$AnimatedSprite2D.play("caminar_atras")

		State.PUNCH:
			match potencia:
				Potencias.FUERTE:
					$AnimatedSprite2D.play("golpe_fuerte")
"""
func change_potencia(new_potencia):
	if potencia == new_potencia:
		return
	potencia = new_potencia
	
func _on_animated_sprite_2d_animation_finished():
	print("Animación terminada:", $AnimatedSprite2D.animation)

	if ($AnimatedSprite2D.animation == "golpe_fuerte"
		or $AnimatedSprite2D.animation == "golpe_debil"
		or $AnimatedSprite2D.animation == "golpe_medio"):
		print("Cambio de estado a Idle")
		change_state(State.IDLE)
