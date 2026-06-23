extends CharacterBody2D

enum State {
	IDLE,
	FORWARD,
	BACKWARDS,
	JUMP,
	ATTACK,
	HURT
}

var state = State.IDLE
var speed = 300

func _physics_process(_delta):
	match state:
		State.IDLE:
			state_idle(_delta)

		State.FORWARD:
			state_forward(_delta)
			
		State.BACKWARDS:
			state_backwards(_delta)
			
	move_and_slide()
			
func state_idle(_delta):
	
	velocity.x = 0
	$AnimatedSprite2D.play("idle")

	if Input.is_action_pressed("derecha_p1"):
		change_state(State.FORWARD)
	
	if Input.is_action_pressed("izquierda_p1"):
		change_state(State.BACKWARDS)

	if Input.is_action_just_pressed("attack"):
		change_state(State.ATTACK)


func state_forward(_delta):
	$AnimatedSprite2D.play("caminar_adelante")

	var direction = Input.get_axis("izquierda_p1", "derecha_p1")
	
	if direction == 0:
		change_state(State.IDLE)

	velocity.x = direction * speed

	if Input.is_action_just_pressed("attack"):
		change_state(State.ATTACK)
		
func state_backwards(_delta):
	$AnimatedSprite2D.play("caminar_atras")

	var direction = Input.get_axis("izquierda_p1", "derecha_p1")
	
	if direction == 0:
		change_state(State.IDLE)

	velocity.x = direction * speed

	if Input.is_action_just_pressed("attack"):
		change_state(State.ATTACK)

func change_state(new_state):
	if state == new_state:
		return

	state = new_state
