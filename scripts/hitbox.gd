extends Area2D

## Hitbox genérica: hace daño a cualquier Area2D que tenga un método
## receive_hit(). Normalmente ese receptor es una Hurtbox.
## Pensada para reutilizarse en golpes, proyectiles, trampas del escenario, etc.

var damage: int = 0
var knockback: float = 0.0
var owner_fighter: Node = null


func _ready() -> void:
	monitoring = false
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area == null or not area.has_method("receive_hit"):
		return
	# Evita auto-golpearse si el hitbox y el hurtbox son del mismo personaje.
	if "owner_fighter" in area and area.owner_fighter == owner_fighter:
		return
	area.receive_hit(damage, knockback, owner_fighter)
