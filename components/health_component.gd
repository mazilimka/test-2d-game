class_name HealthComponent
extends Node

@export var max_health : float = 100
@export var health : float = 100

signal zero_health
signal damaged

func set_health(value: float):
	health = min(value, max_health)
	if health <= 0:
		zero_health.emit()
		death()
	pass

func damage(dmg : float):
	set_health(health - dmg)
	damaged.emit()
	pass

func heal(amount: float):
	set_health(health + amount)


func death():
	print(get_parent())
	get_parent().death()
