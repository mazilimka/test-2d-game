extends PanelContainer

func _ready() -> void:
	%Restart.pressed.connect(restart_pressed)
	%Quit.pressed.connect(quit_pressed)


func open():
	get_tree().paused = true
	show()


func close():
	hide()
	get_tree().paused = false


func restart_pressed():
	close()
	get_tree().reload_current_scene()


func quit_pressed():
	get_tree().quit()
