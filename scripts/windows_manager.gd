extends CanvasLayer

@onready var win_window: PanelContainer = %WinWindow
@onready var death_window: PanelContainer = %DeathWindow

func _ready() -> void:
	Global.WindowManager = self
