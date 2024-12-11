class_name input
extends Control

const SAVE_FOLDER = "user://"
@onready var main = $"." as Control
@onready var current_seed = $Panel/CurrentSeed as Label
@onready var close_input = $Panel/MarginContainer/CloseInput as Button
var hasGeneratedLCG = false

signal manual_simulation
signal auto_simulation

#NILAI PENTING
var seed = 0
var beta_interarrival = 141.0
var beta_service_time = 66.0
var split = 5
var total_data = 100 #DEFAULT 100
var lcg = []

#TOTAL DATA
@onready var total_data_input = $Panel/MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/TotalData as LineEdit
@onready var error_total_data = $Panel/ErrorTotalData as Label
@onready var success_total_data = $Panel/SuccessTotalData as Label


@onready var total_data_submit = $Panel/MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/TotalDataSubmit as Button

#LCG
@onready var generate_lcg = $Panel/MarginContainer/VBoxContainer/InsertDatas/GeneratorLCG/HBoxContainer/GenerateLCG as Button
@onready var error_lcg = $Panel/ErrorLCG as Label
@onready var success_lcg = $Panel/SuccessLCG as Label
@onready var lcg_seed = $Panel/MarginContainer/VBoxContainer/InsertDatas/GeneratorLCG/LCG_seed as LineEdit

#LCG SAVE
@onready var error_saved_lcg = $Panel/ErrorSavedLCG as Label
@onready var saved_lcg = $Panel/SavedLCG as Label
@onready var save_lcg = $Panel/MarginContainer/VBoxContainer/InsertDatas/GeneratorLCG/HBoxContainer/SaveLCG as Button

#BETA
@onready var input_interarrival = $Panel/MarginContainer/VBoxContainer/InsertDatas/InsertBeta/HBoxContainer/Interarrival as LineEdit
@onready var input_service_time = $Panel/MarginContainer/VBoxContainer/InsertDatas/InsertBeta/HBoxContainer2/ServiceTime as LineEdit

#CORE SIMULATE
@onready var simulate = $Panel/MarginContainer/VBoxContainer/Bottombuttons/Sim as Button
@onready var auto_simulate = $Panel/MarginContainer/VBoxContainer/Bottombuttons/AutoSim as Button
@onready var error_simulate = $Panel/ErrorSimulate as Label
@onready var input_split = $Panel/MarginContainer/VBoxContainer/Bottombuttons/VBoxContainer/Split as LineEdit


func _ready():
	
	close_input.button_down.connect(Close)
	
	#TOTAL DATA
	total_data_submit.button_down.connect(SubmitTotalData)
	#LCG
	generate_lcg.button_down.connect(StartGenerateLCG)
	#LCG SAVE
	save_lcg.button_down.connect(SaveToCSV)
	#SIM
	simulate.button_down.connect(Simulate)
	auto_simulate.button_down.connect(AutoSim)

func StartGenerateLCG():
	var new_seed = lcg_seed.get_text()
	
	if new_seed.is_valid_int(): #jika inputan integer baru masuk
		seed = int(new_seed)
		current_seed.set_text("Seed: " + str(seed))
		lcg_seed.clear()
		hasGeneratedLCG = true
		
		GenerateLCG()
		
		success_lcg.visible = true
		await get_tree().create_timer(2.0).timeout
		success_lcg.visible = false
		
	else:
		error_lcg.visible = true
		await get_tree().create_timer(2.0).timeout
		error_lcg.visible = false

func GenerateLCG():
	var a = 1103515245
	var c = 12345
	var m = 2**31
	var x = seed
	lcg.clear()
	
	for i in range(total_data):
		x = (a * x + c) % m
		lcg.append(float(x)/m)
		
	#for i in range(total_data):
		#print(lcg[i])

func SaveToCSV():
	if(hasGeneratedLCG):
		
		var directory = "user://LCGdata_"+str(seed)+".csv"
		
		var SaveFile = FileAccess.open(directory, FileAccess.WRITE)
		var savedata = ""
		for i in lcg:
			savedata += str(i)
			savedata += "\n"
			
		SaveFile.store_string(savedata)
		
		saved_lcg.visible = true
		await get_tree().create_timer(2.0).timeout
		saved_lcg.visible = false
	else:
		error_saved_lcg.visible = true
		await get_tree().create_timer(2.0).timeout
		error_saved_lcg.visible = false

func Simulate():
	if CheckValid():
		print("sim manual")
		
		SetSimulationVariable()
		manual_simulation.emit()
		#SIM MANUAL
		Close()
		
	else:
		HandleSimError()

func AutoSim():
	if CheckValid():
		print("sim auto")
		
		SetSimulationVariable()
		auto_simulation.emit()
		#AUTOSIM
		Close()
		
	else:
		HandleSimError()

func SetSimulationVariable():
	beta_interarrival = float(input_interarrival.get_text())
	beta_service_time = float(input_service_time.get_text())
	split = input_split.get_text()

func HandleSimError():
	if !hasGeneratedLCG:
		error_simulate.text = "Generate LCG terlebih dulu."
	elif !input_split.get_text().is_valid_int() or input_split.get_text() == "0":
		error_simulate.text = "Masukkan jumlah split valid."
	else:
		error_simulate.text = "Masukkan input yang valid."
	error_simulate.visible = true
	
	input_interarrival.set_text(str(beta_interarrival))
	input_service_time.set_text(str(beta_service_time))
	input_split.set_text(str(split))
	
	await get_tree().create_timer(2.0).timeout
	error_simulate.visible = false

func CheckValid():
	if seed != 0 and input_interarrival.get_text().is_valid_float() and input_service_time.get_text().is_valid_float() and input_split.get_text().is_valid_int() and !input_split.get_text() == "0":
		return true
	else:
		return false

func SubmitTotalData():
	if total_data_input.get_text().is_valid_int() and !total_data_input.get_text() == "0":
		total_data = int(total_data_input.get_text())
		success_total_data.visible = true
		await get_tree().create_timer(2.0).timeout
		success_total_data.visible = false
	else:
		total_data_input.set_text(str(total_data))
		error_total_data.visible = true
		await get_tree().create_timer(2.0).timeout
		error_total_data.visible = false

func ReturnData():
	return [beta_interarrival, beta_service_time, split, total_data, lcg, seed]

func Close():
	set_process(false)
	main.visible = false
	


