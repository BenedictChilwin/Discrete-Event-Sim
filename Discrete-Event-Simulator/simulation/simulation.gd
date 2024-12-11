class_name simulation
extends Control

#NILAI PENTING
var beta_interarrival = 0.0
var beta_service_time = 0.0
var split = 0
var total_data = 0
var lcg = []
var seed = 0

var ReplikasiKe = 1
var DataPerReplikasi = 0

var arrival_times = [] #array random variate arrival
var service_times = [] #array random variate depart
var index_arrival = 0 #index ke brp pada array arrival (anggep pointer)
var index_service = 0 #index ke brp pada array depart 
var TotalInSystem = 0 #brp banyak orang yg sedang di dalam sistem

@onready var input_screen = $MarginContainer/Input/HBoxContainer/Control as input
@onready var stats = $MarginContainer/Stats 

#TOP LEFT DISPLAY
@onready var seed_label = $MarginContainer/VBoxContainer/seed
@onready var beta_interarrival_label = $"MarginContainer/VBoxContainer/beta interarrival"
@onready var beta_service_label = $"MarginContainer/VBoxContainer/beta service"
@onready var replikasi_ke = $MarginContainer/VBoxContainer/Replikasi_ke


#CHART
@onready var queue_chart = preload("res://addons/easy_charts/examples/line_chart/QueueChart.tscn")
@onready var margin_container = $MarginContainer
signal ShowChart

#CLOCK EVENT
var Clock = 0
@onready var clock_label = $MarginContainer/Stats/StatisticContainer/ClockEventList/VBoxContainer/Clock as Label
var event_arrive = 0.0
@onready var arrival_label = $MarginContainer/Stats/StatisticContainer/ClockEventList/VBoxContainer2/HBoxContainer/VBoxContainer/Arrival as Label
@onready var label_2 = $MarginContainer/Stats/StatisticContainer/ClockEventList/VBoxContainer2/HBoxContainer/VBoxContainer/Label2 as Label
var event_service = 0.0
@onready var depart_label = $MarginContainer/Stats/StatisticContainer/ClockEventList/VBoxContainer2/HBoxContainer/VBoxContainer2/Depart as Label
@onready var label_3 = $MarginContainer/Stats/StatisticContainer/ClockEventList/VBoxContainer2/HBoxContainer/VBoxContainer2/Label3 as Label

#DELAY & AREA
var NumberDelay = 0
@onready var number_delay_label = $MarginContainer/Stats/StatisticContainer/DelaydanArea/VBoxContainer/NumberDelay as Label
var TotalDelay = 0.0
@onready var total_delay_label = $MarginContainer/Stats/StatisticContainer/DelaydanArea/VBoxContainer2/TotalDelay as Label
var QT_x = 0
var QT_y = 0
var AreaQT = 0.0
var ArrayAreaQTx = [] #BUAT GRAFIK
var ArrayAreaQTy = []

@onready var area_qt_label = $MarginContainer/Stats/StatisticContainer/DelaydanArea/VBoxContainer3/AreaQT as Label
var AreaBT = 0.0
var HelperBT = 0.0 #x
var ArrayAreaBTx = [0.0]  #BUAT GRAFIK
var ArrayAreaBTy = []
@onready var area_bt_label = $MarginContainer/Stats/StatisticContainer/DelaydanArea/VBoxContainer4/AreaBT as Label

#SERVER STATUSES
var ServerIsBusy = false
@onready var server_status_label = $MarginContainer/Stats/StatisticContainer/ServerStatuses/VBoxContainer/ServerStatus as Label
var NumberInQueue = 0
@onready var number_in_queue_label = $MarginContainer/Stats/StatisticContainer/ServerStatuses/VBoxContainer2/NumberInQueue as Label

var dn = 0.0
var Arraydn = []
@onready var dn_label = $MarginContainer/Stats/StatisticContainer/Stats/VBoxContainer/dn as Label
var qn = 0.0
var Arrayqn = []
@onready var qn_label = $MarginContainer/Stats/StatisticContainer/Stats/VBoxContainer2/qn as Label
var un = 0.0
var Arrayun = []
@onready var un_label = $MarginContainer/Stats/StatisticContainer/Stats/VBoxContainer3/un as Label

#QUEUE
var InQueue = []  #orang yg di dalam sistem
@onready var first_on_queue = $MarginContainer/Stats/QueueView/t/FirstOnQueue as Label
@onready var queue_view = $MarginContainer/Stats/QueueView/t/queues as Label
var data_left = 0
@onready var data_left_label = $MarginContainer/Stats/QueueView/t/dataleft as Label

#BUTTONS
@onready var next_event = $MarginContainer/Stats/ButtonContainer/HBoxContainer/NextEvent as Button
@onready var skip_to_end = $MarginContainer/Stats/ButtonContainer/HBoxContainer/AutoSim as Button
@onready var open_graph = $MarginContainer/Stats/ButtonContainer/HBoxContainer/OpenGraph as Button
@onready var next_split = $MarginContainer/Stats/ButtonContainer/HBoxContainer/NextSplit as Button
@onready var finish = $MarginContainer/Stats/ButtonContainer/HBoxContainer/Finish as Button

func _ready():
	
	input_screen.manual_simulation.connect(HardReset)
	input_screen.manual_simulation.connect(ManualSim)
	input_screen.auto_simulation.connect(HardReset)
	input_screen.auto_simulation.connect(AutoSim)
	next_event.button_down.connect(GenerateNextStep)
	skip_to_end.button_down.connect(SkipToEnd)
	open_graph.button_down.connect(OpenGraph)
	next_split.button_down.connect(NextSplit)
	finish.button_down.connect(EndSimSession)

func ManualSim():
	
	SetImportantValues() #dapatkan variabel dari Scene Input
	arrival_times = GenerateInterarrival() #generate random variates arrival
	service_times = GenerateServiceTime() #generate random variates service time 
	SaveToCSV()
	
	event_arrive = arrival_times[0] #nilai pertama arrival
	event_service = INF #nilai pertama depart
	
	arrival_label.set_text(str("%.2f" % event_arrive))
	depart_label.set_text(str("%.2f" % event_service))
	WhichGoesFirst()
	

func AutoSim():
	ManualSim()
	SkipToEnd()
	

func SaveToCSV():
	
	var directory = "user://Beta_"+str(beta_interarrival)+"Inter"+str(beta_service_time)+"Service.csv"
	
	var BetaSave = FileAccess.open(directory, FileAccess.WRITE)
	var savedata = ""
	for i in range(total_data):
		savedata += (str(arrival_times[i])+","+str(service_times[i]))
		savedata += "\n"
			
	BetaSave.store_string(savedata)

func SkipToEnd():
	while index_service != (DataPerReplikasi*ReplikasiKe):
		GenerateNextStep()
	GenerateNextStep()

func SetImportantValues():
	#[interarrival, service_time, split, total_data, lcg]
	var values = input_screen.ReturnData()
	
	beta_interarrival = values[0]
	beta_service_time = values[1]
	split = values[2]
	total_data = values[3]
	lcg = values[4]
	seed = values[5]
	
	DataPerReplikasi = int(total_data) / int(split)
	data_left = DataPerReplikasi 
	
	next_event.disabled = false
	skip_to_end.disabled = false
	data_left_label.set_text("Data Left: " + str(data_left))
	
	#UP LEFT STAT
	seed_label.set_text("Seed: "+str(seed))
	beta_interarrival_label.set_text("Beta_interarrival: "+str(beta_interarrival))
	beta_service_label.set_text("Beta_service: "+str(beta_service_time))
	replikasi_ke.set_text("Replikasi ke-"+str(ReplikasiKe))
	

func NextSplit():
	
	ResetToDefault()
	ReplikasiKe += 1
	data_left = DataPerReplikasi
	
	next_event.disabled = false
	skip_to_end.disabled = false
	next_split.disabled = true
	data_left_label.set_text("Data Left: " + str(data_left))
	
	event_arrive = arrival_times[index_arrival] #nilai pertama arrival
	event_service = INF #nilai pertama depart
	
	arrival_label.set_text(str("%.2f" % event_arrive))
	depart_label.set_text(str("%.2f" % event_service))
	WhichGoesFirst()

func GenerateNextStep():
	if event_arrive < event_service:
		Clock = event_arrive
		
		InQueue.append(str("%.2f" % event_arrive))
		
		event_arrive = event_arrive + arrival_times[index_arrival]
		index_arrival += 1
		
		if TotalInSystem == 0:
			event_service = event_arrive + service_times[index_service]
			index_service += 1
			
			#AREA BT LOGIC
			HelperBT = Clock
		else:
			
			#AREA QT LOGIC
			if QT_y == 0:
				QT_y += 1
				QT_x = Clock
			else:
				AreaQT = AreaQT + ((Clock - QT_x) * QT_y)
				QT_y += 1
				QT_x = Clock
				
			#AREA BT LOGIC
			AreaBT = AreaBT + (Clock - HelperBT)
			HelperBT = Clock
		
		TotalInSystem += 1
		
		#MISC
		NumberDelay += 1
		data_left -= 1

	else:
		Clock = event_service
		
		InQueue.erase(InQueue[0])
		
		if TotalInSystem > 1:
			
			event_service = event_service + service_times[index_service]
			index_service += 1
			
			#AREA BT LOGIC
			AreaBT = AreaBT + (Clock - HelperBT)
			HelperBT = Clock
			
			#AREA QT LOGIC
			AreaQT = AreaQT + ((Clock - QT_x) * QT_y)
			QT_y -= 1
			QT_x = Clock
			
			#TOTAL DELAY LOGIC
			TotalDelay += (Clock - float(InQueue[0]))
			total_delay_label.set_text(str("%.2f" % TotalDelay))
			
		elif TotalInSystem == 1:
			event_service = INF
			
			#AREA BT LOGIC
			AreaBT = AreaBT + (Clock - HelperBT)
			HelperBT = 0
			
			#EXIT ON LAST DEPART BYE BYE
			if index_service == (DataPerReplikasi*ReplikasiKe):
				Finish()
		
		TotalInSystem -= 1	
	
	dn = float(TotalDelay) / NumberDelay
	qn = AreaQT / Clock
	un = AreaBT / Clock
	
	#MASUK KE DALAM ARRAY QT
	ArrayAreaQTx.append(QT_x)
	ArrayAreaQTy.append(QT_y)
	
	#MASUK KE DALAM ARRAY BT
	ArrayAreaBTx.append(Clock)
	
	UpdateDisplay()
	
	if(ServerIsBusy):
		ArrayAreaBTy.append(1)
	else:
		ArrayAreaBTy.append(0)
	
	if index_arrival == (DataPerReplikasi*ReplikasiKe):
		event_arrive = INF
		
	UpdateDisplay()
	
	#update dn qn un

func GenerateInterarrival():
	var hasilInterarrival = []
	
	for i in range(total_data):
		hasilInterarrival.append(-beta_interarrival * log(1 - lcg[i]))
	
	for i in hasilInterarrival:
		print(i)
	
	#SAVE INTERARRIVAL TO CSV	
	return hasilInterarrival

func GenerateServiceTime():
	var hasilServiceTime = []
	
	for i in range(total_data):
		hasilServiceTime.append(-beta_service_time * log(1 - lcg[i]))
	
	return hasilServiceTime

func WhichGoesFirst():
	if event_arrive < event_service:
		arrival_label.set("theme_override_colors/font_color", Color.GREEN)
		label_2.set("theme_override_colors/font_color", Color.GREEN)
		depart_label.set("theme_override_colors/font_color", Color.WHITE)
		label_3.set("theme_override_colors/font_color", Color.WHITE)
	else:
		arrival_label.set("theme_override_colors/font_color", Color.WHITE)
		label_2.set("theme_override_colors/font_color", Color.WHITE)
		depart_label.set("theme_override_colors/font_color", Color.GREEN)
		label_3.set("theme_override_colors/font_color", Color.GREEN)

func UpdateDisplay():
	
	#CLOCK AND SEREVR STATUS
	clock_label.set_text(str("%.2f" % Clock))
	arrival_label.set_text(str("%.2f" % event_arrive))
	depart_label.set_text(str("%.2f" % event_service))
	UpdateQueue()
	WhichGoesFirst()
	
	#DELAY N AREA
	number_delay_label.set_text(str(NumberDelay))
	area_qt_label.set_text(str("%.2f" % AreaQT))
	area_bt_label.set_text(str("%.2f" % AreaBT))
	
	#SERVER STATUSES
	UpdateServerStatus()
	UpdateNumberInQueue()
	
	#QUEUE VIEW
	data_left_label.set_text("Data Left: " + str(data_left))
	
	#FINAL STATS
	dn_label.set_text(str("%.2f" % dn))
	qn_label.set_text(str("%.2f" % qn))
	un_label.set_text(str("%.2f" % un))

func UpdateQueue():
	var que = ""
	var foq = ""
	if InQueue.is_empty():
		foq = "-"
	else:
		for i in range(InQueue.size()):
			if i == 0:
				foq = InQueue[i]
			else:
				que = que + InQueue[i] + "\n"
	
	first_on_queue.set_text(foq)
	queue_view.set_text(que)

func UpdateServerStatus():
	if InQueue.is_empty():
		ServerIsBusy = false
		server_status_label.set_text("Idle")
		server_status_label.set("theme_override_colors/font_color", Color.YELLOW_GREEN)
	else:
		ServerIsBusy = true
		server_status_label.set_text("Busy")
		server_status_label.set("theme_override_colors/font_color", Color.DARK_ORANGE)

func UpdateNumberInQueue():
	if TotalInSystem > 0:
		NumberInQueue = TotalInSystem - 1
	number_in_queue_label.set_text(str(NumberInQueue))

func OpenGraph():
	set_QT_BT_Arrays()
	var t = queue_chart.instantiate()
	margin_container.add_child(t)

func set_QT_BT_Arrays():
	Singleton.QTx = ArrayAreaQTx
	Singleton.QTy = ArrayAreaQTy
	Singleton.BTx = ArrayAreaBTx
	Singleton.BTy = ArrayAreaBTy

func HardReset():
	ResetToDefault()
	print("reset to default")
	beta_interarrival = 0.0
	beta_service_time = 0.0
	split = 0
	total_data = 0
	lcg = []
	seed = 0

	ReplikasiKe = 1
	DataPerReplikasi = 0

	arrival_times = [] #array random variate arrival
	service_times = [] #array random variate depart
	index_arrival = 0 #index ke brp pada array arrival (anggep pointer)
	index_service = 0 #index ke brp pada array depart 
	TotalInSystem = 0 #brp banyak orang yg sedang di dalam sistem

func ResetToDefault():

#CLOCK EVENT
	Clock = 0
	clock_label.set_text("0")
	event_arrive = 0.0
	arrival_label.set("theme_override_colors/font_color", Color.WHITE)
	label_2.set("theme_override_colors/font_color", Color.WHITE)
	event_service = 0.0
	depart_label.set("theme_override_colors/font_color", Color.WHITE)
	label_3.set("theme_override_colors/font_color", Color.WHITE)

#DELAY & AREA
	NumberDelay = 0
	number_delay_label.set_text("0")
	TotalDelay = 0.0
	total_delay_label.set_text("0")
	QT_x = 0
	QT_y = 0
	AreaQT = 0.0
	ArrayAreaQTx = [] #BUAT GRAFIK
	ArrayAreaQTy = []

	area_qt_label.set_text("0")
	AreaBT = 0.0
	HelperBT = 0.0 #x
	ArrayAreaBTx = []  #BUAT GRAFIK
	ArrayAreaBTy = []
	area_bt_label.set_text("0")

#SERVER STATUSES
	ServerIsBusy = false
	server_status_label.set_text("Idle")
	server_status_label.set("theme_override_colors/font_color", Color.YELLOW_GREEN)
	NumberInQueue = 0
	number_in_queue_label.set_text("0")

	dn = 0.0
	dn_label.set_text("0")
	qn = 0.0
	qn_label.set_text("0")
	un = 0.0
	un_label.set_text("0")

#QUEUE
	InQueue = []  #orang yg di dalam sistem
	first_on_queue.set_text("-")
	queue_view.set_text("")
	data_left = DataPerReplikasi - 1
	data_left_label.set_text(str(data_left))

func Finish():
	print(index_arrival)
	print(index_service)
	next_event.disabled = true
	skip_to_end.disabled = true
	next_split.disabled = false
	
	Arraydn.append(dn)
	Arrayqn.append(qn)
	Arrayun.append(un)
	
	if int(ReplikasiKe) == int(split):
		finish.disabled = false
		next_split.disabled = true

func EndSimSession():
	
	var directory = "user://FinalReport_"+str(beta_interarrival)+"Inter"+str(beta_service_time)+"Service.csv"
	
	var BetaSave = FileAccess.open(directory, FileAccess.WRITE)
	var savedata = ""
	
	for i in range(int(split)):
		savedata += (str(Arraydn[i])+","+str(Arrayqn[i])+","+str(Arrayun[i]))
		savedata += "\n"
			
	BetaSave.store_string(savedata)
	
	input_screen.visible = true
	input_screen.set_process(true)
