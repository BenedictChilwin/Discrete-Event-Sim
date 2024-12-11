class_name mainmenu
extends Control

@onready var start_button = $ButtonList/HBoxContainer/VBoxContainer/StartButton as Button
@onready var credits_button = $ButtonList/HBoxContainer/VBoxContainer/CreditsButton as Button
@onready var exit_button = $ButtonList/HBoxContainer/VBoxContainer/ExitButton as Button
@onready var button_list = $ButtonList as MarginContainer
@onready var credit = $Credits as credits

@onready var SIMULATION = preload("res://simulation/simulation.tscn") as PackedScene
#const menu = preload("res://menu/menu.tscn") as PackedScene 
#NGGARAI CRASH

func _ready():
	start_button.button_down.connect(OnStartClick) 
	exit_button.button_down.connect(OnExitClick)
	credits_button.button_down.connect(OnCreditsClick)
	credit.backToMenu.connect(OnCreditsExit)

func OnStartClick():
	get_tree().change_scene_to_packed(SIMULATION)

func OnExitClick():
	get_tree().quit()

func OnCreditsClick():
	credit.set_process(true)
	button_list.visible = false
	credit.visible = true

func OnCreditsExit():
	button_list.visible = true
	credit.visible = false

