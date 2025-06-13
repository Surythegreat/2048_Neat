extends Node2D
@onready var agent=$main

var time=0.0
var step =0.2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time+=delta
	if time>step:
		agent.step()
		time=0
