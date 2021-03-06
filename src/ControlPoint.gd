extends Area

var side : int = -1
var players_inside = []

func _on_ControlPoint_body_entered(body):
	var main = get_tree().get_root().get_node("Main")
	if main.rewinding:
		return
		
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
		players_inside.erase(body)
	pass
	
