extends Area

var side : int
var players_inside = []


func _on_ControlPoint_body_entered(body):
	if body.is_in_group("players"):
		if body.is_alive():
			if players_inside.size() == 0:
				side = body.side

				$CSGCylinder/AlternateMaterialColours.active = false
				$CSGCylinder.material.albedo_color = Globals.colors[side];
				$AudioStreamPlayer_Landed.play()
			players_inside.push_back(body)
		pass
	pass


func _on_ControlPoint_body_exited(body):
	if body.is_in_group("players"):
		players_inside.remove(players_inside.find(body))
	pass
	
