extends Area2D


func _ready() -> void:
	body_entered.connect(goal_has_achived)


func goal_has_achived(body: CharacterBody2D):
	Global.WindowManager.win_window.open()
