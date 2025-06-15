extends Node2D


var time=0.0
var step =0.2
@export var main:PackedScene
@export var neurons:Array

var agents:Array
var NetworkClass = preload("res://NEAT_usability/standalone_scripts/standalone_neuralnet.gd")
var network = NetworkClass.new()
func _ready() -> void:
	#var allneurons = network.get_saved_networks()
	#for i in allneurons:
		#if(i.begins_with("main3_")):
			#neurons.append(i)
	for i in neurons.size():
		var v =main.instantiate()
		v.transform.origin = Vector2(i*673,0)
		v.neuronName=neurons[i]
		add_child(v)
		agents.append(v)
		time=0
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time+=delta
	if time>step:
		for i in agents:
			i.step()
		time=0
