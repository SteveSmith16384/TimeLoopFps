extends Node2D


func _process(delta):
#	var val = Input.get_action_strength("turn_left2") - Input.get_action_strength("turn_right2")
	var val = Input.get_action_strength("move_forward2") - Input.get_action_strength("move_backward2")
	$Label.text = "Val:" + str(val)
	pass
