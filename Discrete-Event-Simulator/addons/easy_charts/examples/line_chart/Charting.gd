extends Control

@onready var QTchart: Chart = $MarginContainer/VBoxContainer/Chart
@onready var BTchart: Chart = $MarginContainer/VBoxContainer/Chart2
@onready var button_2 = $MarginContainer/VBoxContainer/Button2 as Button
@onready var control_2 = $"." as Control

signal closedChart
# This Chart will plot 3 different functions
var f1: Function
var f2: Function
var cp: ChartProperties = ChartProperties.new()
var cp2: ChartProperties = ChartProperties.new()

var QTx = [0]
var QTy = [0]
	
var BTx = [0]
var BTy = [0]

func _ready():
	
	
	button_2.button_down.connect(Refresh)
	#ShowChart.connect(GenerateChart)
	
	# Let's create our @x values
	
	# And our y values. It can be an n-size array of arrays.
	# NOTE: `x.size() == y.size()` or `x.size() == y[n].size()`
	
	
	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	cp.colors.frame = Color("#161a1d")
	cp.colors.background = Color.TRANSPARENT
	cp.colors.grid = Color("#283442")
	cp.colors.ticks = Color("#283442")
	cp.colors.text = Color.WHITE_SMOKE
	cp.draw_bounding_box = false
	cp.title = "Q(t)"
	cp.x_label = "Interarrival"
	cp.y_label = "Queue"
	cp.x_scale = 1
	cp.y_scale = 1
	cp.interactive = true 
	
	cp2.colors.frame = Color("#161a1d")
	cp2.colors.background = Color.TRANSPARENT
	cp2.colors.grid = Color("#283442")
	cp2.colors.ticks = Color("#283442")
	cp2.colors.text = Color.WHITE_SMOKE
	cp2.draw_bounding_box = false
	cp2.title = "B(t)"
	cp2.x_label = "Interarrival"
	cp2.y_label = "Busy"
	cp2.x_scale = 1
	cp2.y_scale = 0.5
	cp2.interactive = true 
	
	# Let's add values to our functions
	GenerateChart()
	
	# Now let's plot our data
	
func GenerateChart():
	#[ArrayAreaQTx, ArrayAreaQTy, ArrayAreaBTx, ArrayAreaBTy]
	
		
	QTx = Singleton.QTx
	QTy = Singleton.QTy
	BTx = Singleton.BTx
	BTy = Singleton.BTy
	
	f1 = Function.new(
		QTx, QTy, "In Queue", 
		{ 
			color = Color("#36a2eb"), 		# The color associated to this function
			marker = Function.Marker.CIRCLE, 	# The marker that will be displayed for each drawn point (x,y)
											# since it is `NONE`, no marker will be shown.
			type = Function.Type.LINE, 		# This defines what kind of plotting will be used, 
											# in this case it will be a Linear Chart.
			interpolation = Function.Interpolation.STAIR	# Interpolation mode, only used for 
															# Line Charts and Area Charts.
		}
	)
	
	f2 = Function.new(
		BTx, BTy, "Busy", 
		{ 
			color = Color("#25a2aa"), 		# The color associated to this function
			marker = Function.Marker.CIRCLE, 	# The marker that will be displayed for each drawn point (x,y)
											# since it is `NONE`, no marker will be shown.
			type = Function.Type.LINE, 		# This defines what kind of plotting will be used, 
											# in this case it will be a Linear Chart.
			interpolation = Function.Interpolation.STAIR	# Interpolation mode, only used for 
															# Line Charts and Area Charts.
		}
	)
	QTchart.plot([f1], cp)
	BTchart.plot([f2], cp2)


#func nextIter():
	## This function updates the values of a function and then updates the plot
	#new_val += 5
	#
	## we can use the `Function.add_point(x, y)` method to update a function
	#f1.add_point(new_val, cos(new_val) * 20)
	#f2.add_point(new_val, cos(new_val) * 20)
	#
	#QTchart.plot([f1], cp)
	#
	#QTchart.queue_redraw()
	#BTchart.queue_redraw() # This will force the Chart to be updated

func Refresh():
	queue_free()
