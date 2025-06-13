extends Camera2D

const  speed=1000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_pressed("ui_left")):
		transform.origin.x-=speed*delta
	elif(Input.is_action_pressed("ui_right")):
		transform.origin.x+=speed*delta
