extends CharacterBody2D
class_name Fighter

## Controlador de personaje de pelea, simple y legible.
##
## CÓMO AGREGAR UN PERSONAJE NUEVO:
##   Duplica player.tscn, cambia los valores exportados (vida, velocidad,
##   daños) y crea su archivo *_spriteframes.tres en assets/characters/.
##   No hace falta tocar código.
##
## CÓMO AGREGAR UN GOLPE NUEVO:
##   Agrega variables exportadas (daño/duración/empuje) y una rama nueva
##   en _process_ground() que llame a _start_attack("nombre_del_golpe").

signal health_changed(current_health: int, max_health: int)
signal defeated(fighter: Fighter)

enum State { IDLE, WALK, JUMP, FALL, ATTACK, BLOCK, HURT, KO }

@export_group("Estadísticas")
@export var max_health: int = 100
@export var move_speed: float = 220.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1300.0

@export_group("Golpes")
@export var light_damage: int = 8
@export var light_active_time: float = 0.12
@export var light_recovery_time: float = 0.18
@export var light_knockback: float = 90.0

@export var heavy_damage: int = 16
@export var heavy_active_time: float = 0.16
@export var heavy_recovery_time: float = 0.32
@export var heavy_knockback: float = 170.0

@export_group("Identidad")
@export var player_label: String = "Jugador"
@export var start_facing_right: bool = true

@export_group("Controles")
@export var key_left: int = KEY_A
@export var key_right: int = KEY_D
@export var key_jump: int = KEY_W
@export var key_light_attack: int = KEY_F
@export var key_heavy_attack: int = KEY_G
@export var key_block: int = KEY_S

var state: State = State.IDLE
var current_health: int
var facing_right: bool = true
var attack_phase_timer: float = 0.0
var attack_id: String = ""
var hurt_timer: float = 0.0

## Asignado desde la escena de la arena para que el personaje sepa
## hacia dónde mirar.
var opponent: Fighter = null

@onready var animated_sprite: AnimatedSprite2D = $Visual
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox


func _ready() -> void:
	current_health = max_health
	facing_right = start_facing_right
	hurtbox.owner_fighter = self
	hitbox.owner_fighter = self
	hitbox.monitoring = false
	_apply_facing()


func _physics_process(delta: float) -> void:
	if state == State.KO:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * delta)
		velocity.y += gravity * delta
		move_and_slide()
		return

	if state in [State.IDLE, State.WALK, State.JUMP, State.FALL]:
		_face_opponent()

	velocity.y += gravity * delta

	match state:
		State.IDLE, State.WALK:
			_process_ground(delta)
		State.JUMP, State.FALL:
			_process_air(delta)
		State.ATTACK:
			_process_attack(delta)
		State.BLOCK:
			_process_block(delta)
		State.HURT:
			_process_hurt(delta)

	move_and_slide()

	if state in [State.IDLE, State.WALK, State.JUMP, State.FALL]:
		if not is_on_floor():
			state = State.FALL
		elif state == State.FALL:
			state = State.IDLE if abs(velocity.x) < 1.0 else State.WALK

	_update_animation()


func _face_opponent() -> void:
	if opponent == null:
		return
	facing_right = opponent.global_position.x > global_position.x
	_apply_facing()


func _process_ground(_delta: float) -> void:
	var dir := 0.0
	if Input.is_physical_key_pressed(key_left):
		dir -= 1.0
	if Input.is_physical_key_pressed(key_right):
		dir += 1.0

	velocity.x = dir * move_speed
	state = State.WALK if dir != 0.0 else State.IDLE

	if Input.is_physical_key_pressed(key_jump) and is_on_floor():
		velocity.y = jump_velocity
		state = State.JUMP
		return

	if Input.is_physical_key_pressed(key_block):
		state = State.BLOCK
		return

	if Input.is_physical_key_pressed(key_light_attack):
		_start_attack("light")
	elif Input.is_physical_key_pressed(key_heavy_attack):
		_start_attack("heavy")


func _process_air(_delta: float) -> void:
	var dir := 0.0
	if Input.is_physical_key_pressed(key_left):
		dir -= 1.0
	if Input.is_physical_key_pressed(key_right):
		dir += 1.0
	velocity.x = dir * move_speed
	state = State.JUMP if velocity.y < 0.0 else State.FALL


func _start_attack(id: String) -> void:
	state = State.ATTACK
	attack_id = id
	attack_phase_timer = 0.0
	velocity.x = 0.0

	hitbox.damage = light_damage if id == "light" else heavy_damage
	hitbox.knockback = light_knockback if id == "light" else heavy_knockback
	hitbox.monitoring = true


func _process_attack(delta: float) -> void:
	attack_phase_timer += delta
	var active_time: float = light_active_time if attack_id == "light" else heavy_active_time
	var recovery_time: float = light_recovery_time if attack_id == "light" else heavy_recovery_time

	velocity.x = move_toward(velocity.x, 0.0, move_speed * delta * 4.0)

	if attack_phase_timer >= active_time:
		hitbox.monitoring = false

	if attack_phase_timer >= active_time + recovery_time:
		state = State.IDLE
		attack_id = ""


func _process_block(_delta: float) -> void:
	velocity.x = 0.0
	if not Input.is_physical_key_pressed(key_block):
		state = State.IDLE


func _process_hurt(delta: float) -> void:
	hurt_timer -= delta
	velocity.x = move_toward(velocity.x, 0.0, move_speed * delta * 3.0)
	if hurt_timer <= 0.0:
		state = State.IDLE


func take_damage(amount: int, knockback: float, attacker: Node) -> void:
	if state == State.KO:
		return

	var push_dir := -1.0 if facing_right else 1.0
	if attacker and attacker is Node2D:
		push_dir = -1.0 if attacker.global_position.x > global_position.x else 1.0

	if state == State.BLOCK:
		amount = int(ceil(amount * 0.2))
		velocity.x = push_dir * knockback * 0.25
	else:
		velocity.x = push_dir * knockback
		velocity.y = -120.0
		state = State.HURT
		hurt_timer = 0.3

	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		_die()


func _die() -> void:
	state = State.KO
	hitbox.monitoring = false
	defeated.emit(self)


func _apply_facing() -> void:
	scale.x = 1.0 if facing_right else -1.0


func setup_character(char_name: String) -> void:
	var path: String = "res://assets/characters/%s_spriteframes.tres" % char_name
	if ResourceLoader.exists(path):
		animated_sprite.sprite_frames = load(path) as SpriteFrames
	_update_animation()


func _update_animation() -> void:
	if not animated_sprite.sprite_frames:
		return
	var anim_name: String = ""
	match state:
		State.IDLE:
			anim_name = "quieto"
		State.WALK:
			anim_name = "caminar"
		State.JUMP:
			anim_name = "saltar"
		State.FALL:
			anim_name = "caer"
		State.ATTACK:
			anim_name = "golpe_ligero" if attack_id == "light" else "golpe_pesado"
		State.BLOCK:
			anim_name = "bloquear"
		State.HURT:
			anim_name = "recibir_daño"
		State.KO:
			anim_name = "nocaut"
	if anim_name != "" and animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)
