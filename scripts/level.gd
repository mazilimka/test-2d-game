extends Node2D

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.get_key_label() == KEY_R:
			get_tree().reload_current_scene()


func _on_bottom_border_area_body_entered(body: CharacterBody2D) -> void:
	if body == Global.Player:
		Global.Player.queue_free()
		Global.WindowManager.death_window.open()
	elif body.is_in_group("Enemies"):
		body.queue_free()
