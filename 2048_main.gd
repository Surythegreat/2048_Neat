
extends Node2D

@export var box:PackedScene
@export var box_side:float
@export var offset:Vector2
@export var colorGrad:Gradient

var is_debug=false
const SIZE := 4
const EMPTY := -1
signal death

var isdeath:bool=false

var haschanged:bool=false
var notchanged:int=0

var grid : Array = []
var boxes:Array
var NetworkClass = preload("res://NEAT_usability/standalone_scripts/standalone_neuralnet.gd")
var network = NetworkClass.new()
@export var neuronName:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_grid()
	generate()
	network.load_config(neuronName)
	
func step():
	if(isdeath):
		return
	var inp=[]
	for i in grid:
		for j in i:
			inp.append((j+1.0)/18.0)
	var network_output = network.update(inp)
	var maxednum=-1;
	var maxind=-1
	for i in range(4):
		if(network_output[i]>maxednum):
			maxednum=network_output[i]
			maxind=i
	if(maxind==0):
		Clear()
		move_left()
		generate()
		if(!haschanged):
			notchanged+=1
		else:
			notchanged=0
		if(is_game_over() ||notchanged>=16):
			death.emit()
		haschanged=false
	elif(maxind==1):
		Clear()
		move_right()
		generate()
		if(!haschanged):
			notchanged+=1
		else:
			notchanged=0
		if(is_game_over() ||notchanged>=16):
			death.emit()
		haschanged=false
	elif(maxind==2):
		Clear()
		move_up()
		generate()
		if(!haschanged):
			notchanged+=1
		else:
			notchanged=0
		if(is_game_over() ||notchanged>=16):
			death.emit()
		haschanged=false
	elif(maxind==3):
		Clear()
		move_down()
		generate()
		if(!haschanged):
			notchanged+=1
		else:
			notchanged=0
		if(is_game_over() ||notchanged>=16):
			death.emit()
		haschanged=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if(Input.is_action_just_pressed("ui_up")):
		#Clear()
		#move_left()
		#generate()
		#if(is_game_over()):
			#print("game over")
	#elif(Input.is_action_just_pressed("ui_down")):
		#Clear()
		#move_right()
		#generate()
		#if(is_game_over()):
			#print("game over")
	#elif(Input.is_action_just_pressed("ui_left")):
		#Clear()
		#move_up()
		#generate()
		#if(is_game_over()):
			#print("game over")
	#elif(Input.is_action_just_pressed("ui_right")):
		#Clear()
		#move_down()
		#generate()
		#if(is_game_over()):
			#print("game over")

func sense() -> Array:
	var inp=[]
	for i in grid:
		for j in i:
			inp.append((j+1.0)/12.0)
	return inp
	

func act(network_output) -> void:
	var maxednum=-1;
	var maxind=-1
	for i in range(4):
		if(network_output[i]>maxednum):
			maxednum=network_output[i]
			maxind=i
	if(maxind==0):
		Clear()
		move_left()
		generate()
		if(!haschanged):
			notchanged+=1
		else:
			notchanged=0
		if(is_game_over() ||notchanged>=16):
			death.emit()
		haschanged=false
	elif(maxind==1):
		Clear()
		move_right()
		generate()
		if(!haschanged):
			notchanged+=1
		else:
			notchanged=0
		if(is_game_over() ||notchanged>=16):
			death.emit()
		haschanged=false
	elif(maxind==2):
		Clear()
		move_up()
		generate()
		if(!haschanged):
			notchanged+=1
		else:
			notchanged=0
		if(is_game_over() ||notchanged>=16):
			death.emit()
		haschanged=false
	elif(maxind==3):
		Clear()
		move_down()
		generate()
		if(!haschanged):
			notchanged+=1
		else:
			notchanged=0
		if(is_game_over() ||notchanged>=16):
			death.emit()
		haschanged=false

func get_fitness() -> float:
	var fitness=0
	for i in grid:
		for j in i:
			fitness+=pow(8,j)
			
	return fitness




func generate():
	if(!is_debug):
		for i in range(4):
			for j in range(4):
				if(grid[i][j]!=EMPTY):
					var b= box.instantiate()
					b.transform.origin = Vector2(i*box_side,j*box_side)+offset
					b.get_child(0).text = str(int(pow(2,grid[i][j])))
					b.set_modulate(colorGrad.sample((grid[i][j])/10.0))
					add_child(b)
					boxes.append(b)

func Clear():
	while !boxes.is_empty():
		boxes.pop_back().queue_free()


func init_grid():
	# Fill grid with -1 (empty)
	grid = []
	for i in SIZE:
		var row = []
		for j in SIZE:
			row.append(EMPTY)
		grid.append(row)

	# Add two initial tiles for demonstration
	add_random_tile()
	add_random_tile()


#func print_grid():
	#for row in grid:
		#print(row) 
	#print("-----------------")


func add_random_tile():
	var empty_cells = []
	for i in SIZE:
		for j in SIZE:
			if grid[i][j] == EMPTY:
				empty_cells.append(Vector2i(i, j))
	if empty_cells.size() == 0:
		return

	var rand_pos = empty_cells[randi() % empty_cells.size()]
	grid[rand_pos.x][rand_pos.y] = 1  # 4 or 2 → log2(4)=2, log2(2)=1


# Core logic: compress + merge
func process_line(line: Array) -> Array:
	var new_line = []
	for val in line:
		if val != EMPTY:
			new_line.append(val)
	while new_line.size() < SIZE:
		new_line.append(EMPTY)
	
	for i in range(SIZE - 1):
		if new_line[i] != EMPTY and new_line[i] == new_line[i + 1]:
			
			new_line[i] += 1  # merge: log2(x) + 1 = log2(2x)
			new_line[i + 1] = EMPTY

	# Compress again after merge
	var final_line = []
	for val in new_line:
		if val != EMPTY:
			final_line.append(val)
	while final_line.size() < SIZE:
		final_line.append(EMPTY)
	for i in range(4):
		if line[i]!=final_line[i] :
			haschanged=true
			break
	return final_line


# Left
func move_left():
	for i in SIZE:
		grid[i] = process_line(grid[i])
	add_random_tile()


# Right
func move_right():
	for i in SIZE:
		grid[i].reverse()
		grid[i] = process_line(grid[i])
		grid[i].reverse()
	add_random_tile()

func is_game_over() -> bool:
	# Check for any empty cell
	for i in SIZE:
		for j in SIZE:
			if grid[i][j] == EMPTY:
				return false  # Not over

	# Check for horizontal merges
	for i in SIZE:
		for j in SIZE - 1:
			if grid[i][j] == grid[i][j + 1]:
				return false  # Merge is possible

	# Check for vertical merges
	for j in SIZE:
		for i in SIZE - 1:
			if grid[i][j] == grid[i + 1][j]:
				return false  # Merge is possible

	return true  # No moves left
# Up
func move_up():
	for col in SIZE:
		var column = []
		for row in SIZE:
			column.append(grid[row][col])
		var new_column = process_line(column)
		for row in SIZE:
			grid[row][col] = new_column[row]
	add_random_tile()


# Down
func move_down():
	for col in SIZE:
		var column = []
		for row in SIZE:
			column.append(grid[row][col])
		column.reverse()
		var new_column = process_line(column)
		new_column.reverse()
		for row in SIZE:
			grid[row][col] = new_column[row]
	add_random_tile()


func _on_death() -> void:
	modulate=(Color(1,0,0))
	print(neuronName)
	isdeath=true
