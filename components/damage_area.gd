class_name DamageAreaComponent
extends Area2D

func damage(dmg : float):
	var _comp = Global.get_component(get_parent(), "HealthComponent")
	if _comp:
		_comp.damage(dmg)
