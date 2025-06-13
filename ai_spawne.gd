extends Node2D
@export var mainScene="res://main.tscn"
var ga = GeneticAlgorithm.new(16,4,mainScene,true,"2048_param")
var lastscenes:Array

@onready var graph=$Camera2D/PlotSint/Graph2D
var steps=0;

var is_debug=false
var fitness_threshhold=2800000


var lastGenerations:Array=[]
@export var dist=800
const ONE_ROW=16
var gra
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(ga)
	place_bodies(ga.get_curr_bodies())
	gra = graph.add_plot_item("performance",Color.RED,10)
	gra.remove_all()
	graph.visible=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("ui_accept")):
		is_debug=!is_debug
		for s in lastscenes:
			s.is_debug=is_debug
	if(Input.is_action_just_pressed("q")):
		graph.visible=!graph.visible
		
	steps+=1
	ga.next_timestep()
	if ga.all_agents_dead:
		ga.evaluate_generation()
		print("total steps:",steps)
		lastGenerations.push_back(log(ga.curr_best.fitness)/log(8))
		print("generationscore",lastGenerations.back())
		if lastGenerations.size()>100:
			lastGenerations.pop_front()
		if(ga.curr_best.fitness>fitness_threshhold):
			ga.curr_best.agent.network.save_to_json("test1_"+str(ga.curr_generation)+"_ai")
			fitness_threshhold=ga.curr_best.fitness*2
		if(graph.visible):
			gra.remove_all()
			if(ga.curr_generation>100):
				for i in range(100):
					gra.add_point(Vector2(i,lastGenerations[i]))
			else:
				for i in range(ga.curr_generation-1):
					gra.add_point(Vector2(i,lastGenerations[i]))
		ga.next_generation()
		place_bodies(ga.get_curr_bodies())
		steps=0

func place_bodies(bodies:Array):
	if(!lastscenes.is_empty()):
		for s in lastscenes:
			s.queue_free()
		lastscenes=[]
	
	for i in bodies.size():
		bodies[i].transform.origin=Vector2((i%ONE_ROW)*dist,(i/ONE_ROW)*dist)
		bodies[i].is_debug=is_debug
		add_child(bodies[i])
		lastscenes.append(bodies[i])
	
