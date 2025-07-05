extends PanelContainer



func _ready() -> void:
	%Start.pressed.connect(start_pressed)
	%Quit.pressed.connect(quit_pressed)
	congratulations()


func start_pressed():
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func quit_pressed():
	get_tree().quit()


func congratulations():
	var tween_rot := get_tree().create_tween().set_loops(-1).set_ease(Tween.EASE_IN_OUT).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_rot.tween_property(%Title, 'rotation', deg_to_rad(-10), 3)
	tween_rot.tween_property(%Title, 'rotation', deg_to_rad(+10), 3)
	
	var tween_scale := get_tree().create_tween().set_loops(-1).set_ease(Tween.EASE_IN_OUT).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var scale_x = %Title.scale.x
	var scale_y = %Title.scale.y
	tween_scale.tween_property(%Title, 'scale', Vector2(scale_x + 0.3, scale_y + 0.3), 4)
	tween_scale.tween_property(%Title, 'scale', Vector2(scale_x, scale_y), 4)
	
	var tween_mod := get_tree().create_tween().set_loops(-1).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_mod.tween_property(%Title, 'modulate', Color.YELLOW_GREEN, 2.5)
	tween_mod.tween_property(%Title, 'modulate', Color.ORANGE, 2.5)
	tween_mod.tween_property(%Title, 'modulate', Color.RED, 2.5)
	tween_mod.tween_property(%Title, 'modulate', Color.WHITE, 2)
