class_name credits
extends Control

@onready var exit_button = $MarginContainer/VBoxContainer/ExitButton as Button
signal backToMenu


func _ready():
	exit_button.button_down.connect(OnExitPress)
	set_process(false) #matikan

func OnExitPress():
	backToMenu.emit()
	set_process(false)
