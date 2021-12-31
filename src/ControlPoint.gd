extends Area

var side : int

func _on_ControlPoint_body_entered(body):
	if body.is_in_group("players"):
		side = body.sidew
		#todo - change colour
		pass
	pass
