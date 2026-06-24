extends Area2D

## Hurtbox genérica: reenvía el golpe recibido a quien sea su dueño
## (debe implementar take_damage(amount, knockback, attacker)).

var owner_fighter: Node = null


func receive_hit(amount: int, knockback: float, attacker: Node) -> void:
	if owner_fighter and owner_fighter.has_method("take_damage"):
		owner_fighter.take_damage(amount, knockback, attacker)
