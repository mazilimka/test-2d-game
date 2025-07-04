extends AnimatableBody2D

@export var self_number := 1

func _ready() -> void:
	$Area2D.body_entered.connect(activate)


func activate(body: CharacterBody2D):
	if body == Global.Player:
		get_parent().get_node("PlatformAnimation").play(str(self_number))
